import 'dart:ui';

import 'package:farah/core/constants/app_routes.dart';
import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/view/widgets/user_type_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showText = false;
  bool showCard = false;
  bool _sessionFound = false;

  @override
  void initState() {
    super.initState();

    // Restore session before revealing the type-selection card.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthCubit>().checkSession();
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => showCard = true);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => showText = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          setState(() => _sessionFound = true);
          final route = state.user.role == 'provider'
              ? AppRoutes.providerHome
              : AppRoutes.home;
          Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF7B2146),
        body: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/image/logo1.png", width: 180),
                  const SizedBox(height: 20),

                  AnimatedSlide(
                    offset: showText ? Offset.zero : const Offset(0, 1),
                    duration: const Duration(milliseconds: 800),
                    child: AnimatedOpacity(
                      opacity: showText ? 1 : 0,
                      duration: const Duration(milliseconds: 800),
                      child: const Text(
                        "فرحتنا",
                        style: TextStyle(
                          color: Color.fromARGB(255, 228, 215, 175),
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Blur overlay — hidden once a session is found.
            if (showCard && !_sessionFound)
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 500),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withValues(alpha: .15),
                  ),
                ),
              ),

            // User-type card — slides up after delay, hidden if session found.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              left: 20,
              right: 20,
              bottom: (showCard && !_sessionFound) ? 30 : -420,
              child: const UserTypeCard(),
            ),
          ],
        ),
      ),
    );
  }
}
