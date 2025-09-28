// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PlusOne';

  @override
  String get signin_title => 'Bienvenido a PlusOne';

  @override
  String get field_email => 'Correo electrónico';

  @override
  String get field_password => 'Contraseña';

  @override
  String get btn_signin => 'Iniciar sesión';

  @override
  String get btn_create_account => '¿No tienes cuenta? ¡Regístrate aquí!';

  @override
  String get btn_forgot_password => '¿Olvidaste tu contraseña?';

  @override
  String get msg_enter_email => 'Por favor ingresa tu correo.';

  @override
  String get msg_enter_password => 'Por favor ingresa tu contraseña.';

  @override
  String get msg_reset_sent => 'Si este correo existe, te enviamos un enlace para restablecer.';

  @override
  String get err_auth_generic => 'No fue posible iniciar sesión. Intenta de nuevo.';

  @override
  String get err_auth_invalid_email => 'Correo inválido.';

  @override
  String get err_auth_wrong_credentials => 'Correo o contraseña incorrectos.';

  @override
  String get err_auth_too_many_requests => 'Demasiados intentos. Intenta más tarde.';
}
