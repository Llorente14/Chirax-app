import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/services/biometric_service.dart';

/// SecurityController - Manages app lock state and biometric authentication
/// Implements WidgetsBindingObserver to detect app lifecycle changes
class SecurityController extends GetxController with WidgetsBindingObserver {
  final _storage = GetStorage();

  // Key for persistent storage
  static const String _securityEnabledKey = 'security_enabled';
  static const String _autoUnlockKey = 'auto_unlock_enabled';

  // State: Is security feature enabled?
  late RxBool isEnabled;
  late RxBool isAutoUnlockEnabled;

  // Available biometrics
  final RxList<BiometricType> availableBiometrics = <BiometricType>[].obs;

  // State: Is app currently locked?
  late RxBool isLocked;

  // Flag to prevent multiple auth dialogs
  bool _isAuthenticating = false;

  @override
  void onInit() {
    super.onInit();

    // Load saved preference (default: false)
    final savedEnabled = _storage.read<bool>(_securityEnabledKey) ?? false;
    isEnabled = savedEnabled.obs;

    // Load auto unlock preference (default: true)
    final savedAutoUnlock = _storage.read<bool>(_autoUnlockKey) ?? true;
    isAutoUnlockEnabled = savedAutoUnlock.obs;

    // Check biometrics
    _checkBiometrics();

    // Initially locked if security is enabled
    isLocked = savedEnabled.obs;

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Auto-authenticate on first launch if enabled AND auto unlock allowed
    if (isEnabled.value && isLocked.value && isAutoUnlockEnabled.value) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        // Check if biometric is available first
        final isSupported = await BiometricService.isDeviceSupported();
        if (!isSupported) {
          // Device doesn't support biometric - auto unlock
          isLocked.value = false;
          return;
        }
        authenticateUser();
      });
    }
  }

  @override
  void onClose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!isEnabled.value) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // User left the app - lock it
        isLocked.value = true;
        break;

      case AppLifecycleState.resumed:
        // User came back - authenticate
        if (isLocked.value && isAutoUnlockEnabled.value) {
          authenticateUser();
        }
        break;

      case AppLifecycleState.detached:
        // App is being terminated
        break;
    }
  }

  /// Toggle security on/off
  /// Requires biometric verification before making changes
  Future<bool> toggleSecurity(bool newValue) async {
    // First verify the user's identity
    final verified = await BiometricService.authenticate();

    if (!verified) {
      // User failed to verify - don't change setting
      return false;
    }

    // Verified! Update the setting
    isEnabled.value = newValue;
    await _storage.write(_securityEnabledKey, newValue);

    // If enabling, set locked state
    if (newValue) {
      isLocked.value = false; // Already verified, so unlock
    } else {
      isLocked.value = false;
    }

    return true;
  }

  /// Authenticate user with biometrics
  /// Called when app is resumed or when user taps unlock button
  Future<void> authenticateUser() async {
    // Prevent multiple auth dialogs
    if (_isAuthenticating) return;
    _isAuthenticating = true;

    try {
      final success = await BiometricService.authenticate();

      if (success) {
        isLocked.value = false;
      }
    } finally {
      _isAuthenticating = false;
    }
  }

  /// Check available biometrics
  Future<void> _checkBiometrics() async {
    final bios = await BiometricService.getAvailableBiometrics();
    availableBiometrics.value = bios;
  }

  /// Toggle auto unlock
  void toggleAutoUnlock(bool val) {
    isAutoUnlockEnabled.value = val;
    _storage.write(_autoUnlockKey, val);
  }

  /// Check if biometrics is available on this device
  Future<bool> isDeviceSupported() async {
    return await BiometricService.isDeviceSupported();
  }
}
