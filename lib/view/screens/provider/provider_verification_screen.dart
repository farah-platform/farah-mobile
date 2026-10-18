import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_verification/provider_verification_cubit.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() => _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState extends State<ProviderVerificationScreen> {
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
            if (state.status == 'approved' || state.nextStep == 'subscription') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.providerSubscriptionPlans,
                (route) => false,
              );
            } else if (state.status == 'active') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.providerHome,
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
                const Spacer(),
                const Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
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
