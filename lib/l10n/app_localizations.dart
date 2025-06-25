import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Citoyen App'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Belediyti'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your voice, your city.'**
  String get appTagline;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to Belediyti'**
  String get continueButton;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @acceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Accept and Continue'**
  String get acceptAndContinue;

  /// No description provided for @whatIsThisAppTitle.
  ///
  /// In en, this message translates to:
  /// **'What is this application?'**
  String get whatIsThisAppTitle;

  /// No description provided for @whatIsThisAppContent.
  ///
  /// In en, this message translates to:
  /// **'An intelligent mobile application aiming to strengthen the relationship between the municipality and the citizen, by facilitating the reporting of local problems and monitoring their resolution, and by improving the quality of daily services, such as cleanliness, roads, water, etc.'**
  String get whatIsThisAppContent;

  /// No description provided for @mainRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Main role of the application'**
  String get mainRoleTitle;

  /// No description provided for @mainRoleContent.
  ///
  /// In en, this message translates to:
  /// **'• Facilitate the process of reporting breakdowns and problems in neighborhoods (such as potholes, waste accumulation, water leaks, construction violations...)\n• Provide a unified communication platform between citizens and the municipality.\n• Send municipal notifications and alerts such as cleaning campaigns, public works or emergency alerts.\n• Allow citizens to track their problem through a precise tracking system (received - in progress - resolved).'**
  String get mainRoleContent;

  /// No description provided for @citizenRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Citizen\'s Rights'**
  String get citizenRightsTitle;

  /// No description provided for @citizenRightsContent.
  ///
  /// In en, this message translates to:
  /// **'• The right to report problems at any time and from anywhere.\n• The possibility of attaching photos and a GPS location to clarify the problem.\n• Receive instant notifications on the status of the report or complaint.\n• Submit general complaints regarding services or performance.\n• Track the complaint and provide additional feedback in case of delay in resolution.'**
  String get citizenRightsContent;

  /// No description provided for @citizenResponsibilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Citizen\'s Responsibilities'**
  String get citizenResponsibilitiesTitle;

  /// No description provided for @citizenResponsibilitiesContent.
  ///
  /// In en, this message translates to:
  /// **'• Reporting must be accurate and honest, without false or malicious reports.\n• Respect the classification of problems according to the correct categories (cleanliness, roads, water...).\n• Interact politely and respectfully with municipal responses via the application.\n• Commit not to use the application for personal purposes or outside the scope of public interest.'**
  String get citizenResponsibilitiesContent;

  /// No description provided for @appBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Benefits of the application'**
  String get appBenefitsTitle;

  /// No description provided for @appBenefitsContent.
  ///
  /// In en, this message translates to:
  /// **'• Improvement of municipal work transparency.\n• Acceleration of problem response.\n• Rapid communication of official information to citizens.\n• Citizen involvement in improving their environment and surrounding services.'**
  String get appBenefitsContent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
