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
  Future<void> updateServiceAvailability(int serviceId, {List<String> block = const [], List<String> unblock = const []});
  Future<void> reviewPaymentProof(int bookingId, int paymentId, String decision, {String? reviewNote});
}
