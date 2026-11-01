// فرح: الدعم المشترك بين العميل والمزود: الأسئلة الشائعة، بيانات التواصل،
// وتفضيل الإشعارات (GET/PUT /notification-settings).
abstract class SupportRepository {
  /// `[{id, question, answer}]` for `customer` or `provider`, managed by the admin.
  Future<List<Map<String, dynamic>>> getFaqs({required String audience});

  /// `support_phone` and `support_email` set by the admin (may be empty).
  Future<Map<String, dynamic>> getSupportContacts();

  Future<bool> getNotificationsEnabled();

  Future<void> setNotificationsEnabled(bool enabled);
}
