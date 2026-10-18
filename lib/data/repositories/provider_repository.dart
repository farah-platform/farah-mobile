abstract class ProviderRepository {
  Future<Map<String, dynamic>> getOnboardingData();
  Future<List<dynamic>> getCategories();
  Future<List<dynamic>> getCities();
  Future<void> submitOnboardingData(Map<String, dynamic> data, dynamic idProof, dynamic coverImage);
  Future<Map<String, dynamic>> getVerificationStatus();
  Future<List<dynamic>> getSubscriptionPlans();
  Future<void> activateSubscription(String planSlug);
  Future<Map<String, dynamic>> getDashboardData();
  Future<List<dynamic>> getProviderServices();
  Future<void> addProviderService(Map<String, dynamic> data, List<dynamic> images);
  Future<void> updateProviderService(int id, Map<String, dynamic> data, List<dynamic> newImages);
  Future<void> deleteProviderService(int id);
  Future<void> toggleServiceVisibility(int id);
  Future<Map<String, dynamic>> getBookingDetails(int bookingId);
  Future<void> reviewPaymentProof(int bookingId, int paymentId, String decision, {String? reviewNote});
}
