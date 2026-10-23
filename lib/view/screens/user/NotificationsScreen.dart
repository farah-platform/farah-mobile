import 'package:farah/core/utils/notification_time.dart';
import 'package:farah/cubits/notification/notification_cubit.dart';
import 'package:farah/data/models/notification_model.dart';
import 'package:farah/view/screens/user/MyBookingsScreen.dart';
import 'package:farah/view/screens/user/favorites_screen.dart';
import 'package:farah/view/screens/user/settings_screen.dart';
import 'package:farah/view/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFBFB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF7B2146)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'الاشعارات',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Color(0xFF7B2146),
            ),
          ),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7B2146)),
              );
            }

            if (state is NotificationError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.red,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2146),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () =>
                          context.read<NotificationCubit>().loadNotifications(),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is NotificationsLoaded) {
              if (state.notifications.isEmpty) {
                return _buildEmptyState();
              }

              return _buildNotificationsList(state.notifications);
            }

            return const SizedBox.shrink();
          },
        ),
        // فرح: نفس ترتيب أزرار الرئيسية (0 الرئيسية، 1 طلباتي، 2 المفضلة، 3 حسابي).
        // كانت الأزرار متلخبطة: "الرئيسية" تفتح تعديل الملف الشخصي.
        bottomNavigationBar: FarahBottomNavBar(
          currentIndex: 0,
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context); // العودة للرئيسية
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingScreen()),
              );
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            } else if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                color: Color(0xFFFBF0F2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.notifications_none_rounded,
                  size: 58,
                  color: Color(0xFF7B2146),
                ),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'لاتوجد اشعارات حتى الان',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B2146),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'ستظهر هنا كل التحديثات المتعلقة بحجوزاتك وطلباتك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    return RefreshIndicator(
      color: const Color(0xFF7B2146),
      onRefresh: () => context.read<NotificationCubit>().loadNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];

          // فرح: createdAt تاريخ (DateTime) مش نص، فكان يطيّح الشاشة أول ما يوصل إشعار.
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _open(notification),
            child: _buildNotificationCard(
              title: notification.title.isEmpty
                  ? 'إشعار جديد'
                  : notification.title,
              body: notification.body,
              time: notificationTimeLabel(notification.createdAt),
              isUnread: !notification.isRead,
            ),
          );
        },
      ),
    );
  }

  // فرح: الضغط يعلّم الإشعار كمقروء، وإشعارات الحجز تفتح "حجوزاتي".
  void _open(NotificationModel notification) {
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }
    if (notification.resourceType == 'booking') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MyBookingScreen()),
      );
    }
  }

  Widget _buildNotificationCard({
    required String title,
    required String body,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF7B2146).withValues(alpha: 0.35)
              : const Color(0xFFF0E4E6),
          width: isUnread ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isUnread) ...[
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF7B2146),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFBF0F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF7B2146),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
