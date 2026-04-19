/**
 * Device identification utilities
 * Uses native APIs via NitroMako for device info and persistent storage
 */

import { Platform } from 'react-native';
import { NitroMako } from '../index';

// Cache for device info
let cachedDeviceId: string | null = null;
let cachedDeviceName: string | null = null;

/**
 * Generate a unique device ID (UUID v4)
 */
function generateUUID(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}

/**
 * Get or create a persistent device ID
 */
function getOrCreateDeviceId(): string {
  if (cachedDeviceId) {
    return cachedDeviceId;
  }

  try {
    // Try to get device info from native (includes vendor ID on iOS, ANDROID_ID on Android)
    const nativeInfo = NitroMako.getDeviceInfo();
    if (nativeInfo.deviceId) {
      cachedDeviceId = nativeInfo.deviceId;
      return nativeInfo.deviceId;
    }
  } catch {
    // Native device info not available
  }

  // Fallback: use native storage for persistent ID
  try {
    const storedId = NitroMako.getStoredDeviceId();
    if (storedId) {
      cachedDeviceId = storedId;
      return storedId;
    }

    // Generate new ID and store it
    const newId = generateUUID();
    NitroMako.storeDeviceId(newId);
    cachedDeviceId = newId;
    return newId;
  } catch {
    // Native storage not available, generate temporary ID
    cachedDeviceId = generateUUID();
    return cachedDeviceId;
  }
}

/**
 * Get device name
 */
function getDeviceName(): string {
  if (cachedDeviceName) {
    return cachedDeviceName;
  }

  try {
    const nativeInfo = NitroMako.getDeviceInfo();
    if (nativeInfo.deviceName) {
      cachedDeviceName = nativeInfo.deviceName;
      return nativeInfo.deviceName;
    }
  } catch {
    // Native device info not available
  }

  // Fallback to platform-based name
  const model = Platform.OS === 'ios' ? 'iOS Device' : 'Android Device';
  cachedDeviceName = model;
  return model;
}

/**
 * Get app name
 */
function getAppName(): string {
  try {
    const nativeInfo = NitroMako.getDeviceInfo();
    return nativeInfo.appName || 'React Native App';
  } catch {
    return 'React Native App';
  }
}

/**
 * Get bundle identifier
 */
function getBundleId(): string {
  try {
    const nativeInfo = NitroMako.getDeviceInfo();
    return nativeInfo.bundleId || '';
  } catch {
    return '';
  }
}

/**
 * Get complete device info
 */
export interface DeviceInfoData {
  deviceId: string;
  deviceName: string;
  platform: 'ios' | 'android';
  appName: string;
  bundleId: string;
}

export async function getDeviceInfo(): Promise<DeviceInfoData> {
  // Use native methods (they are synchronous but we keep async interface for compatibility)
  const deviceId = getOrCreateDeviceId();
  const deviceName = getDeviceName();
  const appName = getAppName();

  return {
    deviceId,
    deviceName,
    platform: Platform.OS as 'ios' | 'android',
    appName,
    bundleId: getBundleId(),
  };
}
