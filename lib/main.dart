import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/classifier.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep status bar transparent so splash gradient shows edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Force portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final classifier = TomatoClassifier();

  runApp(TomatoApp(classifier: classifier));
}

class TomatoApp extends StatelessWidget {
  final TomatoClassifier classifier;
  const TomatoApp({super.key, required this.classifier});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tomato Disease Detector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(classifier: classifier),
    );
  }
}
