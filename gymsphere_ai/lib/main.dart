import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const GymSphereApp());
}

class GymSphereApp extends StatelessWidget {
  const GymSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymSphere AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.temaOscuro,
      home: const LoginScreen(),
    );
  }
}