class AppStrings {
  // App
  static const String appName = 'فرحتنا';
  static const String appTagline = 'تطبيق فرحتنا لإدارة المناسبات والخدمات';

  // Common
  static const String confirm = 'تأكيد';
  static const String cancel = 'إلغاء';
  static const String save = 'حفظ';
  static const String next = 'التالي';
  static const String back = 'العودة سابقا';
  static const String continueBtn = 'المتابعة';
  static const String retry = 'إعادة المحاولة';
  static const String loading = 'جارٍ التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String generalError = 'حدث خطأ، يرجى المحاولة مجدداً';
  static const String networkError = 'تحقق من اتصالك بالإنترنت';
  static const String timeoutError = 'انتهت مهلة الاتصال، يرجى المحاولة مجدداً';

  // Auth — Login
  static const String login = 'تسجيل الدخول';
  static const String loginTitle = 'تسجيل دخول';
  static const String loginSubtitle = 'اهلا بعودتك مجددا';
  static const String loginButton = 'تسجيل الدخول';
  static const String continueWithGoogle = 'المتابعة باستخدام Google';
  static const String noAccount = 'ليس لديك حساب؟';
  static const String createAccount = 'إنشاء حساب';
  static const String forgotPassword = 'نسيت كلمة المرور؟';

  // Auth — Sign Up
  static const String signupTitle = 'إنشاء حساب';
  static const String signupSubtitle =
      'انضم إلينا وابدأ رحلة التخطيط لزفافك بكل أناقة وسهولة.';
  static const String signupButton = 'اشتراك';
  static const String hasAccount = 'لديك حساب بالفعل!';
  static const String privacyConsent = 'بالضغط على اشتراك فإنك توافق على ';
  static const String privacyLink = 'سياسية الخصوصية والاستخدام';

  // Auth — Forgot Password
  static const String forgotPasswordTitle = 'نسيت كلمة المرور';
  static const String forgotPasswordEmailSubtitle =
      'يرجى ادخال بريدك الالكتروني';
  static const String forgotPasswordPhoneSubtitle = 'يرجى ادخال رقم هاتفك';
  static const String tryAnotherWay = 'تجربة طريقة اخرى';
  static const String resetEmailSent =
      'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك';

  // Auth — Verify Code
  static const String verifyTitle = 'أدخل رمز التحقق';
  static const String verifySubtitle = 'تم ارسال رمز التحقق إلى بريدك';
  static const String resendCode = 'إعادة الإرسال';
  static const String notReceived = 'لم يصلك الرمز؟ ';

  // Auth — New Password
  static const String newPasswordTitle = 'كلمة مرور جديدة';
  static const String newPasswordSubtitle = 'يرجى كتابة كلمة مرور قوية';
  static const String newPasswordButton = 'إنشاء كلمة مرور جديدة';
  static const String passwordUpdated = 'تم تحديث كلمة المرور بنجاح';

  // Auth — Terms
  static const String termsTitle = 'الشروط والاحكام';
  static const String termsWelcome = 'مرحبًا بك في';
  static const String termsIntro =
      'يرجى قراءة الشروط التالية بعناية قبل استخدام التطبيق:';
  static const String termsAccept = 'قبول الشروط والاحكام';
  static const String privacyPolicyTitle = 'سياسة الخصوصية:';

  // Form fields
  static const String email = 'البريد الإلكتروني';
  static const String emailHint = 'example@gmail.com';
  static const String password = 'كلمة المرور';
  static const String passwordHint = '••••••••••••';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String name = 'الاسم';
  static const String nameHint = 'example';
  static const String phone = 'رقم الجوال';
  static const String phoneHint = '598577418';
  static const String region = 'المنطقة';
  static const String regionHint = 'اختر منطقتك';
  static const String phoneField = 'رقم الهاتف';

