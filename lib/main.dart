import 'package:farah/core/network/dio_client.dart';
import 'package:farah/core/theme/app_theme.dart';

import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/cubits/booking/booking_cubit.dart';
import 'package:farah/cubits/home/home_cubit.dart';
import 'package:farah/cubits/notification/notification_cubit.dart';
import 'package:farah/cubits/profile/profile_cubit.dart';
import 'package:farah/cubits/service/service_cubit.dart';
import 'package:farah/cubits/service_detail/service_detail_cubit.dart';

import 'package:farah/data/datasources/local/cache_datasource.dart';

import 'package:farah/data/repositories/api_auth_repository.dart';
import 'package:farah/data/repositories/api_booking_repository.dart';
import 'package:farah/data/repositories/api_notification_repository.dart';
import 'package:farah/data/repositories/api_profile_repository.dart';
import 'package:farah/data/repositories/api_service_repository.dart';

import 'package:farah/data/repositories/auth_repository.dart';
import 'package:farah/data/repositories/booking_repository.dart';
import 'package:farah/data/repositories/home_repostory.dart';
import 'package:farah/data/repositories/notification_repository.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:farah/data/repositories/service_repository.dart';

import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/firebase_options.dart';
import 'package:farah/view/screens/user/service_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final cache = CacheDatasource();

  final dioClient = DioClient(cache);

  final AuthRepository authRepository = ApiAuthRepository(
    dioClient: dioClient,
    cache: cache,
  );

  final ServiceRepository serviceRepository = ApiServiceRepository(
    dioClient: dioClient,
  );

  final HomeRepository homeRepository = HomeRepository(dioClient);

  final BookingRepository bookingRepository = ApiBookingRepository(
    dioClient: dioClient,
  );

  final ProfileRepository profileRepository = ApiProfileRepository(
    dioClient: dioClient,
  );

  final NotificationRepository notificationRepository =
      ApiNotificationRepository(dioClient: dioClient);

  runApp(
    FarhaApp(
      authRepository: authRepository,
      serviceRepository: serviceRepository,
      homeRepository: homeRepository,
      bookingRepository: bookingRepository,
      profileRepository: profileRepository,
      notificationRepository: notificationRepository,
    ),
  );
}

class FarhaApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ServiceRepository serviceRepository;
  final HomeRepository homeRepository;
  final BookingRepository bookingRepository;
  final ProfileRepository profileRepository;
  final NotificationRepository notificationRepository;

  const FarhaApp({
    super.key,
    required this.authRepository,
    required this.serviceRepository,
    required this.homeRepository,
    required this.bookingRepository,
    required this.profileRepository,
    required this.notificationRepository,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => authRepository,
      child: MultiBlocProvider(
        providers: [
          // Auth
          BlocProvider(create: (_) => AuthCubit(authRepository)),

          // Home
          BlocProvider(create: (_) => HomeCubit(homeRepository)),

          // Services
          BlocProvider(create: (_) => ServiceCubit(serviceRepository)),

          // Booking
          BlocProvider(create: (_) => BookingCubit(bookingRepository)),

          // Profile
          BlocProvider(create: (_) => ProfileCubit(profileRepository)),

          // Notification
          BlocProvider(
            create: (_) => NotificationCubit(notificationRepository),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,

          locale: const Locale('ar'),

          supportedLocales: const [Locale('ar')],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: appTheme,

          initialRoute: AppRoutes.splash,

          routes: AppRoutes.routes,

          // Service Details
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.serviceDetail) {
              final serviceId = settings.arguments as String;

              return MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) =>
                      ServiceDetailCubit(serviceRepository)..load(serviceId),
                  child: ServiceDetailsScreen(
                    serviceId: int.tryParse(serviceId.toString()),
                  ),
                ),
              );
            }

            return null;
          },
        ),
      ),
    );
  }
}
