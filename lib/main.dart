import 'package:flutter/material.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/home/home_screen.dart'; 

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

      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home':       (context) => HomeScreen(), 
      },
    );
  }
}