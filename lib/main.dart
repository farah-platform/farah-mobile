import 'package:farah/core/network/dio_client.dart';
import 'package:farah/core/theme/app_theme.dart';

import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/cubits/booking/booking_cubit.dart';
import 'package:farah/cubits/favorites/favorites_cubit.dart';
import 'package:farah/cubits/home/home_cubit.dart';
import 'package:farah/cubits/notification/notification_cubit.dart';
import 'package:farah/cubits/profile/profile_cubit.dart';
import 'package:farah/cubits/settings/settings_cubit.dart';

import 'package:farah/data/datasources/local/cache_datasource.dart';

import 'package:farah/data/repositories/api_auth_repository.dart';
import 'package:farah/data/repositories/api_booking_repository.dart';
import 'package:farah/data/repositories/api_notification_repository.dart';
import 'package:farah/data/repositories/api_profile_repository.dart';
import 'package:farah/data/repositories/api_service_repository.dart';
import 'package:farah/data/repositories/api_provider_repository.dart';
import 'package:farah/data/repositories/auth_repository.dart';
import 'package:farah/data/repositories/booking_repository.dart';
import 'package:farah/data/repositories/home_repostory.dart';
import 'package:farah/data/repositories/local_favorites_repository.dart';
import 'package:farah/data/repositories/notification_repository.dart';
import 'package:farah/data/repositories/profile_repository.dart';
import 'package:farah/data/repositories/service_repository.dart';
import 'package:farah/data/repositories/provider_repository.dart';
import 'package:farah/core/constants/app_routes.dart';

// import 'package:farah/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
  final ProviderRepository providerRepository = ApiProviderRepository(
    dioClient: dioClient,
  );

  runApp(
    FarhaApp(
      authRepository: authRepository,
      serviceRepository: serviceRepository,
      homeRepository: homeRepository,
      bookingRepository: bookingRepository,
      profileRepository: profileRepository,
      notificationRepository: notificationRepository,
      providerRepository: providerRepository,
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
  final ProviderRepository providerRepository;

  const FarhaApp({
    super.key,
    required this.authRepository,
    required this.serviceRepository,
    required this.homeRepository,
    required this.bookingRepository,
    required this.profileRepository,
    required this.notificationRepository,
    required this.providerRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<ProviderRepository>.value(value: providerRepository),
        RepositoryProvider<HomeRepository>.value(value: homeRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit(authRepository)),
          BlocProvider(create: (_) => HomeCubit(homeRepository)),
          BlocProvider(create: (_) => BookingCubit(bookingRepository)),
          BlocProvider(create: (_) => ProfileCubit(profileRepository)),
          BlocProvider(create: (_) => SettingsCubit(profileRepository)),
          BlocProvider(
            create: (_) => NotificationCubit(notificationRepository),
          ),
          BlocProvider(create: (_) => FavoritesCubit(LocalFavoritesRepository())),
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
          onUnknownRoute: (_) => MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text(
                  'الصفحة غير موجودة',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
