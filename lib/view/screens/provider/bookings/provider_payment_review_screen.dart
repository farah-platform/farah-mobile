import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubits/provider_payment_review/provider_payment_review_cubit.dart';

class ProviderPaymentReviewScreen extends StatefulWidget {
  final int bookingId;
  final int paymentId;
  
  const ProviderPaymentReviewScreen({super.key, required this.bookingId, required this.paymentId});

  @override
  State<ProviderPaymentReviewScreen> createState() => _ProviderPaymentReviewScreenState();
}

class _ProviderPaymentReviewScreenState extends State<ProviderPaymentReviewScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderPaymentReviewCubit>().loadPaymentDetails(widget.bookingId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('مراجعة الدفع', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: BlocConsumer<ProviderPaymentReviewCubit, ProviderPaymentReviewState>(
        listener: (context, state) {
          if (state is ProviderPaymentReviewSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال قرارك بنجاح')));
            Navigator.pop(context);
          } else if (state is ProviderPaymentReviewError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ProviderPaymentReviewLoading && state is! ProviderPaymentReviewLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          
          Map<String, dynamic>? data;
          if (state is ProviderPaymentReviewLoaded) {
            data = state.bookingDetails;
          }

          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Extract data from API response
          // Assuming user name is in 'user' object or 'user_name'
          final userName = data['user']?['name'] ?? data['user_name'] ?? 'غير متوفر';
          final serviceName = data['service']?['title'] ?? data['service_name'] ?? 'غير متوفر';
          final amount = data['total_price']?.toString() ?? '0';
          
          // Assuming the payment details are in a 'payments' list
          final payments = data['payments'] as List<dynamic>? ?? [];
          final currentPayment = payments.isNotEmpty ? payments.first : null;
          final receiptUrl = currentPayment?['receipt_image'];
          final bankName = currentPayment?['bank_name'] ?? 'غير متوفر';
          final accountNumber = currentPayment?['account_number'] ?? 'غير متوفر';
          final iban = currentPayment?['iban'] ?? 'غير متوفر';

          // For the timeout, let's assume createdAt + 24 hours
          bool isExpired = false;
          if (currentPayment?['created_at'] != null) {
            final createdAt = DateTime.tryParse(currentPayment!['created_at'].toString());
            if (createdAt != null) {
              isExpired = DateTime.now().difference(createdAt).inHours > 24;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isExpired)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('انتهت مهلة المراجعة (24 ساعة)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('يرجى المراجعة في اقرب وقت لتفادي تاثير تقييم متجرك', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                
                const Text('بيانات التحويل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _buildDataRow('اسم العميل', userName),
                _buildDataRow('الخدمة', serviceName),
                _buildDataRow('المبلغ المستحق', '$amount ILS'),
                _buildDataRow('مكان التحويل', bankName),
                _buildDataRow('رقم الحساب', accountNumber),
                _buildDataRow('الايبان', iban),
                const SizedBox(height: 24),
                
                Text('إشعار تحويل لمستفيد في $bankName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.pink)),
                const SizedBox(height: 16),
                
                // Receipt Image
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: receiptUrl != null 
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(receiptUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                      )
                    : const Center(child: Icon(Icons.receipt_long, size: 50, color: Colors.grey)),
                ),
                
                const SizedBox(height: 40),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            context.read<ProviderPaymentReviewCubit>().reviewPayment(widget.bookingId, widget.paymentId, 'confirmed');
                          },
                          child: const Text('قبول الاشعار', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showRejectDialog(context),
                          child: const Text('رفض', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(value, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('سبب الرفض', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('سيظهر السبب للعميل لمساعدته على المحاولة مجددا', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'مكان التحويل غير صحيح مثلا...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (noteController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    context.read<ProviderPaymentReviewCubit>().reviewPayment(
                      widget.bookingId, 
                      widget.paymentId, 
                      'rejected', 
                      reviewNote: noteController.text
                    );
                  },
                  child: const Text('تأكيد الرفض', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
