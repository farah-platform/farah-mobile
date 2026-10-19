import 'dart:io';

import 'package:farah/cubits/profile_edit/profile_edit_cubit.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:farah/view/widgets/provider/settings/provider_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// فرح: "تعديل الملف الشخصي" للمزود حسب التصميم: الصورة، الاسم كامل، رقم الجوال، العنوان.
// يستخدم ProfileEditCubit نفسه (GET /profile و POST /profile/update).
class ProviderProfileEditScreen extends StatefulWidget {
  const ProviderProfileEditScreen({super.key});

  @override
  State<ProviderProfileEditScreen> createState() =>
      _ProviderProfileEditScreenState();
}

class _ProviderProfileEditScreenState extends State<ProviderProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  File? _avatar;
  String? _avatarUrl;
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    context.read<ProfileEditCubit>().load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1080,
    );
    if (picked != null) setState(() => _avatar = File(picked.path));
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileEditCubit>().save(
      name: _nameController.text,
      phone: _phoneController.text,
      region: _addressController.text,
      avatar: _avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'تعديل الملف الشخصي'),
      body: BlocConsumer<ProfileEditCubit, ProfileEditState>(
        listener: (context, state) {
          if (state is ProfileEditReady && !_filled) {
            _filled = true;
            _nameController.text = state.user.name;
            _phoneController.text = state.user.phone;
            _addressController.text = state.user.region;
            setState(() => _avatarUrl = state.user.avatar);
          } else if (state is ProfileEditSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تم حفظ التغييرات')));
            Navigator.pop(context, true);
          } else if (state is ProfileEditError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProfileEditInitial || state is ProfileEditLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileEditError && !_filled) {
            return Center(
              child: TextButton.icon(
                onPressed: () => context.read<ProfileEditCubit>().load(),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            );
          }
          final saving = state is ProfileEditSaving;
          final errors = state is ProfileEditReady
              ? state.fieldErrors
              : const <String, String>{};
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: _avatarPicker(primary)),
                        const SizedBox(height: 30),
                        const ProviderFieldLabel('الاسم كامل', bold: false),
                        TextFormField(
                          controller: _nameController,
                          decoration: providerFieldDecoration(
                            hint: 'الاسم كامل',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: primary,
                            ),
                            borderColor: kProviderOutlinedFieldBorder,
                            errorText: errors['name'],
                          ),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? 'أدخل الاسم' : null,
                        ),
                        const ProviderFieldLabel('رقم الجوال', bold: false),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: providerFieldDecoration(
                            hint: 'رقم الجوال',
                            prefixIcon: Icon(
                              Icons.phone_android_outlined,
                              color: primary,
                            ),
                            borderColor: kProviderOutlinedFieldBorder,
                            errorText: errors['phone'],
                          ),
                        ),
                        const ProviderFieldLabel('العنوان', bold: false),
                        TextFormField(
                          controller: _addressController,
                          decoration: providerFieldDecoration(
                            hint: 'العنوان',
                            prefixIcon: Icon(
                              Icons.my_location_outlined,
                              color: primary,
                            ),
                            borderColor: kProviderOutlinedFieldBorder,
                            errorText: errors['region'],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ProviderBottomAction(
                child: ProviderPrimaryButton(
                  label: 'حفظ التغيرات',
                  loading: saving,
                  onPressed: _save,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _avatarPicker(Color primary) {
    final url = _avatarUrl ?? '';
    return GestureDetector(
      key: const Key('profile_avatar'),
      onTap: _pickAvatar,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF3DDE4),
              image: _avatar != null
                  ? DecorationImage(
                      image: FileImage(_avatar!),
                      fit: BoxFit.cover,
                    )
                  : url.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                      onError: (_, _) {},
                    )
                  : null,
            ),
            child: _avatar == null && url.isEmpty
                ? Icon(Icons.person, size: 56, color: primary)
                : null,
          ),
          // Edit badge on the bottom end (left in RTL), like the design.
          PositionedDirectional(
            end: 2,
            bottom: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF5A0423),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, size: 15, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
