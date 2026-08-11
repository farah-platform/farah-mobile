import 'dart:ui';

import 'package:farah/view/widgets/user_type_card.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showText = false;
  bool showCard = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      setState(() {
        showText = true;
      });
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        showCard = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        color: Color(0xFFD4AF37),
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          AnimatedOpacity(
            opacity: showCard ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withOpacity(.15)),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            left: 20,
            right: 20,
            bottom: showCard ? 30 : -420,
            child: const UserTypeCard(),
          ),
        ],
      ),
    );
  }
}
