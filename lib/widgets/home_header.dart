import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // App Icon
        Icon(
          Icons.eco,
          size: 80,
          color: AppColors.primary,
        ),

        const SizedBox(height: 10),

        // App Title
        Text(
          'Pantify',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),

        const SizedBox(height: 6),

        // Subtitle
        const Text(
          'Smart Tomato Disease Detection',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
