import 'package:flutter/services.dart';
import 'package:foap/helper/imports/common_import.dart';
import 'package:local_auth/local_auth.dart';
import 'shared_prefs.dart';

enum BiometricState { ready, notSupported, notEnrolled }

/// Single place for all fingerprint / face unlock logic.
class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// 1 = face, 2 = fingerprint, 3 = other (iris / device credential), 0 = none
  static Future<int> type() async {
    try {
      if (!await _auth.isDeviceSupported()) return 0;
      final list = await _auth.getAvailableBiometrics();
      if (list.contains(BiometricType.face)) return 1;
      if (list.contains(BiometricType.fingerprint)) return 2;
      if (list.isNotEmpty) return 3;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<BiometricState> state() async {
    try {
      if (!await _auth.isDeviceSupported()) return BiometricState.notSupported;
      final list = await _auth.getAvailableBiometrics();
      return list.isEmpty ? BiometricState.notEnrolled : BiometricState.ready;
    } catch (_) {
      return BiometricState.notSupported;
    }
  }

  static Future<bool> isEnabled() => SharedPrefs().getBioMetricAuthStatus();

  /// Shows the system prompt. Returns true only on real success.
  /// Shows a toast for the common failure reasons so the user knows why.
  static Future<bool> authenticate(String reason,
      {bool showErrors = true}) async {
    try {
      final ok = await _auth.authenticate(localizedReason: reason);
      return ok == true;
    } on PlatformException catch (e) {
      if (showErrors) {
        final code = e.code.toLowerCase();
        String msg = 'Authentication failed. Please try again.';
        if (code.contains('notenrolled')) {
          msg = 'No fingerprint / face is set up on this phone. Add one in phone Settings first.';
        } else if (code.contains('notavailable')) {
          msg = 'Biometric is not available on this device right now.';
        } else if (code.contains('lockedout')) {
          msg = 'Too many attempts. Biometric is locked, try again later or use your phone PIN.';
        } else if (code.contains('passcode')) {
          msg = 'Please set a screen lock on your phone first.';
        }
        AppUtil.showToast(message: msg, isSuccess: false);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Use before sensitive actions (withdraw, change password...).
  /// Returns true when biometric lock is off, or when the user passed it.
  static Future<bool> confirmIfEnabled(String reason) async {
    if (!await isEnabled()) return true;
    if (await state() != BiometricState.ready) return true;
    return authenticate(reason);
  }
}
