import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Academic theme color palette
  static const Color primaryBlue = Color(0xFF0A4D68); // Scholarly Blue
  static const Color accentOrange = Color(0xFFF9A826); // Vibrant Orange
  static const Color backgroundWhite = Color(0xFFF8F8F8); // Paper White
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Card White
  static const Color primaryText = Color(0xFF222222);
  static const Color secondaryText = Color(0xFF6C6C6C);
  static const Color successGreen = Color(0xFF28A745);
  static const Color errorRed = Color(0xFFD9534F);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookSwap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: primaryBlue,
          secondary: accentOrange,
          surface: surfaceWhite,
          background: backgroundWhite,
          error: errorRed,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: primaryText,
          onBackground: primaryText,
          onError: Colors.white,
        ),
      ),
      // Start with the SplashScreen
      home: const SplashScreen(),
    );
  }
}
