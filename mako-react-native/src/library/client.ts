/**
 * WebSocket client for communicating with Mako macOS app
 */

import { Platform } from 'react-native';
import { NitroModules } from 'react-native-nitro-modules';
import type {
  MakoConfig,
  MakoEvent,
  PendingRequest,
  NetworkRequestEvent,
  NetworkResponseEvent,
  NetworkCallbacks,
  DeviceInfoEvent,
  LogEvent,
  NativeLogEvent,
  LogLevel,
  NativeLogSource,
} from './types';
import type { NitroMako as NitroMakoSpec } from '../specs/mako.nitro';
import { enableNetworkInterception, disableNetworkInterception } from './interceptors/xhr';
import { getDeviceInfo } from './device';

// Default URLs to ignore (Metro bundler, hot reload, etc.)
const DEFAULT_IGNORED_URLS: RegExp[] = [
  /localhost:8081/,
  /127\.0\.0\.1:8081/,
  /10\.0\.2\.2:8081/, // Android emulator
  /symbolicate/,
  /\.hot-update\./,
  /hot$/,
  /\.bundle/,
  /__packager/,
  /debugger-ui/,
  /devtools/,
];

/**
 * Mako WebSocket Client
 */
class MakoClient {
  private ws: WebSocket | null = null;
  private config: Required<MakoConfig>;
  private pendingRequests: Map<XMLHttpRequest, PendingRequest> = new Map();
  private messageQueue: MakoEvent[] = [];
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectTimeout: ReturnType<typeof setTimeout> | null = null;
  private isConnecting = false;
  private manualDisconnect = false;

  // Native log capture
  private nitroMako: NitroMakoSpec | null = null;
  private nativeLogCaptureEnabled = false;

  constructor() {
    this.config = {
      host: 'localhost',
      port: 8765,
      enableNetworkCapture: true,
      ignoredUrls: [],
      onConnect: () => {},
      onDisconnect: () => {},
      onError: () => {},
    };
  }

  /**
   * Connect to Mako macOS app
   */
  connect(userConfig: MakoConfig = {}): void {
    // Only run in development
    if (typeof __DEV__ !== 'undefined' && !__DEV__) {
      console.warn('[Mako] SDK only works in development mode');
      return;
    }

    // Merge config with defaults
    this.config = {
      host: userConfig.host ?? 'localhost',
      port: userConfig.port ?? 8765,
      enableNetworkCapture: userConfig.enableNetworkCapture ?? true,
      ignoredUrls: [...DEFAULT_IGNORED_URLS, ...(userConfig.ignoredUrls ?? [])],
      onConnect: userConfig.onConnect ?? (() => {}),
      onDisconnect: userConfig.onDisconnect ?? (() => {}),
      onError: userConfig.onError ?? (() => {}),
    };

    this.manualDisconnect = false;
    this.connectWebSocket();
  }

  /**
   * Disconnect from Mako
   */
  disconnect(): void {
    this.manualDisconnect = true;
    this.cleanup();
  }

