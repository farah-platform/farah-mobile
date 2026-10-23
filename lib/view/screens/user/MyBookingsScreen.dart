import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/mybooking/mybooking_cubit.dart';
import 'package:farah/cubits/mybooking/mybooking_state.dart';
import 'package:farah/data/models/home/myBooking_model.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/view/screens/user/payment_screen.dart';
import 'package:farah/view/screens/user/favorites_screen.dart';
import 'package:farah/view/screens/user/home_screen.dart';
import 'package:farah/view/screens/user/settings_screen.dart';
import 'package:farah/view/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  final List<String> _filters = [
    'الكل',
    'مؤكدة',
    'منتهية',
    'قيدالمراجعة',
    'مرفوضة',
  ];

  @override
  void initState() {
    super.initState();
    context.read<MybookingCubit>().loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF8F8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF7B2146)),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'سجل الحجوزات',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF7B2146),
            ),
          ),
        ),
        body: BlocBuilder<MybookingCubit, MybookingState>(
          builder: (context, state) {
            if (state is MybookingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7B2146)),
              );
            }

            if (state is MybookingError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2146),
                      ),
                      onPressed: () =>
                          context.read<MybookingCubit>().loadBookings(),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is MybookingLoaded) {
              return Column(
                children: [
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _filters.map((filter) {
                        final isSelected = state.selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: GestureDetector(
                            onTap: () => context
                                .read<MybookingCubit>()
                                .filterByStatus(filter),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF7B2146)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF7B2146)
                                      : const Color(0xFFE2D6D8),
                                ),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF555555),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: state.filteredBookings.isEmpty
                        ? Column(
                            children: [
                              const Spacer(),
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF9F1F4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 40,
                                  color: Color(0xFF7B113A),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'لا يوجد حجوزات لحتى الآن',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7B113A),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'أبدأ رحلتك واكتشف ما يناسبك',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(), // لدفع الزر للأسفل
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 24.0,
                                  left: 16.0,
                                  right: 16.0,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        AppRoutes.home,
                                        (route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF7B113A),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),

                                    child: const Text(
                                      'استكشف الخدمات',
                                      style: TextStyle(
                                        fontFamily: 'Tajawal',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.filteredBookings.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildBookingCard(
                                state.filteredBookings[index],
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: FarahBottomNavBar(
          currentIndex: 1,
          onTap: (index) {
            if (index == 1) return;

            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const SettingsScreen(), // أو ProfileScreen
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(MybookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0E4E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    (booking.imageUrl != null && booking.imageUrl!.isNotEmpty)
                    ? Image.network(
                        booking.imageUrl!,
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),

              const SizedBox(width: 12),

              // فرح: Expanded حتى ما يطلع اسم الخدمة الطويل برا الشاشة.
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // لمحاذاة النص لليمين
                  children: [
                    Text(
                      booking.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'تاريخ الحجز',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.date,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildStatusBadge(booking.status),
                  const SizedBox(height: 12),
                  const Text(
                    'السعر',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${booking.price.toInt()}ILS',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B2146),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // فرح: الحجز اللي قبله المزود (بانتظار الدفع) يفتح شاشة الدفع بالعربون وتعليمات التحويل من السيرفر.
          if (booking.awaitingPayment) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: () => _openPayment(booking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2146),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ادفع العربون (${_formatAmount(booking.deposit)} ${booking.currency})',
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAmount(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  Future<void> _openPayment(MybookingModel booking) async {
    final cubit = context.read<MybookingCubit>();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          service: ServiceModel.fromJson({
            'id': booking.serviceId ?? 0,
            'title': booking.title,
            'currency': booking.currency,
            'image': booking.imageUrl,
          }),
          depositAmount: booking.deposit,
          bookingId: booking.id.toString(),
          paymentInstructions: booking.paymentInstructions,
        ),
      ),
    );
    // Reload so the booking moves to "قيد المراجعة" after the proof is sent.
    if (mounted) cubit.loadBookings();
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case BookingStatus.confirmed:
        bg = const Color(0xFFE8F8F2);
        text = const Color(0xFF34A853);
        label = 'مؤكدة';
        break;
      case BookingStatus.completed:
        bg = const Color(0xFFF1F3F4);
        text = const Color(0xFF5F6368);
        label = 'منتهية';
        break;
      case BookingStatus.pending:
        bg = const Color(0xFFFEF7E6);
        text = const Color(0xFFFBBC04);
        label = 'قيد المراجعة';
        break;
      case BookingStatus.cancelled:
        bg = const Color(0xFFFCE8E6);
        text = const Color(0xFFEA4335);
        label = 'مرفوضة';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 75,
      height: 75,
      color: const Color(0xFFF3ECEE),
      child: const Icon(Icons.image_outlined, color: Color(0xFF7B2146)),
    );
  }
}
