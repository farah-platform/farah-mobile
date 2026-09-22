import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_verification/provider_verification_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends State<ProviderVerificationScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderVerificationCubit>().checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('معلومات الخدمة'), centerTitle: true),
      body: BlocConsumer<ProviderVerificationCubit, ProviderVerificationState>(
        listener: (context, state) {
          if (state is ProviderVerificationLoaded) {
            if (state.status == 'approved') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.providerSubscriptionPlans,
                (route) => false,
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ProviderVerificationLoading ||
              state is ProviderVerificationInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          String msg = 'جاري التحقق من بياناتك...';
          if (state is ProviderVerificationLoaded) msg = state.message;
          if (state is ProviderVerificationError) msg = state.message;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'الخطوة الثانية: توثيق الحساب',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const LinearProgressIndicator(value: 0.66),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'حالة التدقيق الحالية:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(msg),
                    ],
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    context.read<ProviderVerificationCubit>().checkStatus();
                  },
                  child: const Text('تحديث الحالة'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
