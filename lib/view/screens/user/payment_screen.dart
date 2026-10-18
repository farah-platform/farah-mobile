import 'dart:io';
import 'package:farah/data/models/home/payment_request_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:farah/cubits/payment/payment_cubit.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/view/screens/user/payment_status_screen.dart';

enum PaymentMethod { bankOfPalestine, palPay, jawwalPay }

class PaymentScreen extends StatefulWidget {
  final ServiceModel service;
  final double depositAmount;
  final String bookingId;

  // Transfer details set by the provider; null until the booking is accepted.
  final String? paymentInstructions;

  const PaymentScreen({
    super.key,
    required this.service,
    required this.depositAmount,
    required this.bookingId,
    this.paymentInstructions,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.bankOfPalestine;
  File? _receiptImage;

  static const Color _maroon = Color(0xFF7B2146);
  static const Color _cardBorder = Color(0xFFE8E8E8);
  static const Color _infoBg = Color(0xFFF9F3F5);

  Future<void> _pickReceiptImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _receiptImage = File(pickedFile.path));
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ $label بنجاح'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String providerDisplayName =
        widget.service.provider?.name.isNotEmpty == true
        ? widget.service.provider!.name
        : 'متجر لافندر';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الدفع',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _maroon,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ملخص الطلب
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'ملخص الطلب',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'عربون حجز',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.depositAmount.toInt()} ${widget.service.currency}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _maroon,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          providerDisplayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.service.title,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _maroon,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 2. اختر طريقة الدفع
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر طريقة الدفع',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              _buildPaymentOption(
                title: 'بنك فلسطين',
                method: PaymentMethod.bankOfPalestine,
              ),
              const SizedBox(height: 10),
              _buildPaymentOption(
                title: 'بال باي',
                method: PaymentMethod.palPay,
              ),
              const SizedBox(height: 10),
              _buildPaymentOption(
                title: 'جوال باي',
                method: PaymentMethod.jawwalPay,
              ),

              const SizedBox(height: 18),

              // 3. الحقول التفاعلية حسب طريقة الدفع
              _buildDynamicPaymentDetails(),

              const SizedBox(height: 18),

              // 4. بطاقة إشعار رفع التحويل
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(
                          Icons.show_chart_rounded,
                          color: _maroon,
                          size: 20,
                        ),
                        Text(
                          'اشعار رفع التحويل',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    InkWell(
                      onTap: _pickReceiptImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _maroon.withOpacity(0.35),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _receiptImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _receiptImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 38,
                                    color: _maroon,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'ارفع صورة اشعار التحويل',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _maroon,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _infoBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: _maroon,
                          ),
                          Spacer(),
                          Text(
                            'سيتم مراجعة الدفع خلال 24 ساعة من قبل مزود الخدمة',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. زر إرسال الإشعار
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    if (!_hasInstructions) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'لا يمكن إرسال إشعار التحويل قبل قبول مقدّم الخدمة لطلبك.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (_receiptImage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى رفع صورة إشعار التحويل أولاً'),
                        ),
                      );
                      return;
                    }

                    String methodKey = 'bank_of_palestine';
                    if (_selectedMethod == PaymentMethod.palPay) {
                      methodKey = 'pal_pay';
                    } else if (_selectedMethod == PaymentMethod.jawwalPay) {
                      methodKey = 'jawwal_pay';
                    }

                    final request = PaymentRequestModel(
                      bookingId: widget.bookingId,
                      paymentMethod: methodKey,
                      amount: widget.depositAmount,
                      receiptImage: _receiptImage!,
                    );

                    // استدعاء الكيوبت أولاً قبل الانتقال لحفظ مرجع الـ State
                    final paymentCubit = context.read<PaymentCubit>();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: paymentCubit,
                          child: const PaymentStatusScreen(),
                        ),
                      ),
                    );

                    paymentCubit.sendReceipt(
                      request: request,
                      serviceTitle: widget.service.title,
                      currency: widget.service.currency,
                    );
                  },
                  child: const Text(
                    'ارسال الاشعار',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required PaymentMethod method,
  }) {
    final isSelected = _selectedMethod == method;

    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _maroon : Colors.black38,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _maroon,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasInstructions =>
      widget.paymentInstructions?.trim().isNotEmpty == true;

  Widget _buildDynamicPaymentDetails() {
    return Container(
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
            'تعليمات التحويل',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: _maroon,
            ),
          ),
          const SizedBox(height: 8),
          if (_hasInstructions)
            _buildReadOnlyField(
              widget.paymentInstructions!.trim(),
              'تعليمات التحويل',
            )
          else
            const Text(
              'ستظهر تفاصيل التحويل هنا بعد قبول مقدّم الخدمة لطلبك.',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.copy_rounded,
              size: 16,
              color: Colors.black45,
            ),
            onPressed: () => _copyToClipboard(value, label),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
