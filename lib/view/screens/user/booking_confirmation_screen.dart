import 'package:farah/data/models/home/booking_request_model.dart';
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

  @override
  Widget build(BuildContext context) {
    // السعر من الفترة المختارة (API). العربون يحدده مقدّم الخدمة عند قبول الطلب.
    final double totalPrice = widget.slot.price;
    const depositPending = 'يُحدَّد عند قبول الطلب';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 1. بطاقة معلومات الخدمة والتاريخ
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cardBorderColor),
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formattedArabicDate,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _primaryMaroon,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: _primaryMaroon,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
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
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 2. عنوان تفاصيل الدفع
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'تفاصيل الدفع',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _primaryMaroon,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 3. جدول تفاصيل المبالغ (العربون والمتبقي)
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
                          depositPending,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'العربون',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _primaryMaroon,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          depositPending,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          'أثناء استلام الخدمة',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _primaryMaroon,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4. شريط التنبيه: العربون مطلوب لتأكيد الحجز
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _lightMaroonBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'العربون مطلوب لتأكيد الحجز',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primaryMaroon,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: _primaryMaroon,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. السعر الإجمالي
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${totalPrice == totalPrice.roundToDouble() ? totalPrice.toInt() : totalPrice} ${widget.currency}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const Text(
                      'السعر الاجمالي',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryMaroon,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 6. زر الانتقال لصفحة الدفع مع الاستماع لـ Cubit
              BlocConsumer<BookingCubit, BookingState>(
                listener: (context, state) {
                  if (state is BookingCreated) {
                    // The provider accepts first; transfer details arrive
                    // with that acceptance (status payment_awaiting).
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم إرسال طلب الحجز إلى مقدّم الخدمة، وستصلك تعليمات الدفع بعد قبوله.',
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  } else if (state is BookingError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is BookingLoading;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryMaroon,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _primaryMaroon.withOpacity(
                          0.6,
                        ),
                        disabledForegroundColor: Colors.white70,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              // بناء كائن الطلب المطابق لمفاتيح السيرفر
                              final request = BookingRequestModel(
                                serviceId: widget.service.id,
                                bookingDate: apiFormattedDate,
                                bookingTime: widget.slot.startTime,
                                bookingSlot: widget.slot.label,
                                notes: widget.notes,
                              );

                              context.read<BookingCubit>().createBooking(
                                request,
                              );
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.2,
                              ),
                            )
                          : const Text(
                              'إرسال طلب الحجز',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
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
