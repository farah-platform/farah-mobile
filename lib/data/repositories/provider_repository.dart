abstract class ProviderRepository {
  Future<Map<String, dynamic>> getOnboardingData();
  Future<void> submitOnboardingData(Map<String, dynamic> data, dynamic idProof, dynamic coverImage);
  Future<Map<String, dynamic>> getVerificationStatus();
  Future<List<dynamic>> getSubscriptionPlans();
  Future<void> activateSubscription(String planId, String bankName, String accountNumber, dynamic receiptImage);
  Future<Map<String, dynamic>> getDashboardData();
}
