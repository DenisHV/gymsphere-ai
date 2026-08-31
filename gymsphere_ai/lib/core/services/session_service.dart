import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';

class SessionService {
  // Cierra la sesión y regresa al Login, borrando todo el historial
  // de navegación (Dashboard, pestañas, etc.)
  static void cerrarSesion(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}