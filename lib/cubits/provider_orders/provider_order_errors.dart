import 'package:dio/dio.dart';

/// Arabic message for an orders API error, preferring the server's own text.
String providerOrderError(Object e, String fallback) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
      final message = (data['title'] ?? data['message'])?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'تحقق من اتصالك بالإنترنت';
    }
  }
  return fallback;
}
