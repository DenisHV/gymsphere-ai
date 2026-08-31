import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import 'two_factor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();
  bool _mostrarClave = false;
  bool _cargando = false;
  String? _errorUsuario;
  String? _errorClave;
  String? _errorGeneral;

  @override
  void dispose() {
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _validarYContinuar() async {
    setState(() {
      _errorGeneral = null;
      _errorUsuario =
          _usuarioController.text.trim().isEmpty ? 'Ingresa tu correo' : null;
      _errorClave = _claveController.text.trim().isEmpty
          ? 'Ingresa tu clave de seguridad'
          : null;
    });

    if (_errorUsuario != null || _errorClave != null) return;

    setState(() => _cargando = true);

    try {
      final correo = _usuarioController.text.trim();
      final resultado = await AuthService.login(
        correo: correo,
        clave: _claveController.text,
      );

      if (!mounted) return;

      // resultado trae requiereConfiguracion2FA y, si es la primera vez, qrImagen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TwoFactorScreen(
            correo: correo,
            qrImagen: resultado['qrImagen'] as String?,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorGeneral = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.tertiary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PASO 1 / 2',
                      style: TextStyle(color: AppColors.primary, letterSpacing: 2, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'ACCESO AL SISTEMA',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.secondary, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Se requieren credenciales de operativo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 24),

                  // Mensaje de error general (ej. correo o clave incorrectos)
                  if (_errorGeneral != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Text(
                        _errorGeneral!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),

                  const Text('ID DE OPERATIVO (correo)', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usuarioController,
                    style: const TextStyle(color: AppColors.secondary),
                    decoration: InputDecoration(
                      hintText: 'correo@ejemplo.com',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: AppColors.tertiary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      errorText: _errorUsuario,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('CLAVE DE SEGURIDAD', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _claveController,
                    obscureText: !_mostrarClave,
                    style: const TextStyle(color: AppColors.secondary),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: AppColors.tertiary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      errorText: _errorClave,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_mostrarClave ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _mostrarClave = !_mostrarClave),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _validarYContinuar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _cargando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neutral),
                            )
                          : const Text(
                              'CONTINUAR',
                              style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('RECUPERAR CLAVE', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('NUEVO INGRESO', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}