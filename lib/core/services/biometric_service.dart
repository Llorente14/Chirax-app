import 'package:local_auth/local_auth.dart';

/// BiometricService - Wrapper untuk local_auth package
/// Handles biometric authentication (Face ID / Fingerprint)
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometric authentication
  static Future<bool> isDeviceSupported() async {
    try {
      // Check if device has biometric hardware
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();

      return canCheck && isSupported;
    } catch (e) {
      // Device doesn't support biometrics
      return false;
    }
  }

  /// Get available biometrics types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate with biometric
  /// Returns true if successful, false otherwise
  static Future<bool> authenticate() async {
    try {
      // Check if biometrics is available first
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      final result = await _auth.authenticate(
        localizedReason: 'Verifikasi identitas untuk membuka aplikasi',
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep auth dialog even if app goes to background
          biometricOnly: true, // Only allow biometrics, not PIN/password
          useErrorDialogs: true, // Show system error dialogs
        ),
      );

      return result;
    } catch (e) {
      // Authentication failed or was cancelled
      return false;
    }
  }
}
