import 'dart:io';
import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_subscription/provider_subscription_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ProviderActivateSubscriptionScreen extends StatefulWidget {
  final String planId;
  const ProviderActivateSubscriptionScreen({super.key, required this.planId});

  @override
  State<ProviderActivateSubscriptionScreen> createState() =>
      _ProviderActivateSubscriptionScreenState();
}

class _ProviderActivateSubscriptionScreenState
    extends State<ProviderActivateSubscriptionScreen> {
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  File? _receiptImage;

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _receiptImage = File(picked.path);
      });
    }
  }

  void _submit() {
    if (_bankNameController.text.isEmpty ||
        _accountNumberController.text.isEmpty ||
        _receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تعبئة جميع الحقول وإرفاق صورة الإيصال'),
        ),
      );
      return;
    }

    context.read<ProviderSubscriptionCubit>().activateSubscription(
      planId: widget.planId,
      bankName: _bankNameController.text,
      accountNumber: _accountNumberController.text,
      receiptImage: _receiptImage!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('تفعيل الاشتراك'), centerTitle: true),
      body: BlocConsumer<ProviderSubscriptionCubit, ProviderSubscriptionState>(
        listener: (context, state) {
          if (state is ProviderSubscriptionSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.providerSubscriptionSuccess,
              (route) => false,
            );
          } else if (state is ProviderSubscriptionError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'بيانات التحويل البنكي المعتمد',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'يرجى إتمام عملية التحويل البنكي على الحساب التالي ورفع الإيصال',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                const Text(
                  'مكان التحويل',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _bankNameController,
                  decoration: const InputDecoration(hintText: 'اسم البنك'),
                ),
                const SizedBox(height: 16),

                const Text(
                  'رقم الحساب',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(
                    hintText: 'رقم الحساب البنكي',
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'إشعار التحويل البنكي',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: primary,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: primary.withValues(alpha: 0.05),
                    ),
                    child: _receiptImage != null
                        ? Image.file(_receiptImage!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, color: primary),
                              const SizedBox(height: 8),
                              Text(
                                'رفع إشعار التحويل البنكي',
                                style: TextStyle(color: primary),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: state is ProviderSubscriptionActivating
                      ? null
                      : _submit,
                  child: state is ProviderSubscriptionActivating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تأكيد'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
