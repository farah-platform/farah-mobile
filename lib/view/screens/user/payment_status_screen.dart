import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:farah/cubits/payment/payment_cubit.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  static const Color _maroon = Color(0xFF7B2146);
  static const Color _cardBorder = Color(0xFFEFEFEF);
  static const Color _circleBg = Color(0xFFF9EEF1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: BlocBuilder<PaymentCubit, PaymentState>(
          builder: (context, state) {
            String title = 'إشعار الدفع';
            if (state is PaymentLoading) title = 'جاري الارسال';
            if (state is PaymentBookingConfirmed) title = '';
            return Text(
              title,
              style: const TextStyle(
                color: _maroon,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<PaymentCubit, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading) {
              return _buildLoadingState();
            } else if (state is PaymentSubmittedUnderReview) {
              return _buildUnderReviewState(context, state);
            } else if (state is PaymentBookingConfirmed) {
              return _buildConfirmedState(context, state);
            } else if (state is PaymentConnectionError) {
              return _buildErrorState(context, state);
            } else if (state is PaymentRejected) {
              return _buildRejectedState(context, state);
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // 1. شاشة جاري الإرسال
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(color: _maroon, strokeWidth: 3),
          ),
          SizedBox(height: 28),
          Text(
            'جاري ارسال الاشعار',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يرجى الانتظار قليلا...',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // 2. شاشة تم إرسال الإشعار (قيد المراجعة 24 ساعة)
  Widget _buildUnderReviewState(
    BuildContext context,
    PaymentSubmittedUnderReview state,
  ) {
    final dateStr = DateFormat('d MMMM yyyy', 'ar').format(state.sentDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildCircleIcon(Icons.history_rounded),
          const SizedBox(height: 18),
          const Text(
            'تم إرسال إشعار الدفع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'سيتم مراجعة دفعتك خلال 24 ساعة',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 24),

          // كرت التفاصيل
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              children: [
                _buildDataRow('الخدمة', state.serviceTitle),
                const Divider(height: 20, color: _cardBorder),
                _buildDataRow(
                  'المبلغ',
                  '${state.amount.toInt()} ${state.currency}',
                ),
                const Divider(height: 20, color: _cardBorder),
                _buildDataRow('تاريخ الارسال', dateStr),
              ],
            ),
          ),

          const Spacer(),
          _buildActionButton('الرئيسية', () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 3. شاشة تم تأكيد حجزك بنجاح
  Widget _buildConfirmedState(
    BuildContext context,
    PaymentBookingConfirmed state,
  ) {
    final dateStr = DateFormat('d MMMM yyyy', 'ar').format(state.bookingDate);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildCircleIcon(Icons.check_rounded, isSolid: true),
          const SizedBox(height: 18),
          const Text(
            'تم تأكيد حجزك بنجاح',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'يمكنك متابعة تفاصيل الحجز من\nخلال طلباتي',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 24),

          // كرت التفاصيل
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              children: [
                _buildDataRow('مزود الخدمة', state.providerName),
                const Divider(height: 20, color: _cardBorder),
                _buildDataRow('الخدمة', state.serviceTitle),
                const Divider(height: 20, color: _cardBorder),
                _buildDataRow('موعد الحجز', dateStr),
                const Divider(height: 20, color: _cardBorder),
                _buildDataRow(
                  'المبلغ المدفوع',
                  '${state.amountPaid.toInt()} ${state.currency}',
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  // 4. شاشة حدث خطأ أثناء الإرسال
  Widget _buildErrorState(BuildContext context, PaymentConnectionError state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          _buildCircleIcon(Icons.warning_amber_rounded),
          const SizedBox(height: 20),
          const Text(
            'حدث خطأ أثناء إرسال الإشعار',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const Spacer(),
          _buildActionButton('اعادة المحاولة', () => context.read<PaymentCubit>().retry()),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 5. شاشة لم يتم قبول إشعار الدفع
  Widget _buildRejectedState(BuildContext context, PaymentRejected state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildCircleIcon(Icons.close_rounded),
          const SizedBox(height: 18),
          const Text(
            'لم يتم قبول إشعار الدفع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 24),

          // كرت سبب الرفض
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'سبب الرفض',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _maroon,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.reason,
                  style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                ),
              ],
            ),
          ),

          const Spacer(),
          _buildActionButton('رفع الاشعار', () {
            Navigator.of(context).pop(); // الرجوع لشاشة الدفع لإعادة الرفع
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ودجات مساعدة لتناسق التصميم
  Widget _buildCircleIcon(IconData icon, {bool isSolid = false}) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSolid ? _maroon : _circleBg,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 42, color: isSolid ? Colors.white : _maroon),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _maroon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _maroon,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
