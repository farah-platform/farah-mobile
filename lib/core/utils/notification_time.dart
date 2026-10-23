import 'package:farah/core/utils/arabic_date.dart';

// فرح: وقت الإشعار بالعربي، مشترك بين إشعارات العميل والمزود.
/// "منذ 12 دقيقة", "منذ ساعة", "أمس 9:15 م" or a full date.
String notificationTimeLabel(DateTime createdAt, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final local = createdAt.toLocal();
  final diff = current.difference(local);
  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
  if (diff.inHours < 24 && local.day == current.day) {
    return diff.inHours == 1 ? 'منذ ساعة' : 'منذ ${diff.inHours} ساعات';
  }
  final yesterday = DateTime(current.year, current.month, current.day - 1);
  final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final time =
      '$h:${local.minute.toString().padLeft(2, '0')} ${local.hour < 12 ? 'ص' : 'م'}';
  if (local.year == yesterday.year &&
      local.month == yesterday.month &&
      local.day == yesterday.day) {
    return 'أمس $time';
  }
  return formatArabicDate(local);
}
