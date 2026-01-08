import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/action_card.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const HomeHeader()
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: -0.2),

              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.camera_alt,
                      title: 'Scan Leaf',
                      onTap: () {},
                    )
                        .animate()
                        .fadeIn(delay: 300.ms)
                        .scale(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.image,
                      title: 'Upload Image',
                      onTap: () {},
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .scale(),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                'Get instant disease detection\nusing AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ).animate().fadeIn(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
