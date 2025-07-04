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
  /// **'Toutes'**
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
  /// **'Résolues'**
  String get resolved;

  /// No description provided for @rejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejetées'**
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

  /// No description provided for @quickActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions Rapides'**
  String get quickActions;

  /// No description provided for @myReports.
  ///
  /// In fr, this message translates to:
  /// **'Mes Signalements'**
  String get myReports;

  /// No description provided for @yourStatistics.
  ///
  /// In fr, this message translates to:
  /// **'Vos Statistiques'**
  String get yourStatistics;

  /// No description provided for @problemsReported.
  ///
  /// In fr, this message translates to:
  /// **'Problèmes Signalés'**
  String get problemsReported;

  /// No description provided for @complaints.
  ///
  /// In fr, this message translates to:
  /// **'réclamations'**
  String get complaints;

  /// No description provided for @recentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité Récente'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get viewAll;

  /// No description provided for @noRecentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité récente'**
  String get noRecentActivity;

  /// No description provided for @noRecentActivityMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vos signalements et réclamations apparaîtront ici'**
  String get noRecentActivityMessage;

  /// No description provided for @newProblemReported.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau problème signalé'**
  String get newProblemReported;

  /// No description provided for @newComplaintSubmitted.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle réclamation soumise'**
  String get newComplaintSubmitted;

  /// No description provided for @noSubject.
  ///
  /// In fr, this message translates to:
  /// **'Pas de sujet'**
  String get noSubject;

  /// No description provided for @unknownActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activité inconnue'**
  String get unknownActivity;

  /// No description provided for @unknownTime.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get unknownTime;

  /// No description provided for @longTimeAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a longtemps'**
  String get longTimeAgo;

  /// No description provided for @dashboardUpdatedSuccessfully.
  ///
  /// In fr, this message translates to:
  /// **'Dashboard mis à jour avec succès'**
  String get dashboardUpdatedSuccessfully;

  /// No description provided for @errorUpdatingDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la mise à jour'**
  String get errorUpdatingDashboard;

  /// No description provided for @updating.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour...'**
  String get updating;

  /// No description provided for @daysAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} jours'**
  String daysAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} heures'**
  String hoursAgo(Object count);

  /// No description provided for @minutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} minutes'**
  String minutesAgo(Object count);

  /// No description provided for @justNow.
  ///
  /// In fr, this message translates to:
  /// **'À l\"instant'**
  String get justNow;

  /// No description provided for @buttonHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get buttonHome;

  /// No description provided for @bnjr.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour ,'**
  String get bnjr;

  /// No description provided for @buttonProb.
  ///
  /// In fr, this message translates to:
  /// **'Problèmes'**
  String get buttonProb;

  /// No description provided for @buttonComp.
  ///
  /// In fr, this message translates to:
  /// **'Réclamations'**
  String get buttonComp;

  /// No description provided for @buttonProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get buttonProfile;

  /// No description provided for @myComplaints.
  ///
  /// In fr, this message translates to:
  /// **'Mes Réclamations'**
  String get myComplaints;

  /// No description provided for @filter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer'**
  String get filter;

  /// No description provided for @reviewing.
  ///
  /// In fr, this message translates to:
  /// **'En examen'**
  String get reviewing;

  /// No description provided for @delegated.
  ///
  /// In fr, this message translates to:
  /// **'Délégué'**
  String get delegated;

  /// No description provided for @complaint.
  ///
  /// In fr, this message translates to:
  /// **'réclamation'**
  String get complaint;

  /// No description provided for @outOfTotal.
  ///
  /// In fr, this message translates to:
  /// **'sur {total} au total'**
  String outOfTotal(Object total);

  /// No description provided for @pendingStatus.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pendingStatus;

  /// No description provided for @reviewingStatus.
  ///
  /// In fr, this message translates to:
  /// **'En examen'**
  String get reviewingStatus;

  /// No description provided for @resolvedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Résolue'**
  String get resolvedStatus;

  /// No description provided for @rejectedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Rejetée'**
  String get rejectedStatus;

  /// No description provided for @inProgressStatus.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgressStatus;

  /// No description provided for @delegatedStatus.
  ///
  /// In fr, this message translates to:
  /// **'Délégué'**
  String get delegatedStatus;

  /// No description provided for @unknownStatus.
  ///
  /// In fr, this message translates to:
  /// **'Inconnu'**
  String get unknownStatus;

  /// No description provided for @dayAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} jour'**
  String dayAgo(Object count);

  /// No description provided for @hourAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} heure'**
  String hourAgo(Object count);

  /// No description provided for @minuteAgo.
  ///
  /// In fr, this message translates to:
  /// **'il y a {count} minute'**
  String minuteAgo(Object count);

  /// No description provided for @subjectNotSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Sujet non spécifié'**
  String get subjectNotSpecified;

  /// No description provided for @unknownMunicipality.
  ///
  /// In fr, this message translates to:
  /// **'Municipalité inconnue'**
  String get unknownMunicipality;

  /// No description provided for @unknownDate.
  ///
  /// In fr, this message translates to:
  /// **'Date inconnue'**
  String get unknownDate;

  /// No description provided for @imageNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Image non disponible'**
  String get imageNotAvailable;

  /// No description provided for @newComplaint.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle Réclamation'**
  String get newComplaint;

  /// No description provided for @allComplaints.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les réclamations'**
  String get allComplaints;

  /// No description provided for @pendingComplaints.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get pendingComplaints;

  /// No description provided for @inProgressComplaints.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgressComplaints;

  /// No description provided for @delegatedComplaints.
  ///
  /// In fr, this message translates to:
  /// **'Délégué'**
  String get delegatedComplaints;

  /// No description provided for @reviewingComplaints.
  ///
  /// In fr, this message translates to:
  /// **'En examen'**
  String get reviewingComplaints;

  /// No description provided for @resolvedComplaints.
  ///
  /// In fr, this message translates to:
  /// **'Résolues'**
  String get resolvedComplaints;

  /// No description provided for @rejectedComplaints.
  ///
  /// In fr, this message translates to:
  /// **'Rejetées'**
  String get rejectedComplaints;

  /// No description provided for @loadingComplaints.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des réclamations...'**
  String get loadingComplaints;

  /// No description provided for @pleaseWait.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez patienter'**
  String get pleaseWait;

  /// No description provided for @oopsError.
  ///
  /// In fr, this message translates to:
  /// **'Oups! Une erreur est survenue'**
  String get oopsError;

  /// No description provided for @pullToRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Tirez vers le bas pour actualiser'**
  String get pullToRefresh;

  /// No description provided for @noComplaints.
  ///
  /// In fr, this message translates to:
  /// **'Aucune réclamation'**
  String get noComplaints;

  /// No description provided for @noComplaintsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas encore soumis de réclamation.\nCommencez par créer votre première réclamation.'**
  String get noComplaintsMessage;

  /// No description provided for @createComplaint.
  ///
  /// In fr, this message translates to:
  /// **'Créer une réclamation'**
  String get createComplaint;

  /// No description provided for @unableToLoadComplaints.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les réclamations. Vérifiez votre connexion.'**
  String get unableToLoadComplaints;

  /// No description provided for @errorDuringRefresh.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'actualisation'**
  String get errorDuringRefresh;

  /// No description provided for @submitComplaintTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déposer une Réclamation'**
  String get submitComplaintTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre voix compte'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Aidez-nous à améliorer nos services ensemble'**
  String get welcomeSubtitle;

  /// No description provided for @municipalitySection.
  ///
  /// In fr, this message translates to:
  /// **'Municipalité Concernée'**
  String get municipalitySection;

  /// No description provided for @municipalityPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez une municipalité'**
  String get municipalityPlaceholder;

  /// No description provided for @municipalityValidation.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une municipalité'**
  String get municipalityValidation;

  /// No description provided for @subjectSection.
  ///
  /// In fr, this message translates to:
  /// **'Sujet de la Réclamation'**
  String get subjectSection;

  /// No description provided for @subjectPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Résumez votre réclamation en quelques mots'**
  String get subjectPlaceholder;

  /// No description provided for @subjectValidationRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le sujet est requis'**
  String get subjectValidationRequired;

  /// No description provided for @subjectValidationMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Le sujet doit contenir au moins 5 caractères'**
  String get subjectValidationMinLength;

  /// No description provided for @descriptionSection.
  ///
  /// In fr, this message translates to:
  /// **'Description Détaillée'**
  String get descriptionSection;

  /// No description provided for @descriptionPlaceholder.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez votre réclamation en détail...'**
  String get descriptionPlaceholder;

  /// No description provided for @descriptionValidationRequired.
  ///
  /// In fr, this message translates to:
  /// **'La description est requise'**
  String get descriptionValidationRequired;

  /// No description provided for @descriptionValidationMinLength.
  ///
  /// In fr, this message translates to:
  /// **'La description doit contenir au moins 20 caractères'**
  String get descriptionValidationMinLength;

  /// No description provided for @voiceRecordingSection.
  ///
  /// In fr, this message translates to:
  /// **'Message Vocal (Optionnel)'**
  String get voiceRecordingSection;

  /// No description provided for @voiceRecordingInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrez un message vocal pour accompagner votre réclamation'**
  String get voiceRecordingInstructions;

  /// No description provided for @voiceRecordingStart.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour enregistrer'**
  String get voiceRecordingStart;

  /// No description provided for @voiceRecordingStop.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur le bouton pour arrêter'**
  String get voiceRecordingStop;

  /// No description provided for @voiceRecordingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement...'**
  String get voiceRecordingInProgress;

  /// No description provided for @voiceRecordingStoppingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Arrêt en cours...'**
  String get voiceRecordingStoppingInProgress;

  /// No description provided for @voiceRecordingPleaseWait.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez patienter...'**
  String get voiceRecordingPleaseWait;

  /// No description provided for @voiceRecordingReady.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement prêt'**
  String get voiceRecordingReady;

  /// No description provided for @voiceRecordingPlayInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur lecture pour écouter votre enregistrement'**
  String get voiceRecordingPlayInstructions;

  /// No description provided for @attachmentsSection.
  ///
  /// In fr, this message translates to:
  /// **'Pièces Jointes'**
  String get attachmentsSection;

  /// No description provided for @photoAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Photo'**
  String get photoAttachment;

  /// No description provided for @photoSelected.
  ///
  /// In fr, this message translates to:
  /// **'Photo sélectionnée'**
  String get photoSelected;

  /// No description provided for @photoAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get photoAdd;

  /// No description provided for @videoAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get videoAttachment;

  /// No description provided for @videoSelected.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo sélectionnée'**
  String get videoSelected;

  /// No description provided for @videoAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une vidéo'**
  String get videoAdd;

  /// No description provided for @evidenceAttachment.
  ///
  /// In fr, this message translates to:
  /// **'Preuve (Requis)'**
  String get evidenceAttachment;

  /// No description provided for @evidenceAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un document'**
  String get evidenceAdd;

  /// No description provided for @submitButton.
  ///
  /// In fr, this message translates to:
  /// **'Soumettre la Réclamation'**
  String get submitButton;

  /// No description provided for @submitButtonProgress.
  ///
  /// In fr, this message translates to:
  /// **'Soumission en cours...'**
  String get submitButtonProgress;

  /// No description provided for @submitSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Réclamation soumise avec succès!'**
  String get submitSuccess;

  /// No description provided for @submitError.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la soumission de la réclamation.'**
  String get submitError;

  /// No description provided for @submitUnexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue est survenue:'**
  String get submitUnexpectedError;

  /// No description provided for @evidenceRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez joindre une preuve (document requis).'**
  String get evidenceRequired;

  /// No description provided for @recordingErrorStart.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du démarrage de l\'enregistrement:'**
  String get recordingErrorStart;

  /// No description provided for @recordingErrorStop.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'arrêt de l\'enregistrement:'**
  String get recordingErrorStop;

  /// No description provided for @recordingPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission d\'enregistrement audio refusée'**
  String get recordingPermissionDenied;

  /// No description provided for @playbackError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la lecture:'**
  String get playbackError;

  /// No description provided for @noRecordingAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun enregistrement vocal disponible.'**
  String get noRecordingAvailable;

  /// No description provided for @tevraghZeina.
  ///
  /// In fr, this message translates to:
  /// **'Tevragh-Zeina'**
  String get tevraghZeina;

  /// No description provided for @ksar.
  ///
  /// In fr, this message translates to:
  /// **'Ksar'**
  String get ksar;

  /// No description provided for @teyarett.
  ///
  /// In fr, this message translates to:
  /// **'Teyarett'**
  String get teyarett;

  /// No description provided for @toujounine.
  ///
  /// In fr, this message translates to:
  /// **'Toujounine'**
  String get toujounine;

  /// No description provided for @sebkha.
  ///
  /// In fr, this message translates to:
  /// **'Sebkha'**
  String get sebkha;

  /// No description provided for @elMina.
  ///
  /// In fr, this message translates to:
  /// **'El Mina'**
  String get elMina;

  /// No description provided for @araffat.
  ///
  /// In fr, this message translates to:
  /// **'Araffat'**
  String get araffat;

  /// No description provided for @riyadh.
  ///
  /// In fr, this message translates to:
  /// **'Riyadh'**
  String get riyadh;

  /// No description provided for @darNaim.
  ///
  /// In fr, this message translates to:
  /// **'Dar Naim'**
  String get darNaim;

  /// No description provided for @complaintDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail de la Réclamation'**
  String get complaintDetailTitle;

  /// No description provided for @loadingDetails.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des détails...'**
  String get loadingDetails;

  /// No description provided for @errorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Oups! Erreur'**
  String get errorTitle;

  /// No description provided for @backButton.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get backButton;

  /// No description provided for @goBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get goBack;

  /// No description provided for @subjectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sujet'**
  String get subjectTitle;

  /// No description provided for @descriptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get descriptionTitle;

  /// No description provided for @noDescriptionProvided.
  ///
  /// In fr, this message translates to:
  /// **'Pas de description fournie.'**
  String get noDescriptionProvided;

  /// No description provided for @municipalityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Municipalité Concernée'**
  String get municipalityTitle;

  /// No description provided for @adminCommentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire Admin'**
  String get adminCommentTitle;

  /// No description provided for @attachmentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pièces Jointes'**
  String get attachmentsTitle;

  /// No description provided for @citizenInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations du Citoyen'**
  String get citizenInfoTitle;

  /// No description provided for @videoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo à l\'appui'**
  String get videoTitle;

  /// No description provided for @videoLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement vidéo'**
  String get videoLoadingError;

  /// No description provided for @voiceRecordingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement vocal'**
  String get voiceRecordingTitle;

  /// No description provided for @audioLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement audio'**
  String get audioLoadingError;

  /// No description provided for @attachedDocumentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Document joint'**
  String get attachedDocumentTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullNameLabel;

  /// No description provided for @nniLabel.
  ///
  /// In fr, this message translates to:
  /// **'NNI'**
  String get nniLabel;

  /// No description provided for @addressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get addressLabel;

  /// No description provided for @municipalityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Municipalité'**
  String get municipalityLabel;

  /// No description provided for @linkNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Lien non disponible'**
  String get linkNotAvailable;

  /// No description provided for @cannotOpenLink.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir le lien'**
  String get cannotOpenLink;

  /// No description provided for @videoLoadingErrorMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement vidéo'**
  String get videoLoadingErrorMessage;

  /// No description provided for @audioLoadingErrorMessage.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement audio'**
  String get audioLoadingErrorMessage;

  /// No description provided for @complaintNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Réclamation non trouvée'**
  String get complaintNotFound;

  /// No description provided for @categorySelectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une catégorie'**
  String get categorySelectionTitle;

  /// No description provided for @reportCategory.
  ///
  /// In fr, this message translates to:
  /// **'Signaler: '**
  String get reportCategory;

  /// No description provided for @detailsFor.
  ///
  /// In fr, this message translates to:
  /// **'Détails pour '**
  String get detailsFor;

  /// No description provided for @categoryRoads.
  ///
  /// In fr, this message translates to:
  /// **'Routes'**
  String get categoryRoads;

  /// No description provided for @categoryWater.
  ///
  /// In fr, this message translates to:
  /// **'Eau'**
  String get categoryWater;

  /// No description provided for @categoryElectricity.
  ///
  /// In fr, this message translates to:
  /// **'Électricité'**
  String get categoryElectricity;

  /// No description provided for @categoryWaste.
  ///
  /// In fr, this message translates to:
  /// **'Déchets'**
  String get categoryWaste;

  /// No description provided for @categoryBuildingPermit.
  ///
  /// In fr, this message translates to:
  /// **'Permis de construire ou de démolir'**
  String get categoryBuildingPermit;

  /// No description provided for @categoryOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get categoryOther;

  /// No description provided for @imageNotSupported.
  ///
  /// In fr, this message translates to:
  /// **'Image non supportée'**
  String get imageNotSupported;

  /// No description provided for @errorOops.
  ///
  /// In fr, this message translates to:
  /// **'Oups! Erreur'**
  String get errorOops;

  /// No description provided for @problemDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détail du Problème'**
  String get problemDetailTitle;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @statusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statusInProgress;

  /// No description provided for @statusResolved.
  ///
  /// In fr, this message translates to:
  /// **'Résolu'**
  String get statusResolved;

  /// No description provided for @statusRejected.
  ///
  /// In fr, this message translates to:
  /// **'Rejeté'**
  String get statusRejected;

  /// No description provided for @voiceNoteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Note Vocale'**
  String get voiceNoteTitle;

  /// No description provided for @locationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get locationTitle;

  /// No description provided for @coordinatesNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Coordonnées non disponibles.'**
  String get coordinatesNotAvailable;

  /// No description provided for @documentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get documentTitle;

  /// No description provided for @videoNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo non disponible ou erreur'**
  String get videoNotAvailable;

  /// No description provided for @audioNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Audio non disponible ou erreur'**
  String get audioNotAvailable;

  /// No description provided for @pauseTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get pauseTooltip;

  /// No description provided for @playTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get playTooltip;

  /// No description provided for @expandMapTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Agrandir la carte'**
  String get expandMapTooltip;

  /// No description provided for @collapseMapTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Réduire la carte'**
  String get collapseMapTooltip;

  /// No description provided for @problemNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Problème non trouvé'**
  String get problemNotFound;

  /// No description provided for @reportProblemTitle.
  ///
  /// In fr, this message translates to:
  /// **'Signaler un Problème'**
  String get reportProblemTitle;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Les services de localisation sont désactivés'**
  String get locationServicesDisabled;

  /// No description provided for @locationServicesDisabledMessage.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez activer les services de localisation dans les paramètres de votre appareil.'**
  String get locationServicesDisabledMessage;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission de localisation refusée'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionDeniedForever.
  ///
  /// In fr, this message translates to:
  /// **'Permission de localisation définitivement refusée'**
  String get locationPermissionDeniedForever;

  /// No description provided for @permissionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Permission requise'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette application nécessite la permission de localisation pour fonctionner. Veuillez l\'activer dans les paramètres.'**
  String get permissionRequiredMessage;

  /// No description provided for @locationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de localisation: Impossible d\'obtenir la position.'**
  String get locationError;

  /// No description provided for @positionNotAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Position non disponible.'**
  String get positionNotAvailable;

  /// No description provided for @searchingMunicipality.
  ///
  /// In fr, this message translates to:
  /// **'Recherche municipalité...'**
  String get searchingMunicipality;

  /// No description provided for @municipalityNotFound.
  ///
  /// In fr, this message translates to:
  /// **'non trouvée.'**
  String get municipalityNotFound;

  /// No description provided for @cannotExtractMunicipality.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'extraire le nom de la municipalité.'**
  String get cannotExtractMunicipality;

  /// No description provided for @errorDeterminingMunicipality.
  ///
  /// In fr, this message translates to:
  /// **'Erreur détermination municipalité.'**
  String get errorDeterminingMunicipality;

  /// No description provided for @problemDescriptionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Description du problème*'**
  String get problemDescriptionTitle;

  /// No description provided for @problemDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Décrivez le problème en détail...'**
  String get problemDescriptionHint;

  /// No description provided for @pleaseProvideDescription.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez fournir une description'**
  String get pleaseProvideDescription;

  /// No description provided for @minimum10Characters.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 10 caractères'**
  String get minimum10Characters;

  /// No description provided for @stopRecording.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get stopRecording;

  /// No description provided for @voiceNote.
  ///
  /// In fr, this message translates to:
  /// **'Note Vocale'**
  String get voiceNote;

  /// No description provided for @microphonePermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission microphone refusée'**
  String get microphonePermissionDenied;

  /// No description provided for @audioRecorderNotInitialized.
  ///
  /// In fr, this message translates to:
  /// **'Enregistreur audio non initialisé'**
  String get audioRecorderNotInitialized;

  /// No description provided for @recordingFinished.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement terminé:'**
  String get recordingFinished;

  /// No description provided for @errorStopping.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'arrêt:'**
  String get errorStopping;

  /// No description provided for @recordingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement en cours...'**
  String get recordingInProgress;

  /// No description provided for @errorStarting.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du démarrage:'**
  String get errorStarting;

  /// No description provided for @problemLocationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement du problème*'**
  String get problemLocationTitle;

  /// No description provided for @problemLocationSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez choisir un emplacement'**
  String get problemLocationSubtitle;

  /// No description provided for @loadingMap.
  ///
  /// In fr, this message translates to:
  /// **'Chargement de la carte...'**
  String get loadingMap;

  /// No description provided for @centeredOnYourPosition.
  ///
  /// In fr, this message translates to:
  /// **'Centré sur votre position'**
  String get centeredOnYourPosition;

  /// No description provided for @documentsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Documents à l\'appui'**
  String get documentsTitle;

  /// No description provided for @documentsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez joindre jusqu\'à 3 documents'**
  String get documentsSubtitle;

  /// No description provided for @chooseDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Choisir des documents'**
  String get chooseDocuments;

  /// No description provided for @imagesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Images à l\'appui'**
  String get imagesTitle;

  /// No description provided for @imagesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez joindre jusqu\'à 3 images'**
  String get imagesSubtitle;

  /// No description provided for @camera.
  ///
  /// In fr, this message translates to:
  /// **'Appareil photo'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get gallery;

  /// No description provided for @videoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous pouvez joindre une seule vidéo'**
  String get videoSubtitle;

  /// No description provided for @record.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get record;

  /// No description provided for @videoLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get videoLibrary;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission caméra refusée'**
  String get cameraPermissionDenied;

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'ENVOYER'**
  String get send;

  /// No description provided for @pleaseFillRequiredFields.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez remplir les champs obligatoires.'**
  String get pleaseFillRequiredFields;

  /// No description provided for @pleaseSelectProblemLocation.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner la position du problème.'**
  String get pleaseSelectProblemLocation;

  /// No description provided for @pleaseWaitMunicipality.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez patienter (municipalité)...'**
  String get pleaseWaitMunicipality;

  /// No description provided for @municipalityNotDetermined.
  ///
  /// In fr, this message translates to:
  /// **'Municipalité non déterminée. Soumission impossible.'**
  String get municipalityNotDetermined;

  /// No description provided for @authTokenMissing.
  ///
  /// In fr, this message translates to:
  /// **'Erreur: Token d\'authentification manquant.'**
  String get authTokenMissing;

  /// No description provided for @problemReportedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Problème signalé avec succès!'**
  String get problemReportedSuccess;

  /// No description provided for @submissionFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec:'**
  String get submissionFailed;

  /// No description provided for @networkSystemError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau/système:'**
  String get networkSystemError;

  /// No description provided for @maxImagesReached.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez joindre que 3 images maximum.'**
  String get maxImagesReached;

  /// No description provided for @imageSelectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur sélection d\'image:'**
  String get imageSelectionError;

  /// No description provided for @videoSelectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur sélection/enregistrement vidéo:'**
  String get videoSelectionError;

  /// No description provided for @documentSelectionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur sélection de document:'**
  String get documentSelectionError;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settings;

  /// No description provided for @lat.
  ///
  /// In fr, this message translates to:
  /// **'Lat'**
  String get lat;

  /// No description provided for @lon.
  ///
  /// In fr, this message translates to:
  /// **'Lon'**
  String get lon;

  /// No description provided for @problemPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Problème: '**
  String get problemPrefix;

  /// No description provided for @complaintPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Réclamation: '**
  String get complaintPrefix;

  /// No description provided for @videoLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement vidéo'**
  String get videoLoadError;

  /// No description provided for @audioLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur chargement audio'**
  String get audioLoadError;

  /// No description provided for @expandMap.
  ///
  /// In fr, this message translates to:
  /// **'Agrandir la carte'**
  String get expandMap;

  /// No description provided for @collapseMap.
  ///
  /// In fr, this message translates to:
  /// **'Réduire la carte'**
  String get collapseMap;

  /// No description provided for @backTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get backTooltip;

  /// No description provided for @sectionDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get sectionDescription;

  /// No description provided for @sectionVoiceNote.
  ///
  /// In fr, this message translates to:
  /// **'Note Vocale'**
  String get sectionVoiceNote;

  /// No description provided for @sectionLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get sectionLocation;

  /// No description provided for @sectionVideo.
  ///
  /// In fr, this message translates to:
  /// **'Vidéo'**
  String get sectionVideo;

  /// No description provided for @sectionDocument.
  ///
  /// In fr, this message translates to:
  /// **'Document'**
  String get sectionDocument;

  /// No description provided for @sectionAdminComment.
  ///
  /// In fr, this message translates to:
  /// **'Commentaire Admin'**
  String get sectionAdminComment;

  /// No description provided for @reduceMap.
  ///
  /// In fr, this message translates to:
  /// **'Réduire la carte'**
  String get reduceMap;

  /// No description provided for @enlargeMap.
  ///
  /// In fr, this message translates to:
  /// **'Agrandir la carte'**
  String get enlargeMap;

  /// No description provided for @myProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon Profil'**
  String get myProfile;

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le Profil'**
  String get editProfile;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder'**
  String get save;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @noProfileDataFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune donnée de profil trouvée.'**
  String get noProfileDataFound;

  /// No description provided for @personalInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations Personnelles'**
  String get personalInformation;

  /// No description provided for @address.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get phone;

  /// No description provided for @notDefined.
  ///
  /// In fr, this message translates to:
  /// **'Non défini'**
  String get notDefined;

  /// No description provided for @user.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get user;

  /// No description provided for @removePicture.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get removePicture;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour avec succès !'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @updateFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la mise à jour'**
  String get updateFailed;

  /// No description provided for @anErrorOccurred.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite'**
  String get anErrorOccurred;

  /// No description provided for @fullNameCannotBeEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Le nom ne peut pas être vide'**
  String get fullNameCannotBeEmpty;

  /// No description provided for @authTokenNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Token d\'authentification non trouvé. Veuillez vous reconnecter.'**
  String get authTokenNotFound;

  /// No description provided for @authTokenNotFoundShort.
  ///
  /// In fr, this message translates to:
  /// **'Token d\'authentification non trouvé.'**
  String get authTokenNotFoundShort;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In fr, this message translates to:
  /// **'Échec du chargement du profil'**
  String get failedToLoadProfile;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la mise à jour du profil'**
  String get failedToUpdateProfile;

  /// No description provided for @failedToPickImage.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la sélection de l\'image'**
  String get failedToPickImage;

  /// No description provided for @anErrorOccurredDuringUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur s\'est produite lors de la mise à jour'**
  String get anErrorOccurredDuringUpdate;

  /// No description provided for @aboutUs.
  ///
  /// In fr, this message translates to:
  /// **'À propos de nous'**
  String get aboutUs;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get logout;

  /// No description provided for @contactUs.
  ///
  /// In fr, this message translates to:
  /// **'Nous Contacter'**
  String get contactUs;

  /// No description provided for @weAreHereToHelp.
  ///
  /// In fr, this message translates to:
  /// **'Nous sommes là pour vous aider !'**
  String get weAreHereToHelp;

  /// No description provided for @arafatPhoneNumber.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone d\'Arafat'**
  String get arafatPhoneNumber;

  /// No description provided for @cannotLaunch.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de lancer'**
  String get cannotLaunch;
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
