import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detect Disease')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              icon: Icons.camera_alt,
              label: 'Capture Leaf',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            CustomButton(
              icon: Icons.image,
              label: 'Upload from Gallery',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
