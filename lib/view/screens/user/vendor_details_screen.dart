import 'package:farah/data/repositories/service_repository.dart';
import 'package:farah/view/screens/user/service_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:farah/data/models/service_model.dart';
import 'package:farah/data/repositories/api_service_repository.dart';
import 'package:farah/cubits/service_detail/service_detail_cubit.dart';
import 'package:farah/view/widgets/bottom_nav_bar.dart';
import 'package:farah/view/screens/user/MyBookingsScreen.dart';
import 'package:farah/view/screens/user/favorites_screen.dart';
import 'package:farah/view/screens/user/profile_edit_screen.dart';
// تأكدي أن مسار استيراد الكيوبت هنا يطابق مشروعك:
import 'package:farah/cubits/vendor/vendor_details_cubit.dart';

class VendorDetailsScreen extends StatefulWidget {
  final int vendorId;
  final String? initialVendorName;
  final String? initialVendorSpecialty;
  final String? initialVendorAvatar;
  final num? initialVendorRating;

  const VendorDetailsScreen({
    super.key,
    required this.vendorId,
    this.initialVendorName,
    this.initialVendorSpecialty,
    this.initialVendorAvatar,
    this.initialVendorRating,
  });

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // تمرير البيانات المبدئية للكيوبت ليعتمد عليها بدلاً من السيرفر الناقص
    context.read<VendorDetailsCubit>().loadVendorDetails(
      providerId: widget.vendorId.toString(),
      vendorName: widget.initialVendorName ?? 'تفاصيل المزود',
      avatar: widget.initialVendorAvatar,
      rating: widget.initialVendorRating,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFBFB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F1F1F)),
            onPressed: () => Navigator.pop(context),
          ),
          title: BlocBuilder<VendorDetailsCubit, VendorDetailsState>(
            builder: (context, state) {
              String title = widget.initialVendorName ?? 'تفاصيل المزود';
              if (state is VendorDetailsLoaded) {
                title = state.vendorName;
              }
              return Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF7B2146),
                ),
              );
            },
          ),
        ),
        body: BlocBuilder<VendorDetailsCubit, VendorDetailsState>(
          builder: (context, state) {
            if (state is VendorDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7B2146)),
              );
            }

            if (state is VendorDetailsError) {
              return _buildErrorState(state.message);
            }

            if (state is VendorDetailsLoaded) {
              final services = state.services;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // تم تحديث البطاقة العلوية لتأخذ المتغيرات مباشرة
                    _buildVendorHeaderCard(
                      name: state.vendorName,
                      specialty: state.specialty,
                      avatarUrl: state.avatar,
                      rating: state.rating,
                    ),
                    const SizedBox(height: 20),

                    if (services.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          'لا توجد خدمات معروضة لهذا المزود حالياً',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildServiceCard(services[index]);
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: FarahBottomNavBar(
          currentIndex: 3,
          onTap: (index) {
            if (index == 3) {
              Navigator.pop(context);
            } else if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MyBookingScreen()),
              );
            } else if (index == 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            } else if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildVendorHeaderCard({
    required String name,
    required String specialty,
    String? avatarUrl,
    required double rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipOval(
                child: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? Image.network(
                        avatarUrl,
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
                      )
                    : _buildLogoPlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7B2146),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF0E4E6)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'حزمة متكاملة من الخدمات المخصصة للعرسان لتجهيز الزفاف بكافة تفاصيله',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12.5,
                    height: 1.5,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(
                    5,
                    (index) => Icon(
                      index < rating.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFD4AF37),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toInt().toString(),
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    final imageUrl = (service.image != null && service.image!.isNotEmpty)
        ? service.image
        : (service.images.isNotEmpty ? service.images.first : null);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    height: 175,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        service.title,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFF7B2146),
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${service.ratingAvg}',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B2146),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${service.reviewsCount} تقييم)',
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Tajawal'),
                        children: [
                          const TextSpan(
                            text: 'تبدأ من ',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          TextSpan(
                            text: '${service.price} ${service.currency}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7B2146),
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFF7B2146).withOpacity(0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => ServiceDetailCubit(
                                context.read<ServiceRepository>(),
                              ),
                              child: ServiceDetailsScreen(
                                serviceId: service.id,
                                service: service,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'عرض التفاصيل',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7B2146),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return Container(
      width: 55,
      height: 55,
      color: const Color(0xFFFBF0F2),
      child: const Icon(Icons.storefront, color: Color(0xFF7B2146), size: 28),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 175,
      width: double.infinity,
      color: const Color(0xFFFBF0F2),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xFF7B2146), size: 40),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              color: Colors.red,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2146),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () =>
                context.read<VendorDetailsCubit>().loadVendorDetails(
                  providerId: widget.vendorId.toString(),
                  vendorName: widget.initialVendorName ?? 'متجر المزود',
                ),
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontFamily: 'Tajawal', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
