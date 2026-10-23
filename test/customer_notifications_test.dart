import 'package:farah/cubits/mybooking/mybooking_cubit.dart';
import 'package:farah/cubits/notification/notification_cubit.dart';
import 'package:farah/data/models/home/myBooking_model.dart';
import 'package:farah/data/models/notification_model.dart';
import 'package:farah/data/repositories/mybooking_repository.dart';
import 'package:farah/data/repositories/notification_repository.dart';
import 'package:farah/view/screens/user/MyBookingsScreen.dart';
import 'package:farah/view/screens/user/NotificationsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// فرح: إشعارات العميل: الشاشة كانت تطيح أول ما يوصل إشعار (التاريخ كان يُمرَّر كنص).

class _FakeNotifications implements NotificationRepository {
  final List<String> read = [];

  @override
  Future<List<NotificationModel>> fetchNotifications() async => [
    NotificationModel(
      id: '1',
      title: 'api title',
      body: 'api body',
      isRead: false,
      type: NotificationType.bookingAccepted,
      referenceId: '9',
      resourceType: 'booking',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  @override
  Future<void> markAsRead(String id) async => read.add(id);

  @override
  Future<void> markAllAsRead() async {}
}

class _NoBookings implements MyBookingRepository {
  @override
  Future<List<MybookingModel>> getBookings() async => [];
}

void main() {
  testWidgets('a notification shows, is marked read and opens my bookings', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 884);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = _FakeNotifications();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NotificationCubit(repo)),
          BlocProvider(create: (_) => MybookingCubit(_NoBookings())),
        ],
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('api title'), findsOneWidget);
    expect(find.text('api body'), findsOneWidget);
    expect(find.text('منذ 5 دقيقة'), findsOneWidget);

    await tester.tap(find.text('api title'));
    await tester.pumpAndSettle();
    expect(repo.read, ['1']);
    expect(find.byType(MyBookingScreen), findsOneWidget);
  });
}
