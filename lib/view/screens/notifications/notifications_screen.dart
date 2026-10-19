import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/notification/notification_cubit.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/constants/app_routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('الاشعارات', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: const Text(
              'تابع دفعات الحجوزات واتخذ الاجراء المناسب',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NotificationError) {
                  return Center(child: Text(state.message));
                } else if (state is NotificationsLoaded) {
                  final notifications = state.notifications;
                  if (notifications.isEmpty) {
                    return const Center(child: Text('لا يوجد إشعارات'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      // To match the UI, let's parse titles or types
                      bool isExpired = n.title.contains('انتهت مهلة');
                      bool isWarning = n.title.contains('تبقى');
                      
                      Color iconColor = isExpired ? Colors.red : (isWarning ? Colors.orange : primary);
                      IconData icon = isExpired ? Icons.error_outline : Icons.notifications_none;
                      
                      return GestureDetector(
                        onTap: () {
                          context.read<NotificationCubit>().markAsRead(n.id);
                          // Booking notifications open the order for providers.
                          final auth = context.read<AuthCubit>().state;
                          final bookingId = int.tryParse(n.referenceId ?? '');
                          if (n.resourceType == 'booking' &&
                              bookingId != null &&
                              auth is AuthSuccess &&
                              auth.user.role == 'provider') {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.providerOrderDetails,
                              arguments: bookingId,
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0,2))
                            ]
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end, // RTL
                                    children: [
                                      Text(
                                        n.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: n.isRead ? Colors.grey.shade700 : Colors.black,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('منذ ${n.createdAt.hour} ساعة', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                                            Text(
                                              n.body,
                                              style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: iconColor.withValues(alpha: 0.1),
                                child: Icon(icon, color: iconColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              }
            ),
          ),
        ],
      ),
    );
  }
}
