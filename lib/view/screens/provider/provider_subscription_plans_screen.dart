import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_subscription/provider_subscription_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderSubscriptionPlansScreen extends StatefulWidget {
  const ProviderSubscriptionPlansScreen({super.key});

  @override
  State<ProviderSubscriptionPlansScreen> createState() =>
      _ProviderSubscriptionPlansScreenState();
}

class _ProviderSubscriptionPlansScreenState
    extends State<ProviderSubscriptionPlansScreen> {
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    context.read<ProviderSubscriptionCubit>().fetchPlans();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('الاشتراك'), centerTitle: true),
      body: BlocBuilder<ProviderSubscriptionCubit, ProviderSubscriptionState>(
        builder: (context, state) {
          if (state is ProviderSubscriptionLoading ||
              state is ProviderSubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          List plans = [];
          if (state is ProviderSubscriptionPlansLoaded) {
            plans = state.plans;
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'الخطوة الثالثة: تفعيل الاشتراك',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const LinearProgressIndicator(value: 1.0),
                const SizedBox(height: 24),

                Text(
                  'اختر الخطة المناسبة لنشاطك',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final isSelected =
                          _selectedPlanId == plan['slug'].toString();

                      return GestureDetector(
                        onTap: () => setState(
                          () => _selectedPlanId = plan['slug'].toString(),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    plan['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${plan['price']} ILS',
                                    style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                plan['description'] ?? '',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                ElevatedButton(
                  onPressed: _selectedPlanId == null
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.providerActivateSubscription,
                            arguments: _selectedPlanId,
                          );
                        },
                  child: const Text('تفعيل الاشتراك'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
