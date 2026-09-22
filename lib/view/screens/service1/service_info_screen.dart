import 'dart:typed_data';
import 'package:farah/view/screens/auth/login.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'request_under_review_screen.dart';
import 'package:flutter/gestures.dart';

// وعلى Android/iOS لازم صلاحية الكاميرا:
// - Android: android.permission.CAMERA في AndroidManifest.xml
// - iOS: NSCameraUsageDescription في Info.plist

class ServiceInfoScreen extends StatefulWidget {
  const ServiceInfoScreen({super.key});

  @override
  State<ServiceInfoScreen> createState() => _ServiceInfoScreenState();
}

class _ServiceCategory {
  final String label;
  final IconData icon;
  const _ServiceCategory(this.label, this.icon);
}

class _ServiceInfoScreenState extends State<ServiceInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final activityNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final commercialRegisterController = TextEditingController();

  final List<_ServiceCategory> categories = const [
    _ServiceCategory('تصوير فوتوغرافي', Icons.camera_alt_outlined),
    _ServiceCategory('صالات أفراح', Icons.mosque_outlined),
    _ServiceCategory('تنسيق ورد', Icons.local_florist_outlined),
    _ServiceCategory('كوافير', Icons.face_retouching_natural_outlined),
    _ServiceCategory('بدلات رجالية', Icons.checkroom_outlined),
    _ServiceCategory('فساتين زفاف', Icons.dry_cleaning_outlined),
    _ServiceCategory('تزيين سيارات', Icons.directions_car_filled_outlined),
    _ServiceCategory('دي جي', Icons.speaker_outlined),
    _ServiceCategory('كوشة', Icons.chair_outlined),
    _ServiceCategory('كروت أفراح', Icons.mail_outline),
    _ServiceCategory('تأجير سيارات', Icons.local_shipping_outlined),
    _ServiceCategory('كيك', Icons.cake_outlined),
  ];
  final Set<String> selectedCategories = {};
  static const int minCategories = 1;
  static const int maxCategories = 5;
  String? categoriesError;

  bool showAllCategories = false;
  static const int collapsedCategoriesCount = 2;

  XFile? idImage;
  String? idImageError;

  XFile? coverImage;
  Uint8List? coverImageBytes;
  bool isLoading = false;

  @override
  void dispose() {
    activityNameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    commercialRegisterController.dispose();
    super.dispose();
  }

  void _toggleCategory(String label) {
    setState(() {
      if (selectedCategories.contains(label)) {
        selectedCategories.remove(label);
      } else {
        if (selectedCategories.length < maxCategories) {
          selectedCategories.add(label);
        }
      }
      categoriesError = null;
    });
  }

  Future<void> _captureIdSelfie() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() {
        idImage = photo;
        idImageError = null;
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        coverImage = image;
        coverImageBytes = bytes;
      });
    }
  }

  void _onNextPressed() {
    setState(() {
      categoriesError = selectedCategories.isEmpty
          ? 'الرجاء اختيار خدمة واحدة على الأقل'
          : null;
      idImageError = idImage == null
          ? 'الرجاء التقاط صورة سلفي مع الهوية'
          : null;
    });

    final isFormValid = _formKey.currentState!.validate();

    if (isFormValid && categoriesError == null && idImageError == null) {
      // لما يترابط الـ Cubit، التنقل لازم يصير عن طريق BlocListener
      // (مش Navigator مباشرة زي تحت) بعد استجابة نجاح من السيرفر

      // تنقل مؤقت لحد ما يترابط الـ Cubit:
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RequestUnderReviewScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'معلومات الخدمة',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_forward, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ساعدنا في التعرف على نشاطك ليظهر للعملاء بطريقة احترافية',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('اسم العمل/النشاط', theme),
                TextFormField(
                  controller: activityNameController,
                  decoration: const InputDecoration(
                    hintText: 'ادخل اسم النشاط',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال اسم النشاط';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildCategoriesHeader(theme, primary),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'يمكنك اختيار كافة الخدمات التي تقدمها',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildCategoriesGrid(theme, primary),
                if (categoriesError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    categoriesError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                _buildLabel('وصف قصير للخدمة', theme),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'نبذة مختصرة تظهر في بطاقة عرض الخدمة',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال وصف قصير للخدمة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildLabel('عنوان العمل', theme),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(
                    hintText: 'اكتب عنوانك بالتفصيل (المدينة، الحي، الشارع)',
                    suffixIcon: Icon(
                      Icons.location_on_outlined,
                      color: primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال عنوان العمل';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                _buildLabel('إثبات الهوية', theme),
                _buildIdCaptureField(theme, primary),
                if (idImageError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    idImageError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 18, color: primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black87,
                            ),
                            children: [
                              const TextSpan(
                                text:
                                    'للمحافظة على موثوقية مزودي الخدمات داخل ',
                              ),
                              TextSpan(
                                text: 'فرحتنا',
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel('رقم السجل التجاري (ان وجد)', theme),
                TextFormField(
                  controller: commercialRegisterController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'أدخل رقم السجل التجاري',
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('صورة الغلاف', theme),
                _buildCoverUploadField(theme, primary),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isLoading ? null : _onNextPressed,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('التالي'),
                ),
                const SizedBox(height: 16),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                    children: [
                      const TextSpan(text: 'لديك حساب بالفعل! '),
                      TextSpan(
                        text: 'تسجيل الدخول',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                      ), //
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader(ThemeData theme, Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'فئة الخدمة',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() => showAllCategories = !showAllCategories);
          },
          child: Row(
            children: [
              Icon(
                showAllCategories
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: primary,
                size: 20,
              ),
              SizedBox(width: 2),
              Text(
                'عرض الكل',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(ThemeData theme, Color primary) {
    final List<_ServiceCategory> visibleCategories = showAllCategories
        ? categories
        : categories.take(collapsedCategoriesCount).toList();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.6,
      children: visibleCategories.map((cat) {
        final isSelected = selectedCategories.contains(cat.label);
        return GestureDetector(
          onTap: () => _toggleCategory(cat.label),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isSelected ? primary : Colors.grey.shade300,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  cat.icon,
                  color: isSelected ? primary : Colors.grey.shade600,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    cat.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? primary : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIdCaptureField(ThemeData theme, Color primary) {
    return GestureDetector(
      onTap: _captureIdSelfie,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: idImageError != null
                ? theme.colorScheme.error
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.camera_alt_outlined, color: primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                idImage != null
                    ? 'تم التقاط صورة الهوية ✓'
                    : 'صورة سلفي مع الهوية الشخصية',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: idImage != null
                      ? Colors.black87
                      : Colors.grey.shade600,
                  fontWeight: idImage != null
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverUploadField(ThemeData theme, Color primary) {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey.shade400,
            style: BorderStyle.solid,
          ),
        ),
        child: coverImage != null && coverImageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.memory(
                  coverImageBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, color: primary, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'إضغط للرفع',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
