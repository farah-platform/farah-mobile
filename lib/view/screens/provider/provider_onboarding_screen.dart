import 'dart:io';

import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_onboarding/provider_onboarding_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() =>
      _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  // Colours from the "بيانات الحساب" design.
  static const _pageBg = Color(0xFFFDF6F7);
  static const _tileBorder = Color(0xFFE6D3D8);
  static const _selectedFill = Color(0xFFFBEEF1);
  static const _noteFill = Color(0xFFF8EAED);
  static const _hint = Color(0xFFA8A8A8);

  // Categories shown before "عرض الكل" is tapped.
  static const _collapsedCount = 3;

  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _profitAccountController = TextEditingController();
  final _crController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCityId;
  File? _idProofFile;
  File? _coverImageFile;
  List<dynamic> _categories = [];
  List<dynamic> _cities = [];
  bool _showAllCategories = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderOnboardingCubit>().loadData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _profitAccountController.dispose();
    _crController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isIdProof) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isIdProof) {
          _idProofFile = File(picked.path);
        } else {
          _coverImageFile = File(picked.path);
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار فئة الخدمة')),
        );
        return;
      }
      if (_selectedCityId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار عنوان العمل')),
        );
        return;
      }
      if (_idProofFile == null || _coverImageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء رفع الصور المطلوبة')),
        );
        return;
      }
      context.read<ProviderOnboardingCubit>().submit(
        businessName: _businessNameController.text,
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text,
        cityId: _selectedCityId!,
        address: _addressController.text.trim(),
        idProof: _idProofFile!,
        profitAccount: _profitAccountController.text.trim(),
        commercialRegister: _crController.text.trim(),
        coverImage: _coverImageFile!,
      );
    }
  }

  // TODO: the design uses custom gold line icons; export them from Figma as
  // SVG to replace these Material approximations.
  IconData _getCategoryIcon(String name) {
    if (name.contains('كوشة')) return Icons.weekend_outlined;
    if (name.contains('صالات')) return Icons.festival_outlined;
    if (name.contains('كوافير')) return Icons.face_retouching_natural_outlined;
    if (name.contains('تصوير')) return Icons.photo_camera_outlined;
    if (name.contains('فساتين')) return Icons.checkroom_outlined;
    if (name.contains('بدلات')) return Icons.dry_cleaning_outlined;
    if (name.contains('ورد')) return Icons.local_florist_outlined;
    if (name.contains('دي جي')) return Icons.speaker_outlined;
    if (name.contains('تزيين سيارات')) return Icons.directions_car_outlined;
    if (name.contains('كروت')) return Icons.mail_outline;
    if (name.contains('كيك')) return Icons.cake_outlined;
    if (name.contains('تأجير سيارات')) return Icons.local_shipping_outlined;
    return Icons.business_center_outlined;
  }

  /// Categories visible in the collapsed row; keeps the selected one visible.
  List<dynamic> _visibleCategories() {
    if (_showAllCategories || _categories.length <= _collapsedCount) {
      return _categories;
    }
    final visible = _categories.take(_collapsedCount).toList();
    final selected = _categories.where(
      (c) => c['id'].toString() == _selectedCategoryId,
    );
    if (selected.isNotEmpty && !visible.contains(selected.first)) {
      visible[_collapsedCount - 1] = selected.first;
    }
    return visible;
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _section({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _note(String text, Color primary) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: _noteFill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: primary, fontSize: 10),
            ),
          ),
          const SizedBox(width: 6),
          Icon(Icons.info_outline, color: primary, size: 16),
        ],
      ),
    );
  }

  Widget _categoryTile(dynamic cat, Color primary, Color gold) {
    final isSelected = _selectedCategoryId == cat['id'].toString();
    return InkWell(
      onTap: () => setState(() => _selectedCategoryId = cat['id'].toString()),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _selectedFill : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : _tileBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getCategoryIcon(cat['name'].toString()), color: gold, size: 28),
            const SizedBox(height: 8),
            Text(
              cat['name'].toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? primary : Colors.black87,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categories_(Color primary, Color gold, bool saving) {
    if (_categories.isEmpty) {
      return saving
          ? const SizedBox.shrink()
          : const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
    }
    final visible = _visibleCategories();
    if (!_showAllCategories) {
      return Row(
        children: [
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: _categoryTile(visible[i], primary, gold),
              ),
            ),
          ],
          for (var i = visible.length; i < _collapsedCount; i++) ...[
            const SizedBox(width: 10),
            const Expanded(child: SizedBox()),
          ],
        ],
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: visible.length,
      itemBuilder: (context, index) =>
          _categoryTile(visible[index], primary, gold),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final gold = theme.colorScheme.secondary;
    const hintStyle = TextStyle(color: _hint, fontSize: 12);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'بيانات الحساب',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocConsumer<ProviderOnboardingCubit, ProviderOnboardingState>(
        listener: (context, state) {
          if (state is ProviderOnboardingSuccess) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.providerVerification,
            );
          } else if (state is ProviderOnboardingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProviderOnboardingLoading ||
              state is ProviderOnboardingInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProviderOnboardingLoaded) {
            _categories = state.categories;
            _cities = state.cities;
          }
          final saving = state is ProviderOnboardingSaving;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'الخطوة الأولى: بيانات النشاط',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 1 / 3,
                      minHeight: 8,
                      color: primary,
                      backgroundColor: const Color(0xFFE8E2E4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ابدأ بتسجيل بيانات متجرك وخدماتك لتلقي الحجوزات المباشرة بكل موثوقية.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _section(
                    children: [
                      _buildLabel('اسم العمل/النشاط', theme),
                      TextFormField(
                        controller: _businessNameController,
                        decoration: const InputDecoration(
                          hintText: 'ادخل اسم النشاط',
                          hintStyle: hintStyle,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLabel('فئة الخدمة', theme),
                          if (_categories.length > _collapsedCount)
                            InkWell(
                              onTap: () => setState(
                                () => _showAllCategories = !_showAllCategories,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'عرض الكل',
                                      style: TextStyle(
                                        color: primary,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Icon(
                                      _showAllCategories
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: primary,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      _categories_(primary, gold, saving),
                      const SizedBox(height: 18),
                      _buildLabel('وصف قصير للخدمة', theme),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'نبذة مختصرة تظهر في بطاقة عرض الخدمة',
                          hintStyle: hintStyle,
                          constraints: BoxConstraints(),
                          contentPadding: EdgeInsets.all(12),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  _section(
                    children: [
                      _buildLabel('عنوان العمل', theme),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCityId,
                        icon: Icon(Icons.keyboard_arrow_down, color: primary),
                        decoration: InputDecoration(
                          hintText: _cities.isEmpty
                              ? 'تعذّر تحميل المناطق'
                              : 'اختر منطقتك',
                          hintStyle: hintStyle,
                          prefixIcon: Icon(Icons.my_location, color: primary),
                        ),
                        items: _cities.isEmpty
                            ? null
                            : _cities.map<DropdownMenuItem<String>>((city) {
                                return DropdownMenuItem<String>(
                                  value: city['id'].toString(),
                                  child: Text(city['name']),
                                );
                              }).toList(),
                        onChanged: _cities.isEmpty
                            ? null
                            : (val) => setState(() => _selectedCityId = val),
                        validator: (val) => val == null ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      // Not in the design: the API requires an address, and
                      // this field was approved separately.
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'العنوان التفصيلي: الحي، الشارع، أقرب معلم',
                          hintStyle: hintStyle,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'مطلوب'
                            : null,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  _section(
                    children: [
                      _buildLabel('إثبات الهوية', theme),
                      InkWell(
                        onTap: () => _pickImage(true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _tileBorder),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _idProofFile != null
                                      ? _idProofFile!.path.split('/').last
                                      : 'صورة سلفي مع الهوية الشخصية',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _idProofFile != null
                                      ? const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                        )
                                      : hintStyle,
                                ),
                              ),
                              Icon(Icons.image_outlined, color: primary),
                            ],
                          ),
                        ),
                      ),
                      _note(
                        'للمصادقة على موثوقية مزودي الخدمات داخل منصتنا',
                        primary,
                      ),
                      const SizedBox(height: 10),
                      _buildLabel('حساب استلام الأرباح', theme),
                      TextFormField(
                        controller: _profitAccountController,
                        decoration: const InputDecoration(
                          hintText:
                              'أدخل رقم الحساب البنكي / المحفظة الإلكترونية',
                          hintStyle: hintStyle,
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'مطلوب' : null,
                      ),
                      _note('سيتم التحويل من حجوزات عملك على هذا الحساب', primary),
                      const SizedBox(height: 10),
                      _buildLabel('رقم السجل التجاري (ان وجد)', theme),
                      TextFormField(
                        controller: _crController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'ادخل رقم السجل التجاري',
                          hintStyle: hintStyle,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  _section(
                    children: [
                      _buildLabel('صورة الغلاف', theme),
                      InkWell(
                        onTap: () => _pickImage(false),
                        borderRadius: BorderRadius.circular(12),
                        child: CustomPaint(
                          painter: DashedBorderPainter(
                            color: primary.withValues(alpha: 0.6),
                          ),
                          child: SizedBox(
                            height: 120,
                            width: double.infinity,
                            child: _coverImageFile != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _coverImageFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: primary,
                                        size: 22,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'إضغط للرفع',
                                        style: TextStyle(
                                          color: primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Text(
                          'جميع وثائقك ومعلوماتك محمية ومشفرة وفق أعلى معايير الخصوصية لن يتم مشاركة صور الهوية أو المستندات الرسمية مع أي أطراف تجارية أخرى.',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 11,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.lock_outline, color: primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: saving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: saving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'التالي',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text.rich(
                        TextSpan(
                          text: 'لديك حساب بالفعل؟ ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: 'تسجيل دخول',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
