// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PlusOne';

  @override
  String get signin_title => 'Welcome to PlusOne';

  @override
  String get field_email => 'Email';

  @override
  String get field_password => 'Password';

  @override
  String get btn_signin => 'Sign in';

  @override
  String get btn_create_account => 'Don\'t have an account? Sign up!';

  @override
  String get btn_forgot_password => 'Forgot your password?';

  @override
  String get msg_enter_email => 'Please enter your email.';

  @override
  String get msg_enter_password => 'Please enter your password.';

  @override
  String get msg_reset_sent => 'If this email exists, we sent a reset link.';

  @override
  String get err_auth_generic => 'Could not sign in. Please try again.';

  @override
  String get err_auth_invalid_email => 'Invalid email address.';

  @override
  String get err_auth_wrong_credentials => 'Incorrect email or password.';

  @override
  String get err_auth_too_many_requests => 'Too many attempts. Try again later.';
}