  // Validation
  static const String emailRequired = 'الرجاء إدخال البريد الإلكتروني';
  static const String emailInvalid = 'صيغة البريد الإلكتروني غير صحيحة';
  static const String passwordRequired = 'الرجاء إدخال كلمة المرور';
  static const String passwordTooShort =
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
  static const String passwordWeak = 'كلمة المرور ضعيفة جداً';
  static const String passwordMismatch = 'كلمة المرور غير متطابقة';
  static const String confirmPasswordRequired = 'الرجاء تأكيد كلمة المرور';
  static const String nameRequired = 'الرجاء إدخال الاسم';
  static const String phoneRequired = 'الرجاء إدخال رقم الجوال';
  static const String phoneInvalid = 'رقم الهاتف غير صحيح';
  static const String regionRequired = 'الرجاء اختيار المنطقة';

  // Regions
  static const String northGaza = 'شمال غزة';
  static const String centralGaza = 'وسط غزة';
  static const String southGaza = 'جنوب غزة';
  static const List<String> regions = [northGaza, centralGaza, southGaza];

  // Service categories
  static const String photography = 'تصوير فوتوغرافي';
  static const String weddingHalls = 'صالات أفراح';
  static const String flowers = 'تنسيق ورد';
  static const String hairSalon = 'كوافير';
  static const String mensSuits = 'بدلات رجالية';
  static const String weddingDresses = 'فساتين زفاف';
  static const String carDecoration = 'تزيين سيارات';
  static const String dj = 'دي جي';
  static const String kosha = 'كوشة';
  static const String invitations = 'كروت أفراح';
  static const String carRental = 'تأجير سيارات';
  static const String cake = 'كيك';

  // Service onboarding
  static const String serviceInfoTitle = 'معلومات الخدمة';
  static const String serviceInfoSubtitle =
      'ساعدنا في التعرف على نشاطك ليظهر للعملاء بطريقة احترافية';
  static const String businessName = 'اسم العمل/النشاط';
  static const String businessNameHint = 'ادخل اسم النشاط';
  static const String serviceCategory = 'فئة الخدمة';
  static const String viewAll = 'عرض الكل';
  static const String canSelectAll = 'يمكنك اختيار كافة الخدمات التي تقدمها';
  static const String shortDescription = 'وصف قصير للخدمة';
  static const String descriptionHint = 'نبذة مختصرة تظهر في بطاقة عرض الخدمة';
  static const String workAddress = 'عنوان العمل';
  static const String addressHint =
      'اكتب عنوانك بالتفصيل (المدينة، الحي، الشارع)';
  static const String idProof = 'إثبات الهوية';
  static const String idSelfie = 'صورة سلفي مع الهوية الشخصية';
  static const String idCaptured = 'تم التقاط صورة الهوية ✓';
  static const String commercialRegister = 'رقم السجل التجاري (ان وجد)';
  static const String commercialRegisterHint = 'أدخل رقم السجل التجاري';
  static const String coverImage = 'صورة الغلاف';
  static const String uploadImage = 'إضغط للرفع';
  static const String categoryRequired = 'الرجاء اختيار خدمة واحدة على الأقل';
  static const String idRequired = 'الرجاء التقاط صورة سلفي مع الهوية';
  static const String businessNameRequired = 'الرجاء إدخال اسم النشاط';
  static const String descriptionRequired = 'الرجاء إدخال وصف قصير للخدمة';
  static const String addressRequired = 'الرجاء إدخال عنوان العمل';

  // Booking status labels
  static const String statusPending = 'قيد الانتظار';
  static const String statusConfirmed = 'مؤكد';
  static const String statusCancelled = 'ملغي';
  static const String statusCompleted = 'مكتمل';

  // Home
  static const String homeTitle = 'الصفحة الرئيسية';
  static const String searchHint = 'ابحث عن خدمة...';
  static const String featuredServices = 'خدمات مميزة';
  static const String allServices = 'جميع الخدمات';
  static const String noServices = 'لا توجد خدمات متاحة';

  // Orders
  static const String myOrders = 'طلباتي';
  static const String noOrders = 'لا توجد طلبات بعد';

  // Profile
  static const String myProfile = 'ملفي الشخصي';
  static const String editProfile = 'تعديل الملف الشخصي';
  static const String logout = 'تسجيل الخروج';

  // Notifications
  static const String notificationsTitle = 'الإشعارات';
  static const String markAllRead = 'تحديد الكل كمقروء';
  static const String noNotifications = 'لا توجد إشعارات';
}
