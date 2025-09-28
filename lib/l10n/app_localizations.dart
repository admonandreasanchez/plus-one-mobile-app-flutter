import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PlusOne'**
  String get appTitle;

  /// No description provided for @signin_title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PlusOne'**
  String get signin_title;

  /// No description provided for @field_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get field_email;

  /// No description provided for @field_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get field_password;

  /// No description provided for @btn_signin.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get btn_signin;

  /// No description provided for @btn_create_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up!'**
  String get btn_create_account;

  /// No description provided for @btn_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get btn_forgot_password;

  /// No description provided for @msg_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get msg_enter_email;

  /// No description provided for @msg_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get msg_enter_password;

  /// No description provided for @msg_reset_sent.
  ///
  /// In en, this message translates to:
  /// **'If this email exists, we sent a reset link.'**
  String get msg_reset_sent;

  /// No description provided for @err_auth_generic.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Please try again.'**
  String get err_auth_generic;

  /// No description provided for @err_auth_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get err_auth_invalid_email;

  /// No description provided for @err_auth_wrong_credentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get err_auth_wrong_credentials;

  /// No description provided for @err_auth_too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get err_auth_too_many_requests;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
