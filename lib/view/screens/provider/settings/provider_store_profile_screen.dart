import 'dart:io';

import 'package:farah/cubits/provider_settings/provider_store_settings_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// "بيانات المتجر": edits the store's name, description, city, address and
/// cover without sending the account back to review.
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
  String? _cityId;
  File? _cover;
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
    super.dispose();
  }

  void _fill(Map<String, dynamic> profile) {
    if (_filled) return;
    _filled = true;
    _nameController.text = profile['business_name']?.toString() ?? '';
    _descriptionController.text = profile['description']?.toString() ?? '';
    _addressController.text = profile['address']?.toString() ?? '';
    _cityId = (profile['city'] as Map?)?['id']?.toString();
  }

  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _cover = File(picked.path));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProviderStoreSettingsCubit>().saveProfile({
      'business_name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'city_id': _cityId,
      'address': _addressController.text.trim(),
    }, _cover);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'بيانات المتجر'),
      body:
          BlocConsumer<ProviderStoreSettingsCubit, ProviderStoreSettingsState>(
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
              final coverUrl = state.profile['cover_image']?.toString();
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: _pickCover,
                        borderRadius: BorderRadius.circular(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 150,
                            child: _cover != null
                                ? Image.file(_cover!, fit: BoxFit.cover)
                                : coverUrl != null && coverUrl.isNotEmpty
                                ? Image.network(
                                    coverUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        _coverHint(primary),
                                  )
                                : _coverHint(primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'اضغط على الصورة لتغيير غلاف المتجر',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      _label('اسم المتجر'),
                      TextFormField(
                        controller: _nameController,
                        decoration: _input('اسم المتجر'),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'أدخل اسم المتجر' : null,
                      ),
                      _label('وصف المتجر'),
                      TextFormField(
                        controller: _descriptionController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: _input('اكتب نبذة عن متجرك'),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'أدخل وصف المتجر' : null,
                      ),
                      _label('المدينة'),
                      DropdownButtonFormField<String>(
                        initialValue: _cityId,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: primary),
                        decoration: _input('اختر المدينة'),
                        items: [
                          for (final c in state.cities)
                            DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['name']?.toString() ?? ''),
                            ),
                        ],
                        onChanged: (v) => setState(() => _cityId = v),
                        validator: (v) => v == null ? 'اختر المدينة' : null,
                      ),
                      _label('العنوان التفصيلي'),
                      TextFormField(
                        controller: _addressController,
                        decoration: _input('مثال: غزة - الرمال'),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? 'أدخل العنوان' : null,
                      ),
                      const SizedBox(height: 28),
                      ProviderPrimaryButton(
                        label: 'حفظ التعديلات',
                        loading: state.saving,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _coverHint(Color primary) {
    return CustomPaint(
      painter: DashedBorderPainter(color: primary.withValues(alpha: 0.6)),
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: primary,
          size: 32,
        ),
      ),
    );
  }
}

Widget _label(String text) => Padding(
  padding: const EdgeInsets.only(top: 18, bottom: 8),
  child: Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  ),
);

InputDecoration _input(String hint) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c),
  );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    enabledBorder: border(const Color(0xFFDADADA)),
    border: border(const Color(0xFFDADADA)),
  );
}
