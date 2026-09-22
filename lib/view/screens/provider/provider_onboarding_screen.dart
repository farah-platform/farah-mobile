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
  final _crController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCityId;
  File? _idProof;
  File? _coverImage;

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
    _crController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isIdProof) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isIdProof) {
          _idProof = File(picked.path);
        } else {
          _coverImage = File(picked.path);
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null ||
          _selectedCityId == null ||
          _idProof == null ||
          _coverImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء تعبئة جميع الحقول المطلوبة وإرفاق الصور'),
          ),
        );
        return;
      }
      context.read<ProviderOnboardingCubit>().submit(
        businessName: _businessNameController.text.trim(),
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text.trim(),
        cityId: _selectedCityId!,
        idProof: _idProof!,
        profitAccount: _profitAccountController.text.trim(),
        commercialRegister: _crController.text.trim(),
        coverImage: _coverImage!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('بيانات الحساب'), centerTitle: true),
      body: BlocConsumer<ProviderOnboardingCubit, ProviderOnboardingState>(
        listener: (context, state) {
          if (state is ProviderOnboardingSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.providerVerification,
              (route) => false,
            );
          } else if (state is ProviderOnboardingError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProviderOnboardingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List categories = [];
          List cities = [];
          if (state is ProviderOnboardingLoaded) {
            categories = state.categories;
            cities = state.cities;
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(value: 0.33),
                  const SizedBox(height: 16),
                  Text(
                    'ابدأ بتسجيل بيانات متجرك وخدماتك لتلقي الحجوزات المباشرة بكل موثوقية.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('اسم المحل/النشاط', theme),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: const InputDecoration(
                      hintText: 'أدخل اسم النشاط',
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('فئة الخدمة', theme),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final isSelected =
                          _selectedCategoryId == cat['id'].toString();
                      return ChoiceChip(
                        label: Text(cat['name']),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(
                            () => _selectedCategoryId = cat['id'].toString(),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  if (categories.isEmpty && state is! ProviderOnboardingInitial)
                    const Text(
                      'لا توجد فئات متاحة حالياً',
                      style: TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 16),

                  _buildLabel('وصف قصير للخدمة', theme),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'نبذة مختصرة تظهر في بطاقة عرض الخدمة',
                    ),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('عنوان العمل', theme),
                  DropdownButtonFormField<String>(
                    value: _selectedCityId,
                    decoration: const InputDecoration(hintText: 'اختر منطقتك'),
                    items: cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city['id'].toString(),
                        child: Text(city['name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCityId = val),
                    validator: (val) => val == null ? 'مطلوب' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('إثبات الهوية', theme),
                  InkWell(
                    onTap: () => _pickImage(true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.image, color: primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _idProof != null
                                  ? _idProof!.path.split('/').last
                                  : 'صورة سلفي مع الهوية الشخصية',
                              style: TextStyle(
                                color: _idProof != null
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
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
                  const SizedBox(height: 16),

                  _buildLabel('رقم السجل التجاري (إن وجد)', theme),
                  TextFormField(
                    controller: _crController,
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
                          color: primary,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: primary.withValues(alpha: 0.05),
                      ),
                      child: _coverImage != null
                          ? Image.file(_coverImage!, fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, color: primary),
                                const SizedBox(height: 8),
                                Text(
                                  'إضغط للرفع',
                                  style: TextStyle(color: primary),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: state is ProviderOnboardingSaving
                        ? null
                        : _submit,
                    child: state is ProviderOnboardingSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('التالي'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
