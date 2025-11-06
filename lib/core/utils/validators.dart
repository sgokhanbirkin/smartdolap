import 'package:easy_localization/easy_localization.dart';

/// Validators utility class
class Validators {
  Validators._();

  /// Check if email is valid
  static bool isValidEmail(String email) => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(email);

  /// Check if password is valid (min 6 characters)
  static bool isValidPassword(String password) => password.length >= 6;

  /// Email validator for FormField (returns error string or null)
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr('invalid_email');
    }
    if (!isValidEmail(value.trim())) {
      return tr('invalid_email');
    }
    return null;
  }

  /// Password validator for FormField (min 6 chars)
  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return tr('short_password');
    }
    if (!isValidPassword(value)) {
      return tr('short_password');
    }
    return null;
  }
}
