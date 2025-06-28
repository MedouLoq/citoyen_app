// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Belediyti';

  @override
  String get appTagline => 'Votre voix, votre ville.';

  @override
  String get continueButton => 'Continuer vers Belediyti';

  @override
  String get termsAndConditions => 'Termes et Conditions';

  @override
  String get whatIsThisApp => 'Qu\"est-ce que cette application?';

  @override
  String get whatIsThisAppContent =>
      'Une application mobile intelligente visant à renforcer la relation entre la municipalité et le citoyen, en facilitant le signalement des problèmes locaux et le suivi de leur résolution, et en améliorant la qualité des services quotidiens, tels que la propreté, les routes, l\"eau, etc.';

  @override
  String get mainRoleOfApp => 'Rôle principal de l\"application';

  @override
  String get mainRoleOfAppContent =>
      '• Faciliter le processus de signalement des pannes et des problèmes dans les quartiers (tels que les nids-de-poule, l\"accumulation de déchets, les fuites d\"eau, les infractions de construction...)• Fournir une plateforme unifiée de communication entre les citoyens et la municipalité.\n• Envoyer des notifications et des alertes municipales telles que les campagnes de nettoyage, les travaux publics ou les alertes d\"urgence.\n• Permettre au citoyen de suivre son problème grâce à un système de suivi précis (reçu - en cours de traitement - résolu).';

  @override
  String get citizenRights => 'Droits du citoyen';

  @override
  String get citizenResponsibilities => 'Responsabilités du citoyen';

  @override
  String get citizenRightsContent =>
      '• Le droit de signaler des problèmes à tout moment et en tout lieu.\n• La possibilité de joindre des photos et une localisation géographique pour illustrer le problème.\n• Recevoir des notifications instantanées sur l\'état du signalement ou de la réclamation.\n• Soumettre des réclamations générales concernant les services ou les performances.\n• Assurer le suivi de la réclamation et fournir des commentaires supplémentaires si la résolution est retardée. ';

  @override
  String get citizenResponsibilitiesContent =>
      '• Le signalement doit être précis et honnête, sans faux signalements ou signalements malveillants.\n• Respecter la classification des problèmes selon les bonnes catégories (propreté, routes, eau...).\n• Interagir poliment et respectueusement avec les réponses de la municipalité via l\"application.\n• S\"engager à ne pas utiliser l\"application à des fins personnelles ou en dehors du cadre de l\"intérêt public.';

  @override
  String get appBenefits => 'Avantages de l\"application';

  @override
  String get appBenefitsContent =>
      '• Amélioration de la transparence du travail municipal.\n• Accélération de la réponse aux problèmes.\n• Communication rapide des informations officielles aux citoyens.\n• Implication du citoyen dans l\"amélioration de son environnement et des services qui l\"entourent.';

  @override
  String get rejectButton => 'Refuser';

  @override
  String get acceptButton => 'Accepter';

  @override
  String get authentication => 'Authentification';

  @override
  String get login => 'Se connecter';

  @override
  String get register => 'S\"inscrire';

  @override
  String get loginError => 'Erreur de connexion';

  @override
  String get correctErrors => 'Veuillez corriger les erreurs';

  @override
  String get invalidCredentials => 'Identifiant ou mot de passe incorrect';

  @override
  String connectionError(Object statusCode) {
    return 'Erreur de connexion. Code: $statusCode';
  }

  @override
  String get connectionErrorInternet =>
      'Erreur de connexion. Veuillez vérifier votre connexion Internet.';

  @override
  String get serverFormatError => 'Erreur de format de réponse du serveur';

  @override
  String get serverCommunicationError =>
      'Erreur lors de la communication avec le serveur';

  @override
  String get timeoutError =>
      'Délai d\"attente dépassé. Veuillez vérifier votre connexion.';

  @override
  String get registrationSuccess =>
      'Inscription réussie! Code de vérification envoyé.';

  @override
  String get registrationFailedCodeNotSent =>
      'Inscription réussie, mais échec de l\"envoi du code. Veuillez réessayer.';

  @override
  String get registrationError => 'Erreur d\"inscription';

  @override
  String get selectMunicipality =>
      'Veuillez sélectionner la municipalité de résidence';

  @override
  String get fullName => 'Nom complet';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get nni => 'NNI';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get municipality => 'Municipalité';

  @override
  String get emailOrPhone => 'Email ou numéro de téléphone';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get registerButton => 'S\"inscrire';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte?';

  @override
  String get dontHaveAccount => 'Vous n\"avez pas de compte?';

  @override
  String get dashboardTitle => 'Tableau de Bord';

  @override
  String get reportButton => 'Signaler';

  @override
  String get myReportedProblems => 'Mes Problèmes Signalés';

  @override
  String get refresh => 'Actualiser';

  @override
  String problemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'problèmes',
      one: 'problème',
    );
    return '$_temp0';
  }

  @override
  String get all => 'Tous';

  @override
  String get pending => 'En attente';

  @override
  String get inProgress => 'En cours';

  @override
  String get resolved => 'Résolu';

  @override
  String get rejected => 'Rejeté';

  @override
  String get unknown => 'Inconnu';

  @override
  String get unknownCategory => 'Catégorie inconnue';

  @override
  String get noDescription => 'Pas de description';

  @override
  String get unknownLocation => 'Lieu inconnu';

  @override
  String get filterByStatus => 'Filtrer par statut';

  @override
  String get close => 'Fermer';

  @override
  String get loadingProblems => 'Chargement des problèmes...';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get retry => 'Réessayer';

  @override
  String get noProblemsFound => 'Aucun problème trouvé';

  @override
  String get noProblemsFoundMessage =>
      'Vous n\"avez signalé aucun problème pour le moment.';
}
