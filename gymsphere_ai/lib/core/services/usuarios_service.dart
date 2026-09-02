import 'dart:convert';

import 'package:http/http.dart' as http;

import 'sesion_actual.dart';

const String _urlBase = 'http://192.168.0.11:3000';

class UsuariosService {
  static Map<String, String> get _cabeceras => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${SesionActual.token}',
  };

  static Future<List<dynamic>> listar() async {
    final respuesta = await http.get(
      Uri.parse('$_urlBase/usuarios'),
      headers: _cabeceras,
    );
    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo cargar la lista de usuarios');
    }
    return jsonDecode(respuesta.body) as List<dynamic>;
  }

  static Future<void> crear({
    required String nombre,
    required String correo,
    required String clave,
    required String rol,
  }) async {
    final respuesta = await http.post(
      Uri.parse('$_urlBase/usuarios/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'correo': correo,
        'clave': clave,
        'rol': rol,
      }),
    );
    if (respuesta.statusCode != 201) {
      final datos = jsonDecode(respuesta.body);
      throw Exception(datos['message'] ?? 'Error al crear el usuario');
    }
  }

  static Future<void> actualizar(int id, Map<String, dynamic> cambios) async {
    final respuesta = await http.patch(
      Uri.parse('$_urlBase/usuarios/$id'),
      headers: _cabeceras,
      body: jsonEncode(cambios),
    );
    if (respuesta.statusCode != 200) {
      final datos = jsonDecode(respuesta.body);
      throw Exception(datos['message'] ?? 'Error al actualizar el usuario');
    }
  }

  static Future<void> eliminar(int id) async {
    final respuesta = await http.delete(
      Uri.parse('$_urlBase/usuarios/$id'),
      headers: _cabeceras,
    );
    if (respuesta.statusCode != 200) {
      throw Exception('Error al eliminar el usuario');
    }
  }

  static Future<void> resetear2FA(int id) async {
    final respuesta = await http.patch(
      Uri.parse('$_urlBase/usuarios/$id/reset-2fa'),
      headers: _cabeceras,
    );
    if (respuesta.statusCode != 200) {
      throw Exception('Error al reiniciar el 2FA');
    }
  }
}
