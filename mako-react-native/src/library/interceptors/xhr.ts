/**
 * XHR Interceptor - Monkey-patches XMLHttpRequest to capture network requests
 *
 * Based on Reactotron's approach which is independent of React Native version.
 * Original source: https://github.com/infinitered/reactotron
 *
 * This approach works on ALL React Native versions (0.60+) because it patches
 * XMLHttpRequest directly instead of relying on RN's internal XHRInterceptor.
 */

import type { NetworkCallbacks } from '../types';

// Store original XMLHttpRequest methods
const originalXHROpen = XMLHttpRequest.prototype.open;
const originalXHRSend = XMLHttpRequest.prototype.send;
const originalXHRSetRequestHeader = XMLHttpRequest.prototype.setRequestHeader;

// Callback references
let openCallback: ((method: string, url: string, xhr: XMLHttpRequest) => void) | null = null;
let sendCallback: ((data: unknown, xhr: XMLHttpRequest) => void) | null = null;
let requestHeaderCallback: ((header: string, value: string, xhr: XMLHttpRequest) => void) | null =
  null;
let headerReceivedCallback:
  | ((
      responseContentType: string | undefined,
      responseSize: number | undefined,
      allHeaders: string,
      xhr: XMLHttpRequest
    ) => void)
  | null = null;
let responseCallback:
  | ((
      status: number,
      timeout: number,
      response: string,
      responseURL: string,
      responseType: string,
      xhr: XMLHttpRequest
    ) => void)
  | null = null;

let interceptorEnabled = false;

/**
 * Check if the interceptor is currently enabled
 */
export function isInterceptorEnabled(): boolean {
  return interceptorEnabled;
}

/**
 * Enable network interception with the provided callbacks
 */
export function enableNetworkInterception(callbacks: NetworkCallbacks): boolean {
  if (interceptorEnabled) {
    console.warn('[Mako] Network interceptor already enabled');
    return false;
  }

  // Store callbacks
  openCallback = callbacks.onOpen;
  sendCallback = callbacks.onSend;
  requestHeaderCallback = callbacks.onRequestHeader;
  headerReceivedCallback = callbacks.onHeaderReceived;
  responseCallback = (
    status: number,
    timeout: number,
    response: string,
    responseURL: string,
    responseType: string,
    xhr: XMLHttpRequest
  ) => {
    callbacks.onResponse(status, timeout > 0, response, responseURL, responseType, xhr);
  };

  // Monkey-patch XMLHttpRequest.prototype.open
  XMLHttpRequest.prototype.open = function (method: string, url: string | URL) {
    if (openCallback) {
      openCallback(method, url.toString(), this);
    }
    // @ts-ignore - apply with arguments
    return originalXHROpen.apply(this, arguments);
  };

  // Monkey-patch XMLHttpRequest.prototype.setRequestHeader
  XMLHttpRequest.prototype.setRequestHeader = function (header: string, value: string) {
    if (requestHeaderCallback) {
      requestHeaderCallback(header, value, this);
    }
    // @ts-ignore - apply with arguments
    return originalXHRSetRequestHeader.apply(this, arguments);
  };

  // Monkey-patch XMLHttpRequest.prototype.send
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  XMLHttpRequest.prototype.send = function (data?: any) {
    if (sendCallback) {
      sendCallback(data, this);
    }

    // Add event listener for state changes
    if (this.addEventListener) {
      this.addEventListener('readystatechange', () => {
        if (!interceptorEnabled) {
          return;
        }

        // HEADERS_RECEIVED state
        if (this.readyState === this.HEADERS_RECEIVED) {
          const contentTypeString = this.getResponseHeader('Content-Type');
          const contentLengthString = this.getResponseHeader('Content-Length');

          let responseContentType: string | undefined;
          let responseSize: number | undefined;

          if (contentTypeString) {
            responseContentType = contentTypeString.split(';')[0];
          }
          if (contentLengthString) {
            responseSize = parseInt(contentLengthString, 10);
          }

          if (headerReceivedCallback) {
            headerReceivedCallback(
              responseContentType,
              responseSize,
              this.getAllResponseHeaders(),
              this
            );
          }
        }

        // DONE state
        if (this.readyState === this.DONE) {
          if (responseCallback) {
            responseCallback(
              this.status,
              this.timeout,
              this.response,
              this.responseURL,
              this.responseType,
              this
            );
          }
        }
      });
    }

    // @ts-ignore - apply with arguments
    return originalXHRSend.apply(this, arguments);
  };

  interceptorEnabled = true;
  console.log('[Mako] Network interception enabled (XMLHttpRequest monkey-patch)');
  return true;
}

/**
 * Disable network interception and restore original XMLHttpRequest methods
 */
export function disableNetworkInterception(): void {
  if (!interceptorEnabled) {
    return;
  }

  interceptorEnabled = false;

  // Restore original methods
  XMLHttpRequest.prototype.open = originalXHROpen;
  XMLHttpRequest.prototype.send = originalXHRSend;
  XMLHttpRequest.prototype.setRequestHeader = originalXHRSetRequestHeader;

  // Clear callbacks
  openCallback = null;
  sendCallback = null;
  requestHeaderCallback = null;
  headerReceivedCallback = null;
  responseCallback = null;

  console.log('[Mako] Network interception disabled');
}
