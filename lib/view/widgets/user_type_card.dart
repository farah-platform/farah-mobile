import 'package:farah/cubits/auth/auth_cubit.dart';
import 'package:farah/view/screens/service1/onboarding_screen2.dart';
import 'package:farah/view/screens/user/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserTypeCard extends StatelessWidget {
  const UserTypeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(28),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "اختيار نوع المستخدم",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                  );
                },
                child: const Text("عميل", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OnboardingScreen2(),
                    ),
                  );
                },
                child: const Text("مزود خدمة", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 20),

            // Guest: set the flag and let SplashScreen's BlocListener navigate.
            TextButton(
              onPressed: () {
                context.read<AuthCubit>().loginAsGuest();
              },
              child: const Text("الدخول كزائر", style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
