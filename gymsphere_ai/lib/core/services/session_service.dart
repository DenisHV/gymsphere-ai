import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import 'sesion_actual.dart';

class SessionService {
  static void cerrarSesion(BuildContext context) {
    SesionActual.limpiar();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}