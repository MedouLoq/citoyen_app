// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Citoyen App';

  @override
  String get appName => 'Belediyti';

  @override
  String get appTagline => 'Your voice, your city.';

  @override
  String get continueButton => 'Continue to Belediyti';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get reject => 'Reject';

  @override
  String get acceptAndContinue => 'Accept and Continue';

  @override
  String get whatIsThisAppTitle => 'What is this application?';

  @override
  String get whatIsThisAppContent =>
      'An intelligent mobile application aiming to strengthen the relationship between the municipality and the citizen, by facilitating the reporting of local problems and monitoring their resolution, and by improving the quality of daily services, such as cleanliness, roads, water, etc.';

  @override
  String get mainRoleTitle => 'Main role of the application';

  @override
  String get mainRoleContent =>
      '• Facilitate the process of reporting breakdowns and problems in neighborhoods (such as potholes, waste accumulation, water leaks, construction violations...)\n• Provide a unified communication platform between citizens and the municipality.\n• Send municipal notifications and alerts such as cleaning campaigns, public works or emergency alerts.\n• Allow citizens to track their problem through a precise tracking system (received - in progress - resolved).';

  @override
  String get citizenRightsTitle => 'Citizen\'s Rights';

  @override
  String get citizenRightsContent =>
      '• The right to report problems at any time and from anywhere.\n• The possibility of attaching photos and a GPS location to clarify the problem.\n• Receive instant notifications on the status of the report or complaint.\n• Submit general complaints regarding services or performance.\n• Track the complaint and provide additional feedback in case of delay in resolution.';

  @override
  String get citizenResponsibilitiesTitle => 'Citizen\'s Responsibilities';

  @override
  String get citizenResponsibilitiesContent =>
      '• Reporting must be accurate and honest, without false or malicious reports.\n• Respect the classification of problems according to the correct categories (cleanliness, roads, water...).\n• Interact politely and respectfully with municipal responses via the application.\n• Commit not to use the application for personal purposes or outside the scope of public interest.';

  @override
  String get appBenefitsTitle => 'Benefits of the application';

  @override
  String get appBenefitsContent =>
      '• Improvement of municipal work transparency.\n• Acceleration of problem response.\n• Rapid communication of official information to citizens.\n• Citizen involvement in improving their environment and surrounding services.';
}
