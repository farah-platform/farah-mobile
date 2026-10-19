import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/provider_orders/provider_orders_cubit.dart';
import 'package:farah/view/widgets/provider/orders/provider_order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "الطلبات" tab: the provider's bookings from the API, filtered by status.
class ProviderOrdersScreen extends StatefulWidget {
  /// Called after an order changed, so other tabs can refresh.
  final VoidCallback? onChanged;

  const ProviderOrdersScreen({super.key, this.onChanged});

  @override
  State<ProviderOrdersScreen> createState() => _ProviderOrdersScreenState();
}

class _ProviderOrdersScreenState extends State<ProviderOrdersScreen> {
  static const _filters = <(String?, String)>[
    (null, 'الكل'),
    ('provider_pending', 'جديدة'),
    ('payment_awaiting', 'بانتظار الدفع'),
    ('review_under_proof', 'مراجعة الدفع'),
    ('confirmed', 'مؤكدة'),
    ('completed', 'مكتملة'),
    ('rejected', 'مرفوضة'),
    ('cancelled', 'ملغاة'),
    ('expired', 'منتهية'),
  ];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ProviderOrdersCubit>();
    if (cubit.state is! ProviderOrdersLoaded) cubit.load();
  }

  Future<void> _open(int id) async {
    final changed = await Navigator.pushNamed(
      context,
      AppRoutes.providerOrderDetails,
      arguments: id,
    );
    if (!mounted) return;
    context.read<ProviderOrdersCubit>().refresh();
    if (changed == true) widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocBuilder<ProviderOrdersCubit, ProviderOrdersState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 14),
              child: Text(
                'الطلبات',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final added = await Navigator.pushNamed(
                      context,
                      AppRoutes.providerExternalBooking,
                    );
                    if (added == true) widget.onChanged?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: BorderSide(color: primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('إضافة حجز خارجي'),
                ),
              ),
            ),
            SizedBox(
              height: 34,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final (status, label) = _filters[i];
                  final selected = state.status == status;
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.read<ProviderOrdersCubit>().load(
                      status: status,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primary),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: selected ? Colors.white : primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            Expanded(child: _list(state)),
          ],
        );
      },
    );
  }

  Widget _list(ProviderOrdersState state) {
    if (state is ProviderOrdersLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is ProviderOrdersError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message),
            TextButton(
              onPressed: () => context.read<ProviderOrdersCubit>().refresh(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }
    final orders = (state as ProviderOrdersLoaded).orders;
    return RefreshIndicator(
      onRefresh: () => context.read<ProviderOrdersCubit>().refresh(),
      child: orders.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                const Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 44,
                  color: Colors.black26,
                ),
                const SizedBox(height: 12),
                Text(
                  state.status == null
                      ? 'لا توجد طلبات حجز بعد'
                      : 'لا توجد طلبات بهذه الحالة',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                for (final order in orders)
                  ProviderOrderCard(
                    order: order,
                    onTap: () => _open(int.parse(order['id'].toString())),
                  ),
              ],
            ),
    );
  }
}
