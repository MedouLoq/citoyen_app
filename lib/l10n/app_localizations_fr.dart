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
  String get all => 'Toutes';

  @override
  String get pending => 'En attente';

  @override
  String get inProgress => 'En cours';

  @override
  String get resolved => 'Résolues';

  @override
  String get rejected => 'Rejetées';

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

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get myReports => 'Mes Signalements';

  @override
  String get yourStatistics => 'Vos Statistiques';

  @override
  String get problemsReported => 'Problèmes Signalés';

  @override
  String get complaints => 'réclamations';

  @override
  String get recentActivity => 'Activité Récente';

  @override
  String get viewAll => 'Tout voir';

  @override
  String get noRecentActivity => 'Aucune activité récente';

  @override
  String get noRecentActivityMessage =>
      'Vos signalements et réclamations apparaîtront ici';

  @override
  String get newProblemReported => 'Nouveau problème signalé';

  @override
  String get newComplaintSubmitted => 'Nouvelle réclamation soumise';

  @override
  String get noSubject => 'Pas de sujet';

  @override
  String get unknownActivity => 'Activité inconnue';

  @override
  String get unknownTime => 'Inconnu';

  @override
  String get longTimeAgo => 'Il y a longtemps';

  @override
  String get dashboardUpdatedSuccessfully => 'Dashboard mis à jour avec succès';

  @override
  String get errorUpdatingDashboard => 'Erreur lors de la mise à jour';

  @override
  String get updating => 'Mise à jour...';

  @override
  String daysAgo(Object count) {
    return 'il y a $count jours';
  }

  @override
  String hoursAgo(Object count) {
    return 'il y a $count heures';
  }

  @override
  String minutesAgo(Object count) {
    return 'il y a $count minutes';
  }

  @override
  String get justNow => 'À l\"instant';

  @override
  String get buttonHome => 'Accueil';

  @override
  String get bnjr => 'Bonjour ,';

  @override
  String get buttonProb => 'Problèmes';

  @override
  String get buttonComp => 'Réclamations';

  @override
  String get buttonProfile => 'Profil';

  @override
  String get myComplaints => 'Mes Réclamations';

  @override
  String get filter => 'Filtrer';

  @override
  String get reviewing => 'En examen';

  @override
  String get delegated => 'Délégué';

  @override
  String get complaint => 'réclamation';

  @override
  String outOfTotal(Object total) {
    return 'sur $total au total';
  }

  @override
  String get pendingStatus => 'En attente';

  @override
  String get reviewingStatus => 'En examen';

  @override
  String get resolvedStatus => 'Résolue';

  @override
  String get rejectedStatus => 'Rejetée';

  @override
  String get inProgressStatus => 'En cours';

  @override
  String get delegatedStatus => 'Délégué';

  @override
  String get unknownStatus => 'Inconnu';

  @override
  String dayAgo(Object count) {
    return 'il y a $count jour';
  }

  @override
  String hourAgo(Object count) {
    return 'il y a $count heure';
  }

  @override
  String minuteAgo(Object count) {
    return 'il y a $count minute';
  }

  @override
  String get subjectNotSpecified => 'Sujet non spécifié';

  @override
  String get unknownMunicipality => 'Municipalité inconnue';

  @override
  String get unknownDate => 'Date inconnue';

  @override
  String get imageNotAvailable => 'Image non disponible';

  @override
  String get newComplaint => 'Nouvelle Réclamation';

  @override
  String get allComplaints => 'Toutes les réclamations';

  @override
  String get pendingComplaints => 'En attente';

  @override
  String get inProgressComplaints => 'En cours';

  @override
  String get delegatedComplaints => 'Délégué';

  @override
  String get reviewingComplaints => 'En examen';

  @override
  String get resolvedComplaints => 'Résolues';

  @override
  String get rejectedComplaints => 'Rejetées';

  @override
  String get loadingComplaints => 'Chargement des réclamations...';

  @override
  String get pleaseWait => 'Veuillez patienter';

  @override
  String get oopsError => 'Oups! Une erreur est survenue';

  @override
  String get pullToRefresh => 'Tirez vers le bas pour actualiser';

  @override
  String get noComplaints => 'Aucune réclamation';

  @override
  String get noComplaintsMessage =>
      'Vous n\'avez pas encore soumis de réclamation.\nCommencez par créer votre première réclamation.';

  @override
  String get createComplaint => 'Créer une réclamation';

  @override
  String get unableToLoadComplaints =>
      'Impossible de charger les réclamations. Vérifiez votre connexion.';

  @override
  String get errorDuringRefresh => 'Erreur lors de l\'actualisation';

  @override
  String get submitComplaintTitle => 'Déposer une Réclamation';

  @override
  String get welcomeTitle => 'Votre voix compte';

  @override
  String get welcomeSubtitle => 'Aidez-nous à améliorer nos services ensemble';

  @override
  String get municipalitySection => 'Municipalité Concernée';

  @override
  String get municipalityPlaceholder => 'Sélectionnez une municipalité';

  @override
  String get municipalityValidation => 'Veuillez sélectionner une municipalité';

  @override
  String get subjectSection => 'Sujet de la Réclamation';

  @override
  String get subjectPlaceholder => 'Résumez votre réclamation en quelques mots';

  @override
  String get subjectValidationRequired => 'Le sujet est requis';

  @override
  String get subjectValidationMinLength =>
      'Le sujet doit contenir au moins 5 caractères';

  @override
  String get descriptionSection => 'Description Détaillée';

  @override
  String get descriptionPlaceholder =>
      'Décrivez votre réclamation en détail...';

  @override
  String get descriptionValidationRequired => 'La description est requise';

  @override
  String get descriptionValidationMinLength =>
      'La description doit contenir au moins 20 caractères';

  @override
  String get voiceRecordingSection => 'Message Vocal (Optionnel)';

  @override
  String get voiceRecordingInstructions =>
      'Enregistrez un message vocal pour accompagner votre réclamation';

  @override
  String get voiceRecordingStart => 'Appuyez pour enregistrer';

  @override
  String get voiceRecordingStop => 'Appuyez sur le bouton pour arrêter';

  @override
  String get voiceRecordingInProgress => 'Enregistrement...';

  @override
  String get voiceRecordingStoppingInProgress => 'Arrêt en cours...';

  @override
  String get voiceRecordingPleaseWait => 'Veuillez patienter...';

  @override
  String get voiceRecordingReady => 'Enregistrement prêt';

  @override
  String get voiceRecordingPlayInstructions =>
      'Appuyez sur lecture pour écouter votre enregistrement';

  @override
  String get attachmentsSection => 'Pièces Jointes';

  @override
  String get photoAttachment => 'Photo';

  @override
  String get photoSelected => 'Photo sélectionnée';

  @override
  String get photoAdd => 'Ajouter une photo';

  @override
  String get videoAttachment => 'Vidéo';

  @override
  String get videoSelected => 'Vidéo sélectionnée';

  @override
  String get videoAdd => 'Ajouter une vidéo';

  @override
  String get evidenceAttachment => 'Preuve (Requis)';

  @override
  String get evidenceAdd => 'Ajouter un document';

  @override
  String get submitButton => 'Soumettre la Réclamation';

  @override
  String get submitButtonProgress => 'Soumission en cours...';

  @override
  String get submitSuccess => 'Réclamation soumise avec succès!';

  @override
  String get submitError => 'Échec de la soumission de la réclamation.';

  @override
  String get submitUnexpectedError => 'Une erreur inattendue est survenue:';

  @override
  String get evidenceRequired =>
      'Veuillez joindre une preuve (document requis).';

  @override
  String get recordingErrorStart =>
      'Erreur lors du démarrage de l\'enregistrement:';

  @override
  String get recordingErrorStop =>
      'Erreur lors de l\'arrêt de l\'enregistrement:';

  @override
  String get recordingPermissionDenied =>
      'Permission d\'enregistrement audio refusée';

  @override
  String get playbackError => 'Erreur lors de la lecture:';

  @override
  String get noRecordingAvailable => 'Aucun enregistrement vocal disponible.';

  @override
  String get tevraghZeina => 'Tevragh-Zeina';

  @override
  String get ksar => 'Ksar';

  @override
  String get teyarett => 'Teyarett';

  @override
  String get toujounine => 'Toujounine';

  @override
  String get sebkha => 'Sebkha';

  @override
  String get elMina => 'El Mina';

  @override
  String get araffat => 'Araffat';

  @override
  String get riyadh => 'Riyadh';

  @override
  String get darNaim => 'Dar Naim';

  @override
  String get complaintDetailTitle => 'Détail de la Réclamation';

  @override
  String get loadingDetails => 'Chargement des détails...';

  @override
  String get errorTitle => 'Oups! Erreur';

  @override
  String get backButton => 'Retour';

  @override
  String get goBack => 'Retour';

  @override
  String get subjectTitle => 'Sujet';

  @override
  String get descriptionTitle => 'Description';

  @override
  String get noDescriptionProvided => 'Pas de description fournie.';

  @override
  String get municipalityTitle => 'Municipalité Concernée';

  @override
  String get adminCommentTitle => 'Commentaire Admin';

  @override
  String get attachmentsTitle => 'Pièces Jointes';

  @override
  String get citizenInfoTitle => 'Informations du Citoyen';

  @override
  String get videoTitle => 'Vidéo à l\'appui';

  @override
  String get videoLoadingError => 'Erreur chargement vidéo';

  @override
  String get voiceRecordingTitle => 'Enregistrement vocal';

  @override
  String get audioLoadingError => 'Erreur chargement audio';

  @override
  String get attachedDocumentTitle => 'Document joint';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get nniLabel => 'NNI';

  @override
  String get addressLabel => 'Adresse';

  @override
  String get municipalityLabel => 'Municipalité';

  @override
  String get linkNotAvailable => 'Lien non disponible';

  @override
  String get cannotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get videoLoadingErrorMessage => 'Erreur chargement vidéo';

  @override
  String get audioLoadingErrorMessage => 'Erreur chargement audio';

  @override
  String get complaintNotFound => 'Réclamation non trouvée';

  @override
  String get categorySelectionTitle => 'Choisir une catégorie';

  @override
  String get reportCategory => 'Signaler: ';

  @override
  String get detailsFor => 'Détails pour ';

  @override
  String get categoryRoads => 'Routes';

  @override
  String get categoryWater => 'Eau';

  @override
  String get categoryElectricity => 'Électricité';

  @override
  String get categoryWaste => 'Déchets';

  @override
  String get categoryBuildingPermit => 'Permis de construire ou de démolir';

  @override
  String get categoryOther => 'Autre';

  @override
  String get imageNotSupported => 'Image non supportée';

  @override
  String get errorOops => 'Oups! Erreur';

  @override
  String get problemDetailTitle => 'Détail du Problème';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusResolved => 'Résolu';

  @override
  String get statusRejected => 'Rejeté';

  @override
  String get voiceNoteTitle => 'Note Vocale';

  @override
  String get locationTitle => 'Emplacement';

  @override
  String get coordinatesNotAvailable => 'Coordonnées non disponibles.';

  @override
  String get documentTitle => 'Document';

  @override
  String get videoNotAvailable => 'Vidéo non disponible ou erreur';

  @override
  String get audioNotAvailable => 'Audio non disponible ou erreur';

  @override
  String get pauseTooltip => 'Pause';

  @override
  String get playTooltip => 'Lecture';

  @override
  String get expandMapTooltip => 'Agrandir la carte';

  @override
  String get collapseMapTooltip => 'Réduire la carte';

  @override
  String get problemNotFound => 'Problème non trouvé';

  @override
  String get reportProblemTitle => 'Signaler un Problème';

  @override
  String get locationServicesDisabled =>
      'Les services de localisation sont désactivés';

  @override
  String get locationServicesDisabledMessage =>
      'Veuillez activer les services de localisation dans les paramètres de votre appareil.';

  @override
  String get locationPermissionDenied => 'Permission de localisation refusée';

  @override
  String get locationPermissionDeniedForever =>
      'Permission de localisation définitivement refusée';

  @override
  String get permissionRequired => 'Permission requise';

  @override
  String get permissionRequiredMessage =>
      'Cette application nécessite la permission de localisation pour fonctionner. Veuillez l\'activer dans les paramètres.';

  @override
  String get locationError =>
      'Erreur de localisation: Impossible d\'obtenir la position.';

  @override
  String get positionNotAvailable => 'Position non disponible.';

  @override
  String get searchingMunicipality => 'Recherche municipalité...';

  @override
  String get municipalityNotFound => 'non trouvée.';

  @override
  String get cannotExtractMunicipality =>
      'Impossible d\'extraire le nom de la municipalité.';

  @override
  String get errorDeterminingMunicipality =>
      'Erreur détermination municipalité.';

  @override
  String get problemDescriptionTitle => 'Description du problème*';

  @override
  String get problemDescriptionHint => 'Décrivez le problème en détail...';

  @override
  String get pleaseProvideDescription => 'Veuillez fournir une description';

  @override
  String get minimum10Characters => 'Minimum 10 caractères';

  @override
  String get stopRecording => 'Arrêter';

  @override
  String get voiceNote => 'Note Vocale';

  @override
  String get microphonePermissionDenied => 'Permission microphone refusée';

  @override
  String get audioRecorderNotInitialized => 'Enregistreur audio non initialisé';

  @override
  String get recordingFinished => 'Enregistrement terminé:';

  @override
  String get errorStopping => 'Erreur lors de l\'arrêt:';

  @override
  String get recordingInProgress => 'Enregistrement en cours...';

  @override
  String get errorStarting => 'Erreur lors du démarrage:';

  @override
  String get problemLocationTitle => 'Emplacement du problème*';

  @override
  String get problemLocationSubtitle => 'Vous devez choisir un emplacement';

  @override
  String get loadingMap => 'Chargement de la carte...';

  @override
  String get centeredOnYourPosition => 'Centré sur votre position';

  @override
  String get documentsTitle => 'Documents à l\'appui';

  @override
  String get documentsSubtitle => 'Vous pouvez joindre jusqu\'à 3 documents';

  @override
  String get chooseDocuments => 'Choisir des documents';

  @override
  String get imagesTitle => 'Images à l\'appui';

  @override
  String get imagesSubtitle => 'Vous pouvez joindre jusqu\'à 3 images';

  @override
  String get camera => 'Appareil photo';

  @override
  String get gallery => 'Galerie';

  @override
  String get videoSubtitle => 'Vous pouvez joindre une seule vidéo';

  @override
  String get record => 'Enregistrer';

  @override
  String get videoLibrary => 'Galerie';

  @override
  String get cameraPermissionDenied => 'Permission caméra refusée';

  @override
  String get send => 'ENVOYER';

  @override
  String get pleaseFillRequiredFields =>
      'Veuillez remplir les champs obligatoires.';

  @override
  String get pleaseSelectProblemLocation =>
      'Veuillez sélectionner la position du problème.';

  @override
  String get pleaseWaitMunicipality => 'Veuillez patienter (municipalité)...';

  @override
  String get municipalityNotDetermined =>
      'Municipalité non déterminée. Soumission impossible.';

  @override
  String get authTokenMissing => 'Erreur: Token d\'authentification manquant.';

  @override
  String get problemReportedSuccess => 'Problème signalé avec succès!';

  @override
  String get submissionFailed => 'Échec:';

  @override
  String get networkSystemError => 'Erreur réseau/système:';

  @override
  String get maxImagesReached => 'Vous ne pouvez joindre que 3 images maximum.';

  @override
  String get imageSelectionError => 'Erreur sélection d\'image:';

  @override
  String get videoSelectionError => 'Erreur sélection/enregistrement vidéo:';

  @override
  String get documentSelectionError => 'Erreur sélection de document:';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get settings => 'Paramètres';

  @override
  String get lat => 'Lat';

  @override
  String get lon => 'Lon';

  @override
  String get problemPrefix => 'Problème: ';

  @override
  String get complaintPrefix => 'Réclamation: ';

  @override
  String get videoLoadError => 'Erreur chargement vidéo';

  @override
  String get audioLoadError => 'Erreur chargement audio';

  @override
  String get expandMap => 'Agrandir la carte';

  @override
  String get collapseMap => 'Réduire la carte';

  @override
  String get backTooltip => 'Retour';

  @override
  String get sectionDescription => 'Description';

  @override
  String get sectionVoiceNote => 'Note Vocale';

  @override
  String get sectionLocation => 'Emplacement';

  @override
  String get sectionVideo => 'Vidéo';

  @override
  String get sectionDocument => 'Document';

  @override
  String get sectionAdminComment => 'Commentaire Admin';

  @override
  String get reduceMap => 'Réduire la carte';

  @override
  String get enlargeMap => 'Agrandir la carte';

  @override
  String get myProfile => 'Mon Profil';

  @override
  String get editProfile => 'Modifier le Profil';

  @override
  String get edit => 'Modifier';

  @override
  String get save => 'Sauvegarder';

  @override
  String get error => 'Erreur';

  @override
  String get noProfileDataFound => 'Aucune donnée de profil trouvée.';

  @override
  String get personalInformation => 'Informations Personnelles';

  @override
  String get address => 'Adresse';

  @override
  String get phone => 'Téléphone';

  @override
  String get notDefined => 'Non défini';

  @override
  String get user => 'Utilisateur';

  @override
  String get removePicture => 'Supprimer la photo';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès !';

  @override
  String get updateFailed => 'Échec de la mise à jour';

  @override
  String get anErrorOccurred => 'Une erreur s\'est produite';

  @override
  String get fullNameCannotBeEmpty => 'Le nom ne peut pas être vide';

  @override
  String get authTokenNotFound =>
      'Token d\'authentification non trouvé. Veuillez vous reconnecter.';

  @override
  String get authTokenNotFoundShort => 'Token d\'authentification non trouvé.';

  @override
  String get failedToLoadProfile => 'Échec du chargement du profil';

  @override
  String get failedToUpdateProfile => 'Échec de la mise à jour du profil';

  @override
  String get failedToPickImage => 'Échec de la sélection de l\'image';

  @override
  String get anErrorOccurredDuringUpdate =>
      'Une erreur s\'est produite lors de la mise à jour';

  @override
  String get aboutUs => 'À propos de nous';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get contactUs => 'Nous Contacter';

  @override
  String get weAreHereToHelp => 'Nous sommes là pour vous aider !';

  @override
  String get arafatPhoneNumber => 'Numéro de téléphone d\'Arafat';

  @override
  String get cannotLaunch => 'Impossible de lancer';
}
