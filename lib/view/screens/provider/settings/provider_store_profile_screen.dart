import 'dart:io';

import 'package:farah/cubits/provider_settings/provider_store_settings_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/settings/provider_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// فرح: "بيانات المتجر" حسب التصميم: الغلاف والشعار، اسم المتجر، فئة الخدمة، الوصف،
// عنوان العمل ورقم السجل التجاري. يحفظ عبر POST /provider/profile بدون إعادة الحساب للمراجعة.
class ProviderStoreProfileScreen extends StatefulWidget {
  const ProviderStoreProfileScreen({super.key});

  @override
  State<ProviderStoreProfileScreen> createState() =>
      _ProviderStoreProfileScreenState();
}

class _ProviderStoreProfileScreenState
    extends State<ProviderStoreProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _registerController = TextEditingController();
  String? _categoryId;
  String? _cityId;
  File? _cover;
  File? _logo;
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderStoreSettingsCubit>().load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _registerController.dispose();
    super.dispose();
  }

  void _fill(Map<String, dynamic> profile) {
    if (_filled) return;
    _filled = true;
    _nameController.text = profile['business_name']?.toString() ?? '';
    _descriptionController.text = profile['description']?.toString() ?? '';
    _addressController.text = profile['address']?.toString() ?? '';
    _registerController.text =
        profile['commercial_register_number']?.toString() ?? '';
    _categoryId = (profile['category'] as Map?)?['id']?.toString();
    _cityId = (profile['city'] as Map?)?['id']?.toString();
  }

  Future<File?> _pick() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1600,
    );
    return picked == null ? null : File(picked.path);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProviderStoreSettingsCubit>().saveProfile(
      {
        'business_name': _nameController.text.trim(),
        'category_id': ?_categoryId,
        'description': _descriptionController.text.trim(),
        'city_id': _cityId,
        'address': _addressController.text.trim(),
        'commercial_register_number': _registerController.text.trim(),
      },
      _cover,
      logo: _logo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'بيانات المتجر'),
      body: BlocConsumer<ProviderStoreSettingsCubit, ProviderStoreSettingsState>(
        listener: (context, state) {
          if (state.saved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم حفظ بيانات المتجر')),
            );
            Navigator.pop(context, true);
          } else if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          _fill(state.profile);
          final categories = [
            for (final c in state.categories)
              if (c is Map) c,
          ];
          // Keep the saved category selectable even if it's no longer listed.
          final categoryIds = categories.map((c) => c['id'].toString());
          final categoryValue = categoryIds.contains(_categoryId)
              ? _categoryId
              : null;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 12, 32, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _coverAndLogo(state.profile, primary),
                        const SizedBox(height: 12),
                        const ProviderFieldLabel('اسم المتجر'),
                        TextFormField(
                          controller: _nameController,
                          decoration: providerFieldDecoration(
                            hint: 'اسم المتجر',
                          ),
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'أدخل اسم المتجر'
                              : null,
                        ),
                        ProviderFieldLabel('فئة الخدمة', color: primary),
                        DropdownButtonFormField<String>(
                          initialValue: categoryValue,
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: primary,
                            size: 28,
                          ),
                          decoration: providerFieldDecoration(
                            hint: 'اختر فئة الخدمة',
                          ),
                          items: [
                            for (final c in categories)
                              DropdownMenuItem(
                                value: c['id'].toString(),
                                child: Text(c['name']?.toString() ?? ''),
                              ),
                          ],
                          onChanged: (v) => setState(() => _categoryId = v),
                          validator: (v) =>
                              v == null ? 'اختر فئة الخدمة' : null,
                        ),
                        ProviderFieldLabel('وصف المتجر', color: primary),
                        TextFormField(
                          controller: _descriptionController,
                          minLines: 2,
                          maxLines: 6,
                          decoration: providerFieldDecoration(
                            hint: 'اكتب نبذة عن متجرك',
                          ),
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'أدخل وصف المتجر'
                              : null,
                        ),
                        // The design has no city field; it only shows up
                        // when the store has none yet (the API needs it).
                        if (_cityId == null || state.profile['city'] == null)
                          ..._cityField(state.cities, primary),
                        ProviderFieldLabel('عنوان العمل', color: primary),
                        TextFormField(
                          controller: _addressController,
                          decoration: providerFieldDecoration(
                            hint: 'مثال: غزة - شارع عمر المختار',
                          ),
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? 'أدخل عنوان العمل'
                              : null,
                        ),
                        ProviderFieldLabel(
                          'رقم السجل التجاري (إن وجد)',
                          color: primary,
                        ),
                        TextFormField(
                          controller: _registerController,
                          keyboardType: TextInputType.text,
                          decoration: providerFieldDecoration(hint: 'اختياري'),
                          validator: (v) => (v ?? '').trim().length > 50
                              ? 'الرقم طويل جداً'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ProviderBottomAction(
                child: ProviderPrimaryButton(
                  label: 'حفظ التغيرات',
                  loading: state.saving,
                  onPressed: _save,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _cityField(List<dynamic> cities, Color primary) => [
    ProviderFieldLabel('المدينة', color: primary),
    DropdownButtonFormField<String>(
      initialValue: _cityId,
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: primary, size: 28),
      decoration: providerFieldDecoration(hint: 'اختر المدينة'),
      items: [
        for (final c in cities)
          if (c is Map)
            DropdownMenuItem(
              value: c['id'].toString(),
              child: Text(c['name']?.toString() ?? ''),
            ),
      ],
      onChanged: (v) => setState(() => _cityId = v),
      validator: (v) => v == null ? 'اختر المدينة' : null,
    ),
  ];

  Widget _coverAndLogo(Map<String, dynamic> profile, Color primary) {
    final coverUrl = profile['cover_image']?.toString() ?? '';
    final logoUrl = profile['logo']?.toString() ?? '';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          key: const Key('store_cover'),
          onTap: () async {
            final file = await _pick();
            if (file != null) setState(() => _cover = file);
          },
          borderRadius: BorderRadius.circular(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 135,
              width: double.infinity,
              child: _cover != null
                  ? Image.file(_cover!, fit: BoxFit.cover)
                  : coverUrl.isNotEmpty
                  ? Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _coverHint(primary),
                    )
                  : _coverHint(primary),
            ),
          ),
        ),
        // The logo sits on the cover's bottom start corner with an edit badge.
        PositionedDirectional(
          start: -4,
          bottom: -16,
          child: GestureDetector(
            key: const Key('store_logo'),
            onTap: () async {
              final file = await _pick();
              if (file != null) setState(() => _logo = file);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF3DDE4),
                    border: Border.all(color: Colors.white, width: 2),
                    image: _logo != null
                        ? DecorationImage(
                            image: FileImage(_logo!),
                            fit: BoxFit.cover,
                          )
                        : logoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                            onError: (_, _) {},
                          )
                        : null,
                  ),
                  child: _logo == null && logoUrl.isEmpty
                      ? Icon(Icons.storefront_outlined, color: primary)
                      : null,
                ),
                PositionedDirectional(
                  end: 0,
                  bottom: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A0423),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _coverHint(Color primary) {
    return CustomPaint(
      painter: DashedBorderPainter(color: primary.withValues(alpha: 0.6)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: primary, size: 30),
            const SizedBox(height: 4),
            const Text(
              'أضف صورة غلاف المتجر',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
