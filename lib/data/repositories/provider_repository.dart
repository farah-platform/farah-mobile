abstract class ProviderRepository {
  Future<Map<String, dynamic>> getOnboardingData();
  Future<List<dynamic>> getCategories();
  Future<List<dynamic>> getCities();
  Future<void> submitOnboardingData(Map<String, dynamic> data, dynamic idProof, dynamic coverImage);
  Future<Map<String, dynamic>> getVerificationStatus();
  Future<List<dynamic>> getSubscriptionPlans();
  Future<void> activateSubscription(String planSlug);
  Future<Map<String, dynamic>> getDashboardData();
}
