import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_verification/provider_verification_cubit.dart';

class ProviderRouterScreen extends StatefulWidget {
  const ProviderRouterScreen({super.key});

  @override
  State<ProviderRouterScreen> createState() => _ProviderRouterScreenState();
}

class _ProviderRouterScreenState extends State<ProviderRouterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderVerificationCubit>().checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProviderVerificationCubit, ProviderVerificationState>(
        listener: (context, state) {
          if (state is ProviderVerificationLoaded) {
            if (state.status == 'active' || state.status == 'approved') {
              Navigator.pushReplacementNamed(context, AppRoutes.providerHome);
            } else if (state.nextStep == 'onboarding' || state.status == 'not_started') {
              Navigator.pushReplacementNamed(context, AppRoutes.providerOnboarding);
            } else if (state.nextStep == 'subscription') {
              Navigator.pushReplacementNamed(context, AppRoutes.providerSubscriptionPlans);
            } else {
              // Usually pending
              Navigator.pushReplacementNamed(context, AppRoutes.providerVerification);
            }
          } else if (state is ProviderVerificationError) {
             // Fallback
             Navigator.pushReplacementNamed(context, AppRoutes.providerOnboarding);
          }
        },
        builder: (context, state) {
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
