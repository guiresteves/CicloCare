import 'package:flutter/material.dart';

// Importa sua tela onboarding
import 'features/auth/onboarding_screen.dart';

void main() {
  runApp(const CicloCareApp());
}

class CicloCareApp extends StatelessWidget {
  const CicloCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'CicloCare',

      theme: ThemeData(
        fontFamily: 'Poppins',

        primaryColor: const Color(0xFF7C5CBF),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),

      home: const OnboardingScreen(),
    );
  }
}