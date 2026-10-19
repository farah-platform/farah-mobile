abstract class ProviderRepository {
  Future<Map<String, dynamic>> getOnboardingData();
  Future<List<dynamic>> getCategories();
  Future<List<dynamic>> getCities();
  Future<void> submitOnboardingData(Map<String, dynamic> data, dynamic idProof, dynamic coverImage);
  Future<Map<String, dynamic>> getVerificationStatus();
  Future<List<dynamic>> getSubscriptionPlans();
  /// Starts the free month, or sends the transfer [proof] for a paid plan.
  /// Returns the subscription, or the payment waiting for admin review.
  Future<Map<String, dynamic>> activateSubscription(String planSlug, {dynamic proof});
  /// The platform account providers transfer subscriptions to.
  Future<Map<String, dynamic>> getBankTransferDetails();
  Future<Map<String, dynamic>> getDashboardData();
  Future<List<dynamic>> getProviderServices();
  Future<void> addProviderService(Map<String, dynamic> data, List<dynamic> images);
  Future<void> updateProviderService(int id, Map<String, dynamic> data, List<dynamic> newImages);
  Future<void> deleteProviderService(int id);
  Future<void> toggleServiceVisibility(int id, bool isAvailable);
  Future<Map<String, dynamic>> getBookingDetails(int bookingId);
  /// Provider bookings, optionally filtered by workflow status.
  Future<List<dynamic>> getProviderBookings({String? status});
  /// Accept (with the deposit) or reject a booking request.
  Future<void> decideBooking(int bookingId, String decision, {double? depositAmount, String? note});
  Future<void> completeBooking(int bookingId);
  /// Raw bytes of a payment proof file.
  Future<List<int>> getPaymentProof(int bookingId, int paymentId);
  Future<void> updatePaymentInstructions(String instructions);
  /// Blocked dates of a service for a month (YYYY-MM).
  Future<Map<String, dynamic>> getServiceAvailability(int serviceId, String month);
  /// Records a booking made outside the app; with a service it blocks that date.
  Future<void> addExternalBooking(Map<String, dynamic> data);
  Future<List<dynamic>> getProviderReviews();
  Future<void> updatePayoutAccount({required String bankName, required String accountNumber, String? iban});
  // فرح: بيانات المتجر مع الشعار (logo) وفئة الخدمة ورقم السجل التجاري.
  Future<void> updateStoreProfile(Map<String, dynamic> data, dynamic coverImage, {dynamic logo});
  // فرح: شاشة "الاشتراك الحالي": GET /provider/subscription و POST /provider/subscription/cancel.
  /// Latest subscription with its plan (and features), or null when none.
  Future<Map<String, dynamic>?> getCurrentSubscription();
  Future<void> cancelSubscription();
  // فرح: مركز المساعدة: GET /faqs?audience=provider وبيانات التواصل من GET /settings.
  Future<List<dynamic>> getFaqs();
  /// `support_phone` and `support_email` set by the admin (may be empty).
  Future<Map<String, dynamic>> getSupportContacts();
  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  Future<void> updateServiceAvailability(int serviceId, {List<String> block = const [], List<String> unblock = const []});
  Future<void> reviewPaymentProof(int bookingId, int paymentId, String decision, {String? reviewNote});
}
