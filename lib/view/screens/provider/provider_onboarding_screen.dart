import 'dart:io';

import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_onboarding/provider_onboarding_cubit.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _profitAccountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _crController = TextEditingController();
  
  String? _selectedCategoryId;
  String? _selectedCityId;
  File? _idProofFile;
  File? _coverImageFile;
  List<dynamic> _categories = [];
  List<dynamic> _cities = [];

  @override
  void initState() {
    super.initState();
    context.read<ProviderOnboardingCubit>().loadData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    _profitAccountController.dispose();
    _accountNumberController.dispose();
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
        profitAccount: _profitAccountController.text,
        idProof: _idProofFile!,
        commercialRegister: _crController.text,
        coverImage: _coverImageFile!,
      );
    }
  }

  IconData _getCategoryIcon(String name) {
    if (name.contains('كوشة')) return Icons.weekend_outlined;
    if (name.contains('صالات')) return Icons.apartment_outlined;
    if (name.contains('كوافير')) return Icons.content_cut;
    if (name.contains('تصوير')) return Icons.camera_alt_outlined;
    if (name.contains('فساتين')) return Icons.checkroom_outlined;
    if (name.contains('ورد')) return Icons.local_florist_outlined;
    if (name.contains('دي جي')) return Icons.headphones_outlined;
    if (name.contains('تزيين سيارات')) return Icons.directions_car_outlined;
    if (name.contains('كروت')) return Icons.mail_outline;
    if (name.contains('كيك')) return Icons.cake_outlined;
    if (name.contains('تأجير سيارات')) return Icons.car_rental;
    return Icons.business_center_outlined;
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات الحساب'),
        centerTitle: true,
      ),
      body: BlocConsumer<ProviderOnboardingCubit, ProviderOnboardingState>(
        listener: (context, state) {
          if (state is ProviderOnboardingSuccess) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.providerVerification,
            );
          } else if (state is ProviderOnboardingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is ProviderOnboardingLoading || state is ProviderOnboardingInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProviderOnboardingLoaded) {
            _categories = state.categories;
            _cities = state.cities;
          } else if (state is ProviderOnboardingSaving) {
            // Keep previous UI state (or show a loading overlay later)
            // But we can't easily get the categories here if state doesn't hold them. 
            // Usually we'd use a copyWith or keep them in the UI state.
            // Let's just render what we have.
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'الخطوة الأولى: بيانات النشاط',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ بتسجيل بيانات متجرك وخدماتك لتلقي الحجوزات المباشرة بكل موثوقية.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('اسم العمل/النشاط', theme),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      hintText: 'ادخل اسم النشاط',
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('فئة الخدمة', theme),
                      Text(
                        'عرض الكل',
                        style: TextStyle(color: primary, fontSize: 12),
                      ),
                    ],
                  ),
                  
                  if (_categories.isEmpty && state is! ProviderOnboardingSaving)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_categories.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategoryId == cat['id'].toString();
                        return InkWell(
                          onTap: () => setState(() => _selectedCategoryId = cat['id'].toString()),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? primary : Colors.grey.shade300, 
                                width: 1.5
                              ),
                              color: isSelected ? primary.withAlpha(15) : Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getCategoryIcon(cat['name'].toString()), 
                                  color: isSelected ? primary : Colors.grey.shade400, 
                                  size: 28
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat['name'], 
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? primary : Colors.grey.shade700, 
                                    fontSize: 12, 
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                  )
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),

                  _buildLabel('وصف قصير للخدمة', theme),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'نبذة مختصرة تظهر في بطاقة عرض الخدمة',
                      constraints: BoxConstraints(), // Fix height issue
                      contentPadding: EdgeInsets.all(12),
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('عنوان العمل', theme),
                  DropdownButtonFormField<String>(
                    value: _selectedCityId,
                    decoration: InputDecoration(
                      hintText: _cities.isEmpty ? 'لا يوجد اتصال' : 'اختر منطقتك',
                      errorText: _cities.isEmpty ? 'خطأ 500: لم يتم تحميل المناطق من السيرفر' : null,
                      suffixIcon: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
                    ),
                    items: _cities.isEmpty ? null : _cities.map<DropdownMenuItem<String>>((city) {
                      return DropdownMenuItem<String>(
                        value: city['id'].toString(),
                        child: Text(city['name']),
                      );
                    }).toList(),
                    onChanged: _cities.isEmpty ? null : (val) => setState(() => _selectedCityId = val),
                    validator: (val) => val == null ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('إثبات الهوية', theme),
                  InkWell(
                    onTap: () => _pickImage(true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.image_outlined, color: primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _idProofFile != null
                                  ? _idProofFile!.path.split('/').last
                                  : 'صورة سيلفي مع الهوية الشخصية',
                              style: TextStyle(
                                color: _idProofFile != null
                                    ? Colors.black
                                    : Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: primary, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'للمصادقة على موثوقية مزود الخدمات داخل منصتنا',
                            style: TextStyle(color: primary, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('حساب استلام الأرباح', theme),
                  TextFormField(
                    controller: _profitAccountController,
                    decoration: const InputDecoration(
                      hintText: 'أدخل رقم الحساب البنكي / المحفظة الإلكترونية',
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'مطلوب' : null,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: primary, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'سيتم التحويل من دوريات عملك على هذا الحساب',
                            style: TextStyle(color: primary, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('رقم الحساب', theme),
                  TextFormField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'أدخل رقم الحساب',
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('رقم السجل التجاري (إن وجد)', theme),
                  TextFormField(
                    controller: _crController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'أدخل رقم السجل التجاري',
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('صورة الغلاف', theme),
                  InkWell(
                    onTap: () => _pickImage(false),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: primary.withAlpha(100),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _coverImageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _coverImageFile!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    color: primary, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'إضغط للرفع',
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, color: primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'جميع بياناتك ومعلوماتك محمية ومشفرة وفق أعلى معايير الخصوصية. لن يتم مشاركتها مع أي أطراف تجارية أخرى.',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 10,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  ElevatedButton(
                    onPressed: state is ProviderOnboardingSaving ? null : _submit,
                    child: state is ProviderOnboardingSaving 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('التالي'),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text.rich(
                        TextSpan(
                          text: 'لديك حساب بالفعل؟ ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

