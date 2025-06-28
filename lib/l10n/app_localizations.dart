import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In fr, this message translates to:
  /// **'Belediyti'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre voix, votre ville.'**
  String get appTagline;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer vers Belediyti'**
  String get continueButton;

  /// No description provided for @termsAndConditions.
  ///
  /// In fr, this message translates to:
  /// **'Termes et Conditions'**
  String get termsAndConditions;

  /// No description provided for @whatIsThisApp.
  ///
  /// In fr, this message translates to:
  /// **'Qu\"est-ce que cette application?'**
  String get whatIsThisApp;

  /// No description provided for @whatIsThisAppContent.
  ///
  /// In fr, this message translates to:
  /// **'Une application mobile intelligente visant à renforcer la relation entre la municipalité et le citoyen, en facilitant le signalement des problèmes locaux et le suivi de leur résolution, et en améliorant la qualité des services quotidiens, tels que la propreté, les routes, l\"eau, etc.'**
  String get whatIsThisAppContent;

  /// No description provided for @mainRoleOfApp.
  ///
  /// In fr, this message translates to:
  /// **'Rôle principal de l\"application'**
  String get mainRoleOfApp;

  /// No description provided for @mainRoleOfAppContent.
  ///
  /// In fr, this message translates to:
  /// **'• Faciliter le processus de signalement des pannes et des problèmes dans les quartiers (tels que les nids-de-poule, l\"accumulation de déchets, les fuites d\"eau, les infractions de construction...)• Fournir une plateforme unifiée de communication entre les citoyens et la municipalité.\n• Envoyer des notifications et des alertes municipales telles que les campagnes de nettoyage, les travaux publics ou les alertes d\"urgence.\n• Permettre au citoyen de suivre son problème grâce à un système de suivi précis (reçu - en cours de traitement - résolu).'**
  String get mainRoleOfAppContent;

  /// No description provided for @citizenRights.
  ///
  /// In fr, this message translates to:
  /// **'Droits du citoyen'**
  String get citizenRights;

  /// No description provided for @citizenResponsibilities.
  ///
  /// In fr, this message translates to:
  /// **'Responsabilités du citoyen'**
  String get citizenResponsibilities;

  /// No description provided for @citizenRightsContent.
  ///
  /// In fr, this message translates to:
  /// **'• Le droit de signaler des problèmes à tout moment et en tout lieu.\n• La possibilité de joindre des photos et une localisation géographique pour illustrer le problème.\n• Recevoir des notifications instantanées sur l\'état du signalement ou de la réclamation.\n• Soumettre des réclamations générales concernant les services ou les performances.\n• Assurer le suivi de la réclamation et fournir des commentaires supplémentaires si la résolution est retardée. '**
  String get citizenRightsContent;

  /// No description provided for @citizenResponsibilitiesContent.
  ///
  /// In fr, this message translates to:
  /// **'• Le signalement doit être précis et honnête, sans faux signalements ou signalements malveillants.\n• Respecter la classification des problèmes selon les bonnes catégories (propreté, routes, eau...).\n• Interagir poliment et respectueusement avec les réponses de la municipalité via l\"application.\n• S\"engager à ne pas utiliser l\"application à des fins personnelles ou en dehors du cadre de l\"intérêt public.'**
  String get citizenResponsibilitiesContent;

  /// No description provided for @appBenefits.
  ///
  /// In fr, this message translates to:
  /// **'Avantages de l\"application'**
  String get appBenefits;

  /// No description provided for @appBenefitsContent.
  ///
  /// In fr, this message translates to:
  /// **'• Amélioration de la transparence du travail municipal.\n• Accélération de la réponse aux problèmes.\n• Communication rapide des informations officielles aux citoyens.\n• Implication du citoyen dans l\"amélioration de son environnement et des services qui l\"entourent.'**
  String get appBenefitsContent;

  /// No description provided for @rejectButton.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get rejectButton;

  /// No description provided for @acceptButton.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get acceptButton;

  /// No description provided for @authentication.
  ///
  /// In fr, this message translates to:
  /// **'Authentification'**
  String get authentication;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'S\"inscrire'**
  String get register;

  /// No description provided for @loginError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion'**
  String get loginError;

  /// No description provided for @correctErrors.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez corriger les erreurs'**
  String get correctErrors;

  /// No description provided for @invalidCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Identifiant ou mot de passe incorrect'**
  String get invalidCredentials;

  /// No description provided for @connectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion. Code: {statusCode}'**
  String connectionError(Object statusCode);

  /// No description provided for @connectionErrorInternet.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion. Veuillez vérifier votre connexion Internet.'**
  String get connectionErrorInternet;

  /// No description provided for @serverFormatError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de format de réponse du serveur'**
  String get serverFormatError;

  /// No description provided for @serverCommunicationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la communication avec le serveur'**
  String get serverCommunicationError;

  /// No description provided for @timeoutError.
  ///
  /// In fr, this message translates to:
  /// **'Délai d\"attente dépassé. Veuillez vérifier votre connexion.'**
  String get timeoutError;

  /// No description provided for @registrationSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie! Code de vérification envoyé.'**
  String get registrationSuccess;

  /// No description provided for @registrationFailedCodeNotSent.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie, mais échec de l\"envoi du code. Veuillez réessayer.'**
  String get registrationFailedCodeNotSent;

  /// No description provided for @registrationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\"inscription'**
  String get registrationError;

  /// No description provided for @selectMunicipality.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner la municipalité de résidence'**
  String get selectMunicipality;

  /// No description provided for @fullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phoneNumber;

  /// No description provided for @nni.
  ///
  /// In fr, this message translates to:
  /// **'NNI'**
  String get nni;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @municipality.
  ///
  /// In fr, this message translates to:
  /// **'Municipalité'**
  String get municipality;

  /// No description provided for @emailOrPhone.
  ///
  /// In fr, this message translates to:
  /// **'Email ou numéro de téléphone'**
  String get emailOrPhone;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In fr, this message translates to:
  /// **'S\"inscrire'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez déjà un compte?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\"avez pas de compte?'**
  String get dontHaveAccount;

  /// No description provided for @dashboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de Bord'**
  String get dashboardTitle;

  /// No description provided for @reportButton.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get reportButton;

  /// No description provided for @myReportedProblems.
  ///
  /// In fr, this message translates to:
  /// **'Mes Problèmes Signalés'**
  String get myReportedProblems;

  /// No description provided for @refresh.
  ///
  /// In fr, this message translates to:
  /// **'Actualiser'**
  String get refresh;

  /// No description provided for @problemsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{problème} other{problèmes}}'**
  String problemsCount(num count);

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all;

  /// No description provided for @pending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pending;

  /// No description provided for @inProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgress;

  /// No description provided for @resolved.
  ///
  /// In fr, this message translates to:
  /// **'Résolu'**
  String get resolved;

  /// No description provided for @rejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get rejected;

  /// No description provided for @unknown.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get unknown;

  /// No description provided for @unknownCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie inconnue'**
  String get unknownCategory;

  /// No description provided for @noDescription.
  ///
  /// In fr, this message translates to:
  /// **'Pas de description'**
  String get noDescription;

  /// No description provided for @unknownLocation.
  ///
  /// In fr, this message translates to:
  /// **'Lieu inconnu'**
  String get unknownLocation;

  /// No description provided for @filterByStatus.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par statut'**
  String get filterByStatus;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @loadingProblems.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des problèmes...'**
  String get loadingProblems;

  /// No description provided for @loadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get loadingError;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @noProblemsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun problème trouvé'**
  String get noProblemsFound;

  /// No description provided for @noProblemsFoundMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\"avez signalé aucun problème pour le moment.'**
  String get noProblemsFoundMessage;
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
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
