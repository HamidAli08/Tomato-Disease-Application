import 'package:flutter/material.dart';
import 'utils/app_colors.dart';
import 'screens/splash_screen.dart';

class TomatoDiseaseApp extends StatelessWidget {
  const TomatoDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tomato Leaf Disease Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
