import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/core/utils/notification_time.dart';
import 'package:farah/cubits/notification/notification_cubit.dart';
import 'package:farah/data/models/notification_model.dart';
import 'package:farah/view/widgets/provider/onboarding/provider_step_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:farah/core/utils/notification_time.dart';

/// "الاشعارات" for providers: payment proofs and booking updates from the API.
class ProviderNotificationsScreen extends StatefulWidget {
  const ProviderNotificationsScreen({super.key});

  @override
  State<ProviderNotificationsScreen> createState() =>
      _ProviderNotificationsScreenState();
}

class _ProviderNotificationsScreenState
    extends State<ProviderNotificationsScreen> {
  static const _paymentTypes = {
    NotificationType.paymentProofSubmitted,
    NotificationType.paymentReviewReminder,
    NotificationType.paymentReviewOverdue,
  };

  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  Future<void> _open(NotificationModel n) async {
    if (!n.isRead) context.read<NotificationCubit>().markAsRead(n.id);
    final bookingId = int.tryParse(n.referenceId ?? '');
    if (n.resourceType != 'booking' || bookingId == null) return;
    await Navigator.pushNamed(
      context,
      _paymentTypes.contains(n.type)
          ? AppRoutes.providerPaymentReview
          : AppRoutes.providerOrderDetails,
      arguments: bookingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: kProviderStepBackground,
      appBar: providerStepAppBar(context, 'الاشعارات'),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  TextButton(
                    onPressed: () =>
                        context.read<NotificationCubit>().loadNotifications(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          final items = (state as NotificationsLoaded).notifications;
          return RefreshIndicator(
            onRefresh: () =>
                context.read<NotificationCubit>().loadNotifications(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
              children: [
                const Text(
                  'تابع دفعات الحجوزات واتخذ الاجراء المناسب',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        'لا توجد إشعارات بعد',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                for (final n in items) _card(n, primary),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(NotificationModel n, Color primary) {
    final icon = switch (n.type) {
      NotificationType.paymentReviewReminder => Icons.schedule,
      NotificationType.paymentReviewOverdue => Icons.info_outline,
      NotificationType.newBooking => Icons.event_available_outlined,
      _ => Icons.notifications_none_rounded,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: n.isRead ? Colors.white : const Color(0xFFF6E5E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: n.isRead
              ? const Color(0xFFE3DADD)
              : primary.withValues(alpha: 0.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _open(n),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 10, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: n.isRead
                      ? const Color(0xFFF6E5E8)
                      : Colors.white,
                  child: Icon(icon, color: primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      if (n.body.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          n.body,
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        notificationTimeLabel(n.createdAt),
                        style: TextStyle(color: primary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_left, color: primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
