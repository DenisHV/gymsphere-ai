import 'dart:convert';
import 'package:http/http.dart' as http;

const String _urlBase = 'http://192.168.0.2:3000';

class AuthService {

  static Future<Map<String, dynamic>> login({
    required String correo,
    required String clave,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'clave': clave}),
    );

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;

    if (respuesta.statusCode != 200 && respuesta.statusCode != 201) {
      throw Exception(datos['message'] ?? 'Error al iniciar sesión');
    }

    return datos;
  }

  static Future<Map<String, dynamic>> verificar2FA({
    required String correo,
    required String codigo,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/auth/verificar-2fa'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'codigo': codigo}),
    );

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;

    if (respuesta.statusCode != 200 && respuesta.statusCode != 201) {
      throw Exception(datos['message'] ?? 'Código incorrecto');
    }

    return datos;
  }
}