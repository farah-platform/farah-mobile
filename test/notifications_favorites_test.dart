import 'package:dio/dio.dart';
import 'package:farah/core/network/dio_client.dart';
import 'package:farah/cubits/favorites/favorites_cubit.dart';
import 'package:farah/data/datasources/local/cache_datasource.dart';
import 'package:farah/data/models/notification_model.dart';
import 'package:farah/data/repositories/api_favorites_repository.dart';
import 'package:farah/data/repositories/api_notification_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _NoTokenCache extends CacheDatasource {
  @override
  Future<String?> getToken() async => null;
}

class _Recorder extends Interceptor {
  final List<RequestOptions> requests = [];
  final Map<String, dynamic> Function(RequestOptions) respond;
  final int statusCode;
  _Recorder(this.respond, {this.statusCode = 200});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    requests.add(options);
    final response = Response(
      requestOptions: options,
      statusCode: statusCode,
      data: respond(options),
    );
    if (statusCode >= 400) {
      handler.reject(
        DioException(
          requestOptions: options,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
    } else {
      handler.resolve(response);
    }
  }
}

DioClient _client(_Recorder recorder) {
  final client = DioClient(_NoTokenCache());
  client.dio.interceptors.add(recorder);
  return client;
}

void main() {
  group('notifications', () {
    test('parses the API shape (int id, snake_case type)', () {
      final n = NotificationModel.fromMap({
        'id': 12,
        'type': 'booking_accepted',
        'title': 't',
        'body': 'b',
        'resource_type': 'booking',
        'resource_id': 9,
        'data': {'reference': 'BKG-1'},
        'is_read': false,
        'created_at': '2026-10-18T08:00:00+00:00',
      });
      expect(n.id, '12');
      expect(n.type, NotificationType.bookingAccepted);
      expect(n.referenceId, '9');
      expect(n.resourceType, 'booking');
      expect(
        NotificationType.fromApi('booking_requested'),
        NotificationType.newBooking,
      );
      expect(
        NotificationType.fromApi('unknown_type'),
        NotificationType.general,
      );
    });

    test('mark read uses POST', () async {
      final recorder = _Recorder((_) => <String, dynamic>{'status': true});
      final repo = ApiNotificationRepository(dioClient: _client(recorder));
      await repo.markAsRead('12');
      await repo.markAllAsRead();
      expect(recorder.requests.map((r) => '${r.method} ${r.path}'), [
        'POST /notifications/12/read',
        'POST /notifications/read-all',
      ]);
    });
  });

  group('favorites', () {
    test('loads favorites from the API keyed by service id', () async {
      final recorder = _Recorder(
        (_) => {
          'data': [
            {
              'id': 3,
              'service_id': 41,
              'title': 'api title',
              'price': 250,
              'image': 'https://x/img.jpg',
              'rating_avg': 4.5,
              'provider': {'id': 7, 'name': 'api provider'},
            },
          ],
        },
      );
      final items = await ApiFavoritesRepository(
        dioClient: _client(recorder),
      ).getFavorites();

      expect(recorder.requests.single.path, '/favorites');
      expect(items.single.id, '41');
      expect(items.single.providerName, 'api provider');
      expect(items.single.price, 250);
    });

    test('remove toggles once when the item was favorited', () async {
      final recorder = _Recorder((_) => {'is_favorited': false});
      await ApiFavoritesRepository(dioClient: _client(recorder)).remove('41');
      expect(recorder.requests.map((r) => '${r.method} ${r.path}'), [
        'POST /favorites/toggle/41',
      ]);
    });

    test('guest toggle explains that login is needed', () async {
      final recorder = _Recorder(
        (_) => {'message': 'Unauthenticated.'},
        statusCode: 401,
      );
      final cubit = FavoritesCubit(
        ApiFavoritesRepository(dioClient: _client(recorder)),
      );
      expect(await cubit.toggle('41'), 'سجّل الدخول لإضافة الخدمة إلى المفضلة');
    });
  });
}
