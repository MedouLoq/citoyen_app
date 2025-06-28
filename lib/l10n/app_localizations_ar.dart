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
  String get nni => 'رقم التعريف الوطني';

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
  String get dashboardTitle => 'لوحة القيادة';

  @override
  String get reportButton => 'الإبلاغ';

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
  String get inProgress => 'قيد المعالجة';

  @override
  String get resolved => 'تم الحل';

  @override
  String get rejected => 'مرفوض';

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
}
