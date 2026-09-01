
class SesionActual {
  static String? token;
  static String? nombre;
  static String? correo;
  static String? rol;

  static void guardar({
    required String token,
    required String nombre,
    required String correo,
    required String rol,
  }) {
    SesionActual.token = token;
    SesionActual.nombre = nombre;
    SesionActual.correo = correo;
    SesionActual.rol = rol;
  }

  static void limpiar() {
    token = null;
    nombre = null;
    correo = null;
    rol = null;
  }
}