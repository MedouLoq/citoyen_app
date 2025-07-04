// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'بلديتي';

  @override
  String get appTagline => 'صوتك، مدينتك.';

  @override
  String get continueButton => 'المتابعة إلى بلديتي';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get whatIsThisApp => 'ما هو هذا التطبيق؟';

  @override
  String get whatIsThisAppContent =>
      'تطبيق ذكي يهدف إلى تعزيز العلاقة بين البلدية والمواطن، من خلال تسهيل الإبلاغ عن المشاكل المحلية ومتابعة حلها، وتحسين جودة الخدمات اليومية، مثل النظافة، الطرق، المياه، إلخ.';

  @override
  String get mainRoleOfApp => 'الدور الرئيسي للتطبيق';

  @override
  String get mainRoleOfAppContent =>
      '• تسهيل عملية الإبلاغ عن الأعطال والمشاكل في الأحياء (مثل الحفر، تراكم النفايات، تسربات المياه، مخالفات البناء...)\n• توفير منصة موحدة للتواصل بين المواطنين والبلدية.\n• إرسال إشعارات وتنبيهات بلدية مثل حملات النظافة، الأشغال العامة أو تنبيهات الطوارئ.\n• تمكين المواطن من متابعة مشكلته من خلال نظام تتبع دقيق (تم الاستلام - قيد المعالجة - تم الحل).';

  @override
  String get citizenRights => 'حقوق المواطن';

  @override
  String get citizenResponsibilities => 'مسؤوليات المواطن';

  @override
  String get citizenRightsContent =>
      '• الحق في الإبلاغ عن المشاكل في أي وقت ومن أي مكان.\n• إمكانية إرفاق الصور والموقع الجغرافي لتوضيح المشكلة.\n• تلقي إشعارات فورية حول حالة البلاغ أو الشكوى.\n• تقديم شكاوى عامة بخصوص الخدمات أو الأداء.\n• متابعة الشكوى وتقديم ملاحظات إضافية في حال تأخر الحل.';

  @override
  String get citizenResponsibilitiesContent =>
      '• يجب أن يكون البلاغ دقيقًا وصادقًا، دون بلاغات كاذبة أو كيدية.\n• احترام تصنيف المشاكل حسب الفئات الصحيحة (نظافة، طرق، مياه...).\n• التفاعل بلباقة واحترام مع ردود البلدية عبر التطبيق.\n• الالتزام بعدم استخدام التطبيق لأغراض شخصية أو خارج إطار المصلحة العامة.';

  @override
  String get appBenefits => 'مزايا التطبيق';

  @override
  String get appBenefitsContent =>
      '• تحسين شفافية العمل البلدي.\n• تسريع الاستجابة للمشاكل.\n• إيصال المعلومات الرسمية للمواطنين بسرعة.\n• إشراك المواطن في تحسين بيئته والخدمات المحيطة به.';

  @override
  String get rejectButton => 'رفض';

  @override
  String get acceptButton => 'قبول';

  @override
  String get authentication => 'المصادقة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get loginError => 'خطأ في تسجيل الدخول';

  @override
  String get correctErrors => 'يرجى تصحيح الأخطاء';

  @override
  String get invalidCredentials => 'اسم المستخدم أو كلمة المرور غير صحيحة';

  @override
  String connectionError(Object statusCode) {
    return 'خطأ في الاتصال. الرمز: $statusCode';
  }

  @override
  String get connectionErrorInternet =>
      'خطأ في الاتصال. يرجى التحقق من اتصال الإنترنت.';

  @override
  String get serverFormatError => 'خطأ في تنسيق استجابة الخادم';

  @override
  String get serverCommunicationError => 'خطأ في التواصل مع الخادم';

  @override
  String get timeoutError => 'انتهت مهلة الانتظار. يرجى التحقق من الاتصال.';

  @override
  String get registrationSuccess =>
      'تم إنشاء الحساب بنجاح! تم إرسال رمز التحقق.';

  @override
  String get registrationFailedCodeNotSent =>
      'تم إنشاء الحساب، لكن فشل في إرسال الرمز. يرجى المحاولة مرة أخرى.';

  @override
  String get registrationError => 'خطأ في التسجيل';

  @override
  String get selectMunicipality => 'يرجى اختيار البلدية';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get nni => 'الرقم الوطني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get municipality => 'البلدية';

  @override
  String get emailOrPhone => 'البريد الإلكتروني أو رقم الهاتف';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get registerButton => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get reportButton => 'إبلاغ';

  @override
  String get myReportedProblems => 'مشاكلي المبلغ عنها';

  @override
  String get refresh => 'تحديث';

  @override
  String problemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مشاكل',
      many: 'العديد من المشاكل',
      few: 'عدد قليل من المشاكل',
      two: 'مشكلتان',
      one: 'مشكلة واحدة',
      zero: 'لا توجد مشاكل',
    );
    return '$_temp0';
  }

  @override
  String get all => 'الكل';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get resolved => 'محلولة';

  @override
  String get rejected => 'مرفوضة';

  @override
  String get unknown => 'غير معروف';

  @override
  String get unknownCategory => 'فئة غير معروفة';

  @override
  String get noDescription => 'لا يوجد وصف';

  @override
  String get unknownLocation => 'موقع غير معروف';

  @override
  String get filterByStatus => 'تصفية حسب الحالة';

  @override
  String get close => 'إغلاق';

  @override
  String get loadingProblems => 'جاري تحميل المشاكل...';

  @override
  String get loadingError => 'خطأ في التحميل';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noProblemsFound => 'لم يتم العثور على مشاكل';

  @override
  String get noProblemsFoundMessage => 'لم تقم بالإبلاغ عن أي مشاكل حتى الآن.';

  @override
  String get quickActions => 'الإجراءات السريعة';

  @override
  String get myReports => 'تقاريري';

  @override
  String get yourStatistics => 'إحصائياتك';

  @override
  String get problemsReported => 'المشاكل المُبلغ عنها';

  @override
  String get complaints => 'شكاوى';

  @override
  String get recentActivity => 'النشاط الأخير';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noRecentActivity => 'لا يوجد نشاط حديث';

  @override
  String get noRecentActivityMessage => 'ستظهر تقاريرك وشكاواك هنا';

  @override
  String get newProblemReported => 'تم الإبلاغ عن مشكلة جديدة';

  @override
  String get newComplaintSubmitted => 'تم تقديم شكوى جديدة';

  @override
  String get noSubject => 'لا يوجد موضوع';

  @override
  String get unknownActivity => 'نشاط غير معروف';

  @override
  String get unknownTime => 'غير معروف';

  @override
  String get longTimeAgo => 'منذ وقت طويل';

  @override
  String get dashboardUpdatedSuccessfully => 'تم تحديث لوحة التحكم بنجاح';

  @override
  String get errorUpdatingDashboard => 'خطأ في التحديث';

  @override
  String get updating => 'جاري التحديث...';

  @override
  String daysAgo(Object count) {
    return 'منذ $count أيام';
  }

  @override
  String hoursAgo(Object count) {
    return 'منذ $count ساعات';
  }

  @override
  String minutesAgo(Object count) {
    return 'منذ $count دقائق';
  }

  @override
  String get justNow => 'الآن';

  @override
  String get buttonHome => 'الرئيسية';

  @override
  String get bnjr => 'مرحبا ,';

  @override
  String get buttonProb => 'المشاكل';

  @override
  String get buttonComp => 'الشكاوى';

  @override
  String get buttonProfile => 'الملف الشخصي';

  @override
  String get myComplaints => 'شكاواي';

  @override
  String get filter => 'تصفية';

  @override
  String get reviewing => 'قيد المراجعة';

  @override
  String get delegated => 'مفوضة';

  @override
  String get complaint => 'شكوى';

  @override
  String outOfTotal(Object total) {
    return 'من أصل $total';
  }

  @override
  String get pendingStatus => 'في الانتظار';

  @override
  String get reviewingStatus => 'قيد المراجعة';

  @override
  String get resolvedStatus => 'تم الحل';

  @override
  String get rejectedStatus => 'مرفوضة';

  @override
  String get inProgressStatus => 'قيد التنفيذ';

  @override
  String get delegatedStatus => 'مفوضة';

  @override
  String get unknownStatus => 'غير معروف';

  @override
  String dayAgo(Object count) {
    return 'منذ $count يوم';
  }

  @override
  String hourAgo(Object count) {
    return 'منذ $count ساعة';
  }

  @override
  String minuteAgo(Object count) {
    return 'منذ $count دقيقة';
  }

  @override
  String get subjectNotSpecified => 'لم يتم تحديد الموضوع';

  @override
  String get unknownMunicipality => 'بلدية غير معروفة';

  @override
  String get unknownDate => 'تاريخ غير معروف';

  @override
  String get imageNotAvailable => 'الصورة غير متاحة';

  @override
  String get newComplaint => 'شكوى جديدة';

  @override
  String get allComplaints => 'جميع الشكاوى';

  @override
  String get pendingComplaints => 'قيد الانتظار';

  @override
  String get inProgressComplaints => 'قيد التنفيذ';

  @override
  String get delegatedComplaints => 'مفوضة';

  @override
  String get reviewingComplaints => 'قيد المراجعة';

  @override
  String get resolvedComplaints => 'محلولة';

  @override
  String get rejectedComplaints => 'مرفوضة';

  @override
  String get loadingComplaints => 'جاري تحميل الشكاوى...';

  @override
  String get pleaseWait => 'يرجى الانتظار';

  @override
  String get oopsError => 'عذراً! حدث خطأ';

  @override
  String get pullToRefresh => 'اسحب للأسفل للتحديث';

  @override
  String get noComplaints => 'لا توجد شكاوى';

  @override
  String get noComplaintsMessage =>
      'لم تقم بتقديم أي شكوى بعد.\nابدأ بإنشاء شكواك الأولى.';

  @override
  String get createComplaint => 'إنشاء شكوى';

  @override
  String get unableToLoadComplaints => 'تعذر تحميل الشكاوى. تحقق من اتصالك.';

  @override
  String get errorDuringRefresh => 'خطأ أثناء التحديث';

  @override
  String get submitComplaintTitle => 'تقديم شكوى';

  @override
  String get welcomeTitle => 'صوتك مهم';

  @override
  String get welcomeSubtitle => 'ساعدنا في تحسين خدماتنا معاً';

  @override
  String get municipalitySection => 'البلدية المعنية';

  @override
  String get municipalityPlaceholder => 'اختر بلدية';

  @override
  String get municipalityValidation => 'يرجى اختيار بلدية';

  @override
  String get subjectSection => 'موضوع الشكوى';

  @override
  String get subjectPlaceholder => 'لخص شكواك في كلمات قليلة';

  @override
  String get subjectValidationRequired => 'الموضوع مطلوب';

  @override
  String get subjectValidationMinLength =>
      'يجب أن يحتوي الموضوع على 5 أحرف على الأقل';

  @override
  String get descriptionSection => 'الوصف التفصيلي';

  @override
  String get descriptionPlaceholder => 'اوصف شكواك بالتفصيل...';

  @override
  String get descriptionValidationRequired => 'الوصف مطلوب';

  @override
  String get descriptionValidationMinLength =>
      'يجب أن يحتوي الوصف على 20 حرفاً على الأقل';

  @override
  String get voiceRecordingSection => 'رسالة صوتية (اختياري)';

  @override
  String get voiceRecordingInstructions => 'سجل رسالة صوتية لمرافقة شكواك';

  @override
  String get voiceRecordingStart => 'اضغط للتسجيل';

  @override
  String get voiceRecordingStop => 'اضغط على الزر للتوقف';

  @override
  String get voiceRecordingInProgress => 'جاري التسجيل...';

  @override
  String get voiceRecordingStoppingInProgress => 'جاري الإيقاف...';

  @override
  String get voiceRecordingPleaseWait => 'يرجى الانتظار...';

  @override
  String get voiceRecordingReady => 'التسجيل جاهز';

  @override
  String get voiceRecordingPlayInstructions =>
      'اضغط على التشغيل للاستماع لتسجيلك';

  @override
  String get attachmentsSection => 'المرفقات';

  @override
  String get photoAttachment => 'صورة';

  @override
  String get photoSelected => 'تم اختيار الصورة';

  @override
  String get photoAdd => 'إضافة صورة';

  @override
  String get videoAttachment => 'فيديو';

  @override
  String get videoSelected => 'تم اختيار الفيديو';

  @override
  String get videoAdd => 'إضافة فيديو';

  @override
  String get evidenceAttachment => 'دليل (مطلوب)';

  @override
  String get evidenceAdd => 'إضافة مستند';

  @override
  String get submitButton => 'تقديم الشكوى';

  @override
  String get submitButtonProgress => 'جاري التقديم...';

  @override
  String get submitSuccess => 'تم تقديم الشكوى بنجاح!';

  @override
  String get submitError => 'فشل في تقديم الشكوى.';

  @override
  String get submitUnexpectedError => 'حدث خطأ غير متوقع:';

  @override
  String get evidenceRequired => 'يرجى إرفاق دليل (مستند مطلوب).';

  @override
  String get recordingErrorStart => 'خطأ أثناء بدء التسجيل:';

  @override
  String get recordingErrorStop => 'خطأ أثناء إيقاف التسجيل:';

  @override
  String get recordingPermissionDenied => 'تم رفض إذن التسجيل الصوتي';

  @override
  String get playbackError => 'خطأ أثناء التشغيل:';

  @override
  String get noRecordingAvailable => 'لا يوجد تسجيل صوتي متاح.';

  @override
  String get tevraghZeina => 'تفرغ زينة';

  @override
  String get ksar => 'القصر';

  @override
  String get teyarett => 'تيارت';

  @override
  String get toujounine => 'توجنين';

  @override
  String get sebkha => 'السبخة';

  @override
  String get elMina => 'الميناء';

  @override
  String get araffat => 'عرفات';

  @override
  String get riyadh => 'الرياض';

  @override
  String get darNaim => 'دار النعيم';

  @override
  String get complaintDetailTitle => 'تفاصيل الشكوى';

  @override
  String get loadingDetails => 'جارٍ تحميل التفاصيل...';

  @override
  String get errorTitle => 'أُوبس! خطأ';

  @override
  String get backButton => 'عودة';

  @override
  String get goBack => 'رجوع';

  @override
  String get subjectTitle => 'الموضوع';

  @override
  String get descriptionTitle => 'الوصف';

  @override
  String get noDescriptionProvided => 'لا يوجد وصف متاح.';

  @override
  String get municipalityTitle => 'البلدية المعنية';

  @override
  String get adminCommentTitle => 'تعليق المسؤول';

  @override
  String get attachmentsTitle => 'المرفقات';

  @override
  String get citizenInfoTitle => 'معلومات المواطن';

  @override
  String get videoTitle => 'الفيديو المرفق';

  @override
  String get videoLoadingError => 'خطأ في تحميل الفيديو';

  @override
  String get voiceRecordingTitle => 'تسجيل صوتي';

  @override
  String get audioLoadingError => 'خطأ في تحميل الصوت';

  @override
  String get attachedDocumentTitle => 'وثيقة مرفقة';

  @override
  String get fullNameLabel => 'الاسم الكامل';

  @override
  String get nniLabel => 'رقم الهوية الوطنية';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get municipalityLabel => 'البلدية';

  @override
  String get linkNotAvailable => 'الرابط غير متوفر';

  @override
  String get cannotOpenLink => 'تعذر فتح الرابط';

  @override
  String get videoLoadingErrorMessage => 'خطأ في تحميل الفيديو';

  @override
  String get audioLoadingErrorMessage => 'خطأ في تحميل الصوت';

  @override
  String get complaintNotFound => 'لم يتم العثور على الشكوى';

  @override
  String get categorySelectionTitle => 'اختر فئة';

  @override
  String get reportCategory => 'الإبلاغ عن: ';

  @override
  String get detailsFor => 'تفاصيل لـ ';

  @override
  String get categoryRoads => 'الطرق';

  @override
  String get categoryWater => 'المياه';

  @override
  String get categoryElectricity => 'الكهرباء';

  @override
  String get categoryWaste => 'النفايات';

  @override
  String get categoryBuildingPermit => 'رخصة البناء أو الهدم';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get imageNotSupported => 'الصورة غير مدعومة';

  @override
  String get errorOops => 'عذراً! خطأ';

  @override
  String get problemDetailTitle => 'تفاصيل المشكلة';

  @override
  String get statusPending => 'في الانتظار';

  @override
  String get statusInProgress => 'قيد التنفيذ';

  @override
  String get statusResolved => 'تم الحل';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get voiceNoteTitle => 'الملاحظة الصوتية';

  @override
  String get locationTitle => 'الموقع';

  @override
  String get coordinatesNotAvailable => 'الإحداثيات غير متوفرة.';

  @override
  String get documentTitle => 'المستند';

  @override
  String get videoNotAvailable => 'الفيديو غير متاح أو خطأ';

  @override
  String get audioNotAvailable => 'الصوت غير متاح أو خطأ';

  @override
  String get pauseTooltip => 'إيقاف مؤقت';

  @override
  String get playTooltip => 'تشغيل';

  @override
  String get expandMapTooltip => 'توسيع الخريطة';

  @override
  String get collapseMapTooltip => 'تقليل الخريطة';

  @override
  String get problemNotFound => 'المشكلة غير موجودة';

  @override
  String get reportProblemTitle => 'الإبلاغ عن مشكلة';

  @override
  String get locationServicesDisabled => 'خدمات الموقع معطلة';

  @override
  String get locationServicesDisabledMessage =>
      'يرجى تفعيل خدمات الموقع في إعدادات الجهاز.';

  @override
  String get locationPermissionDenied => 'تم رفض إذن الموقع';

  @override
  String get locationPermissionDeniedForever => 'تم رفض إذن الموقع نهائياً';

  @override
  String get permissionRequired => 'إذن مطلوب';

  @override
  String get permissionRequiredMessage =>
      'يتطلب هذا التطبيق إذن الموقع للعمل. يرجى تفعيله في الإعدادات.';

  @override
  String get locationError => 'خطأ في الموقع: غير قادر على الحصول على الموقع.';

  @override
  String get positionNotAvailable => 'الموقع غير متاح.';

  @override
  String get searchingMunicipality => 'البحث عن البلدية...';

  @override
  String get municipalityNotFound => 'غير موجودة.';

  @override
  String get cannotExtractMunicipality => 'غير قادر على استخراج اسم البلدية.';

  @override
  String get errorDeterminingMunicipality => 'خطأ في تحديد البلدية.';

  @override
  String get problemDescriptionTitle => 'وصف المشكلة*';

  @override
  String get problemDescriptionHint => 'صف المشكلة بالتفصيل...';

  @override
  String get pleaseProvideDescription => 'يرجى تقديم وصف';

  @override
  String get minimum10Characters => '10 أحرف كحد أدنى';

  @override
  String get stopRecording => 'إيقاف';

  @override
  String get voiceNote => 'تسجيل صوتي';

  @override
  String get microphonePermissionDenied => 'تم رفض إذن الميكروفون';

  @override
  String get audioRecorderNotInitialized => 'مسجل الصوت غير مهيأ';

  @override
  String get recordingFinished => 'انتهى التسجيل:';

  @override
  String get errorStopping => 'خطأ في الإيقاف:';

  @override
  String get recordingInProgress => 'التسجيل قيد التقدم...';

  @override
  String get errorStarting => 'خطأ في البدء:';

  @override
  String get problemLocationTitle => 'موقع المشكلة*';

  @override
  String get problemLocationSubtitle => 'يجب اختيار موقع';

  @override
  String get loadingMap => 'تحميل الخريطة...';

  @override
  String get centeredOnYourPosition => 'تم التركيز على موقعك';

  @override
  String get documentsTitle => 'المستندات المرفقة';

  @override
  String get documentsSubtitle => 'يمكنك إرفاق حتى 3 مستندات';

  @override
  String get chooseDocuments => 'اختيار المستندات';

  @override
  String get imagesTitle => 'الصور المرفقة';

  @override
  String get imagesSubtitle => 'يمكنك إرفاق حتى 3 صور';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get videoSubtitle => 'يمكنك إرفاق فيديو واحد فقط';

  @override
  String get record => 'تسجيل';

  @override
  String get videoLibrary => 'مكتبة الفيديو';

  @override
  String get cameraPermissionDenied => 'تم رفض إذن الكاميرا';

  @override
  String get send => 'إرسال';

  @override
  String get pleaseFillRequiredFields => 'يرجى ملء الحقول المطلوبة.';

  @override
  String get pleaseSelectProblemLocation => 'يرجى اختيار موقع المشكلة.';

  @override
  String get pleaseWaitMunicipality => 'يرجى الانتظار (البلدية)...';

  @override
  String get municipalityNotDetermined =>
      'لم يتم تحديد البلدية. لا يمكن الإرسال.';

  @override
  String get authTokenMissing => 'خطأ: رمز المصادقة مفقود.';

  @override
  String get problemReportedSuccess => 'تم الإبلاغ عن المشكلة بنجاح!';

  @override
  String get submissionFailed => 'فشل:';

  @override
  String get networkSystemError => 'خطأ في الشبكة/النظام:';

  @override
  String get maxImagesReached => 'لا يمكنك إرفاق أكثر من 3 صور.';

  @override
  String get imageSelectionError => 'خطأ في اختيار الصورة:';

  @override
  String get videoSelectionError => 'خطأ في اختيار/تسجيل الفيديو:';

  @override
  String get documentSelectionError => 'خطأ في اختيار المستند:';

  @override
  String get ok => 'حسناً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get settings => 'الإعدادات';

  @override
  String get lat => 'خط العرض';

  @override
  String get lon => 'خط الطول';

  @override
  String get problemPrefix => 'المشكلة:';

  @override
  String get complaintPrefix => 'مطالبة : ';

  @override
  String get videoLoadError => 'خطأ في تحميل الفيديو';

  @override
  String get audioLoadError => 'خطأ في تحميل الصوت';

  @override
  String get expandMap => 'توسيع الخريطة';

  @override
  String get collapseMap => 'تقليل الخريطة';

  @override
  String get backTooltip => 'عودة';

  @override
  String get sectionDescription => 'الوصف';

  @override
  String get sectionVoiceNote => 'مذكرة صوتية';

  @override
  String get sectionLocation => 'الموقع';

  @override
  String get sectionVideo => 'الفيديو';

  @override
  String get sectionDocument => 'الوثيقة';

  @override
  String get sectionAdminComment => 'تعليق المسؤول';

  @override
  String get reduceMap => 'تصغير الخريطة';

  @override
  String get enlargeMap => 'تكبير الخريطة';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get edit => 'تعديل';

  @override
  String get save => 'حفظ';

  @override
  String get error => 'خطأ';

  @override
  String get noProfileDataFound => 'لم يتم العثور على بيانات الملف الشخصي.';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get address => 'العنوان';

  @override
  String get phone => 'الهاتف';

  @override
  String get notDefined => 'غير محدد';

  @override
  String get user => 'المستخدم';

  @override
  String get removePicture => 'إزالة الصورة';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح!';

  @override
  String get updateFailed => 'فشل في التحديث';

  @override
  String get anErrorOccurred => 'حدث خطأ';

  @override
  String get fullNameCannotBeEmpty => 'لا يمكن أن يكون الاسم فارغاً';

  @override
  String get authTokenNotFound =>
      'لم يتم العثور على رمز المصادقة. يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get authTokenNotFoundShort => 'لم يتم العثور على رمز المصادقة.';

  @override
  String get failedToLoadProfile => 'فشل في تحميل الملف الشخصي';

  @override
  String get failedToUpdateProfile => 'فشل في تحديث الملف الشخصي';

  @override
  String get failedToPickImage => 'فشل في اختيار الصورة';

  @override
  String get anErrorOccurredDuringUpdate => 'حدث خطأ أثناء التحديث';

  @override
  String get aboutUs => 'معلومات عنا';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get weAreHereToHelp => 'نحن هنا لمساعدتك!';

  @override
  String get arafatPhoneNumber => 'رقم هاتف عرفات';

  @override
  String get cannotLaunch => 'لا يمكن تشغيل';
}
