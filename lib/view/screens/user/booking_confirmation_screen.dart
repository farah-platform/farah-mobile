import 'package:farah/data/models/home/booking_request_model.dart';
import 'package:farah/view/screens/user/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:farah/cubits/booking/booking_cubit.dart';
import 'package:farah/data/models/booking_options_model.dart';
import 'package:farah/data/models/service_model.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final ServiceModel service;
  final DateTime selectedDateTime;
  final BookingOptionSlotModel slot;
  final String currency;
  final String? notes;

  const BookingConfirmationScreen({
    super.key,
    required this.service,
    required this.selectedDateTime,
    required this.slot,
    required this.currency,
    this.notes,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  static const Color _primaryMaroon = Color(0xFF7B2146);
  static const Color _lightMaroonBg = Color(0xFFF9EEF1);
  static const Color _cardBorderColor = Color(0xFFE8E8E8);

  // دالة مساعدة لتنسيق الأرقام (إزالة الفواصل إذا كان الرقم صحيحاً)
  String _formatPrice(double price) {
    return price == price.roundToDouble()
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    // حساب المبالغ بناءً على نسبة 30%
    final double totalPrice = widget.slot.price;
    final double depositPrice = totalPrice * 0.30; // العربون 30%
    final double remainingPrice = totalPrice - depositPrice; // المتبقي

    final formattedArabicDate = DateFormat(
      'd MMMM yyyy',
      'ar',
    ).format(widget.selectedDateTime);

    final apiFormattedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(widget.selectedDateTime);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تأكيد الحجز',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _primaryMaroon,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // لمحاذاة العناوين لليمين
            children: [
              const SizedBox(height: 12),

              // 1. بطاقة معلومات الخدمة والتاريخ (تم عكس الترتيب لتكون الصورة يميناً)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorderColor),
                ),
                child: Row(
                  children: [
                    // الصورة أولاً لتظهر على اليمين
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child:
                          widget.service.image != null &&
                              widget.service.image!.isNotEmpty
                          ? Image.network(
                              widget.service.image!,
                              width: 84,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _buildPlaceholderImage(),
                            )
                          : _buildPlaceholderImage(),
                    ),
                    const SizedBox(width: 14),
                    // النصوص ثانياً لتظهر على يسار الصورة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 15,
                                color: _primaryMaroon,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedArabicDate,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _primaryMaroon,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. عنوان تفاصيل الدفع
              const Text(
                'تفاصيل الدفع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _primaryMaroon,
                ),
              ),
              const SizedBox(height: 10),

              // 3. جدول تفاصيل المبالغ (تم عكس الترتيب ليكون السعر يساراً والكلمة يميناً)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'العربون',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _primaryMaroon,
                          ),
                        ),
                        Text(
                          '${_formatPrice(depositPrice)} ${widget.currency}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'أثناء استلام الخدمة',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _primaryMaroon,
                          ),
                        ),
                        Text(
                          '${_formatPrice(remainingPrice)} ${widget.currency}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4. شريط التنبيه (تم عكس الترتيب لتكون الأيقونة يميناً)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _lightMaroonBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: _primaryMaroon,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'العربون مطلوب لتأكيد الحجز',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primaryMaroon,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. السعر الإجمالي (تم عكس الترتيب ليكون السعر يساراً والكلمة يميناً)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'السعر الاجمالي',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryMaroon,
                      ),
                    ),
                    Text(
                      '${_formatPrice(totalPrice)} ${widget.currency}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 6. زر الانتقال لصفحة الدفع
              // 6. زر الانتقال لصفحة الدفع
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryMaroon,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // 1. تجهيز بيانات الطلب التي سنرسلها لشاشة الدفع
                    final request = BookingRequestModel(
                      serviceId: widget.service.id,
                      bookingDate: apiFormattedDate,
                      bookingTime: widget.slot.startTime,
                      bookingSlot: widget.slot.label,
                      notes: widget.notes,
                    );

                    // 2. كود الانتقال الفعلي
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          service: widget.service,
                          depositAmount:
                              depositPrice, // استخدمنا الاسم الموجود في ملفك
                          bookingRequest:
                              request, // مررنا الطلب لإنشائه بعد نجاح الدفع
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'الانتقال لصفحة الدفع',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ], // نهاية قائمة الـ children
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 84,
      height: 72,
      color: Colors.grey[200],
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
