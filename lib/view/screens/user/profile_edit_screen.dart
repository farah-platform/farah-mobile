import 'dart:io';

import 'package:farah/core/constants/app_colors.dart';
import 'package:farah/cubits/profile_edit/profile_edit_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  File? _pickedFile;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileEditCubit>().load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _regionCtrl.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1080,
    );
    if (picked != null) {
      setState(() {
        _pickedFile = File(picked.path);
        _dirty = true;
      });
    }
  }

  void _save() {
    context.read<ProfileEditCubit>().save(
      name: _nameCtrl.text,
      phone: _phoneCtrl.text,
      region: _regionCtrl.text,
      avatar: _pickedFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<ProfileEditCubit, ProfileEditState>(
        listener: (context, state) {
          if (state is ProfileEditReady && !state.dirty) {
            if (_nameCtrl.text.isEmpty) {
              _nameCtrl.text = state.user.name;
              _phoneCtrl.text = state.user.phone;
              _regionCtrl.text = state.user.region;
            }
          }
          if (state is ProfileEditSuccess) {
            Navigator.of(context).pop(true);
          }
          if (state is ProfileEditError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isSaving = state is ProfileEditSaving;
          final fieldErrors = state is ProfileEditReady
              ? state.fieldErrors
              : <String, String>{};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.15,
                        ),
                        backgroundImage: _pickedFile != null
                            ? FileImage(_pickedFile!)
                            : null,
                        child: _pickedFile == null
                            ? Transform.flip(
                                flipX:
                                    false, // Mallattoo gara bitaatti garagalcha
                                child: const Icon(
                                  Icons.person,
                                  size: 52,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildField(
                  controller: _nameCtrl,
                  label: 'الاسم كامل',
                  icon: Icons.person_outline,
                  errorText: fieldErrors['name'],
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'رقم الجوال',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  errorText: fieldErrors['phone'],
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: _regionCtrl,
                  label: 'العنوان',
                  icon: Icons.location_on_outlined,
                  errorText: fieldErrors['region'],
                  onChanged: (_) => _onFieldChanged(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: (!_dirty || isSaving) ? null : _save,
                    child: isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'حفظ التغييرات',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(icon, color: AppColors.primary),
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