  /**
   * Check if connected
   */
  isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }

  /**
   * Send a log event to Mako
   */
  sendLog(level: LogLevel, message: string, metadata?: Record<string, unknown>): void {
    const event: LogEvent = {
      type: 'log',
      source: 'js',
      level,
      message,
      timestamp: Date.now(),
      metadata,
    };
    this.send(event);
  }

  /**
   * Start capturing native platform logs (NSLog/print on iOS, Logcat on Android)
   * Called automatically on connect
   */
  startNativeLogCapture(): boolean {
    if (this.nativeLogCaptureEnabled) {
      console.warn('[Mako] Native log capture already enabled');
      return false;
    }

    try {
      const nitro = this.getNitroMako();
      const success = nitro.startLogCapture((log) => {
        this.handleNativeLog(log);
      });

      if (success) {
        this.nativeLogCaptureEnabled = true;
        console.log('[Mako] Native log capture enabled');
      }
      return success;
    } catch (error) {
      console.error('[Mako] Failed to start native log capture:', error);
      return false;
    }
  }

  /**
   * Stop capturing native platform logs
   */
  stopNativeLogCapture(): void {
    if (!this.nativeLogCaptureEnabled) return;

    try {
      const nitro = this.getNitroMako();
      nitro.stopLogCapture();
      this.nativeLogCaptureEnabled = false;
      console.log('[Mako] Native log capture disabled');
    } catch (error) {
      console.error('[Mako] Failed to stop native log capture:', error);
    }
  }

  /**
   * Check if native log capture is active
   */
  isNativeLogCaptureEnabled(): boolean {
    return this.nativeLogCaptureEnabled;
  }

  /**
   * Internal: Get or create NitroMako instance
   */
  private getNitroMako(): NitroMakoSpec {
    if (!this.nitroMako) {
      this.nitroMako = NitroModules.createHybridObject<NitroMakoSpec>('NitroMako');
    }
    return this.nitroMako;
  }

  /**
   * Internal: Handle native log entry from NitroMako
   */
  private handleNativeLog(log: { level: string; message: string; tag: string; timestamp: number }): void {
    const platform = Platform.OS as NativeLogSource;

    // Map 'verbose' to 'debug' (verbose is used in native to avoid iOS DEBUG macro conflict)
    const level = log.level === 'verbose' ? 'debug' : log.level;

    const event: NativeLogEvent = {
      type: 'native',
      source: platform,
      level: level as LogLevel,
      message: log.message,
      timestamp: log.timestamp,
      metadata: log.tag ? { tag: log.tag } : undefined,
    };

    this.send(event);
  }

  /**
   * Internal: Connect WebSocket
   */
  private connectWebSocket(): void {
    if (this.isConnecting || this.isConnected()) return;

    this.isConnecting = true;
    const url = `ws://${this.config.host}:${this.config.port}`;

    try {
      this.ws = new WebSocket(url);

      this.ws.onopen = () => {
        this.isConnecting = false;
        this.reconnectAttempts = 0;
        console.log(`[Mako] Connected to ${url}`);
        this.config.onConnect();

        // Send device info first
        this.sendDeviceInfo();

        // Send queued messages
        this.flushQueue();

        // Enable network interception if configured
        if (this.config.enableNetworkCapture) {
          this.setupNetworkInterception();
        }

        // Enable native log capture automatically
        this.startNativeLogCapture();
      };

      this.ws.onclose = () => {
        this.isConnecting = false;
        console.log('[Mako] Disconnected');
        this.config.onDisconnect();

        // Attempt reconnection if not manually disconnected
        if (!this.manualDisconnect) {
          this.scheduleReconnect();
        }
      };

      this.ws.onerror = (event) => {
        this.isConnecting = false;
        const error = new Error('WebSocket error');
        console.error('[Mako] Connection error:', event);
        this.config.onError(error);
      };

      this.ws.onmessage = (event) => {
        // Handle incoming messages from Mako (future feature)
        console.log('[Mako] Received:', event.data);
      };
    } catch (error) {
      this.isConnecting = false;
      console.error('[Mako] Failed to create WebSocket:', error);
      this.scheduleReconnect();
    }
  }

  /**
   * Internal: Schedule reconnection with exponential backoff
   */
  private scheduleReconnect(): void {
    if (this.manualDisconnect) return;
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      console.warn('[Mako] Max reconnection attempts reached');
      return;
    }

    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
    this.reconnectAttempts++;

    console.log(`[Mako] Reconnecting in ${delay}ms (attempt ${this.reconnectAttempts})`);

    this.reconnectTimeout = setTimeout(() => {
      this.connectWebSocket();
    }, delay);
  }

  /**
   * Internal: Cleanup resources
   */
  private cleanup(): void {
    if (this.reconnectTimeout) {
      clearTimeout(this.reconnectTimeout);
      this.reconnectTimeout = null;
    }

    // Stop native log capture
    this.stopNativeLogCapture();

    disableNetworkInterception();

    if (this.ws) {
      this.ws.onopen = null;
      this.ws.onclose = null;
      this.ws.onerror = null;
      this.ws.onmessage = null;
      this.ws.close();
      this.ws = null;
    }

    this.pendingRequests.clear();
    this.messageQueue = [];
    this.reconnectAttempts = 0;
    this.isConnecting = false;
  }

  /**
   * Internal: Send event to Mako
   */
  private send(event: MakoEvent): void {
    if (this.isConnected() && this.ws) {
      try {
        this.ws.send(JSON.stringify(event));
      } catch (error) {
        console.error('[Mako] Failed to send event:', error);
        this.messageQueue.push(event);
      }
    } else {
      // Queue message for later
      this.messageQueue.push(event);
    }
  }

  /**
   * Internal: Send device info to Mako
   */
  private async sendDeviceInfo(): Promise<void> {
    try {
      const deviceInfo = await getDeviceInfo();
      const event: DeviceInfoEvent = {
        type: 'device_info',
        ...deviceInfo,
      };
      this.send(event);
      console.log(`[Mako] Device registered: ${deviceInfo.deviceName} (${deviceInfo.deviceId})`);
    } catch (error) {
      console.warn('[Mako] Failed to send device info:', error);
    }
  }

  /**
   * Internal: Flush queued messages
   */
  private flushQueue(): void {
    while (this.messageQueue.length > 0 && this.isConnected()) {
      const event = this.messageQueue.shift();
      if (event) {
        this.send(event);
      }
    }
  }

  /**
   * Internal: Check if URL should be ignored
   */
  private shouldIgnoreUrl(url: string): boolean {
    return this.config.ignoredUrls.some((pattern) => pattern.test(url));
  }

  /**
   * Internal: Generate unique request ID
   */
  private generateRequestId(): string {
    return `${Date.now()}-${Math.random().toString(36).substring(2, 11)}`;
  }

  /**
   * Internal: Parse response headers string into object
   */
  private parseResponseHeaders(headersString: string): Record<string, string> {
    const headers: Record<string, string> = {};
    if (!headersString) return headers;

    const lines = headersString.trim().split(/[\r\n]+/);
    for (const line of lines) {
      const colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        const key = line.substring(0, colonIndex).trim();
        const value = line.substring(colonIndex + 1).trim();
        if (key) {
          headers[key] = value;
        }
      }
    }
    return headers;
  }

  /**
   * Internal: Setup network interception callbacks
   */
  private setupNetworkInterception(): void {
    const callbacks: NetworkCallbacks = {
      onOpen: (method: string, url: string, xhr: XMLHttpRequest) => {
        if (this.shouldIgnoreUrl(url)) return;

        const request: PendingRequest = {
          id: this.generateRequestId(),
          method,
          url,
          headers: {},
          startTime: Date.now(),
        };
        this.pendingRequests.set(xhr, request);
      },

      onRequestHeader: (header: string, value: string, xhr: XMLHttpRequest) => {
        const request = this.pendingRequests.get(xhr);
        if (request) {
          request.headers[header] = value;
        }
      },

      onSend: (data: unknown, xhr: XMLHttpRequest) => {
        const request = this.pendingRequests.get(xhr);
        if (!request) return;

        // Convert body to string
        if (data !== null && data !== undefined) {
          request.body = typeof data === 'string' ? data : JSON.stringify(data);
        }

        // Send request event
        const event: NetworkRequestEvent = {
          type: 'network',
          stage: 'request',
          requestId: request.id,
          method: request.method,
          url: request.url,
          headers: request.headers,
          body: request.body,
          timestamp: request.startTime,
        };
        this.send(event);
      },

      onHeaderReceived: (
        _responseContentType: string | undefined,
        _responseSize: number | undefined,
        responseHeaders: string,
        xhr: XMLHttpRequest
      ) => {
        // Store response headers for later use in onResponse
        const request = this.pendingRequests.get(xhr);
        if (request) {
          request.responseHeaders = this.parseResponseHeaders(responseHeaders);
        }
      },

      onResponse: (
        status: number,
        _timeout: boolean,
        response: unknown,
        responseURL: string,
        responseType: string,
        xhr: XMLHttpRequest
      ) => {
        const request = this.pendingRequests.get(xhr);
        if (!request) return;

        const endTime = Date.now();

        // Helper function to send the response event
        const sendResponseEvent = (bodyString: string | undefined) => {
          const event: NetworkResponseEvent = {
            type: 'network',
            stage: 'response',
            requestId: request.id,
            method: request.method,
            url: responseURL || request.url,
            statusCode: status,
            duration: endTime - request.startTime,
            headers: request.responseHeaders,
            body: bodyString,
            timestamp: endTime,
          };
          this.send(event);
          this.pendingRequests.delete(xhr);
        };

        // Handle Blob response type with FileReader (async)
        // This is how React Native often returns response data
        if (responseType === 'blob' && response instanceof Blob) {
          const reader = new FileReader();
          reader.onloadend = () => {
            const text = reader.result as string;
            sendResponseEvent(text);
          };
          reader.onerror = () => {
            sendResponseEvent(undefined);
          };
          reader.readAsText(response);
          return;
        }

        // For other types, process synchronously
        let bodyString: string | undefined;

        // First, try xhr.responseText which is always a string (most reliable)
        try {
          if (xhr.responseText) {
            bodyString = xhr.responseText;
          }
        } catch {
          // responseText may throw if responseType is not '' or 'text'
        }

        // Fallback: try to convert the response parameter
        if (!bodyString && response !== null && response !== undefined) {
          if (typeof response === 'string') {
            bodyString = response;
          } else if (typeof response === 'object') {
            try {
              bodyString = JSON.stringify(response, null, 2);
            } catch {
              bodyString = String(response);
            }
          }
        }

        sendResponseEvent(bodyString);
      },
    };

    const success = enableNetworkInterception(callbacks);
    if (success) {
      console.log('[Mako] Network capture enabled');
    }
  }
}

// Export singleton instance
export const client = new MakoClient();
