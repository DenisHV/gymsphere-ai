import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../member/member_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../reception/reception_dashboard.dart';
import '../../core/services/sesion_actual.dart';

class TwoFactorScreen extends StatefulWidget {
  final String correo;
  final String? qrImagen; // viene en base64 solo la primera vez

  const TwoFactorScreen({
    super.key,
    required this.correo,
    this.qrImagen,
  });

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen> {
  final List<TextEditingController> _controladores =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focos = List.generate(6, (_) => FocusNode());

  static const int _duracionTotal = 30;
  int _segundosRestantes = _duracionTotal;
  Timer? _temporizador;
  bool _cargando = false;
  String? _errorGeneral;

  @override
  void initState() {
    super.initState();
    _iniciarContador();
  }

  void _iniciarContador() {
    _segundosRestantes = _duracionTotal;
    _temporizador?.cancel();
    _temporizador = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_segundosRestantes > 0) {
          _segundosRestantes--;
        } else {
          _segundosRestantes = _duracionTotal;
        }
      });
    });
  }

  @override
  void dispose() {
    for (var c in _controladores) {
      c.dispose();
    }
    for (var f in _focos) {
      f.dispose();
    }
    _temporizador?.cancel();
    super.dispose();
  }

  Future<void> _verificarCodigo() async {
    final codigo = _controladores.map((c) => c.text).join();

    if (codigo.length != 6) {
      setState(() => _errorGeneral = 'Ingresa los 6 dígitos');
      return;
    }

    setState(() {
      _cargando = true;
      _errorGeneral = null;
    });

    try {
      final resultado = await AuthService.verificar2FA(
        correo: widget.correo,
        codigo: codigo,
      );

      if (!mounted) return;

      final usuario = resultado['usuario'] as Map<String, dynamic>;
      final rol = usuario['rol'] as String;
      final nombre = usuario['nombre'] as String;

      // Enrutamiento real según el rol del usuario autenticado
      Widget pantallaDestino;
            final correoUsuario = usuario['correo'] as String;
                  SesionActual.guardar(
        token: resultado['token'] as String,
        nombre: nombre,
        correo: correoUsuario,
        rol: rol,
      );

            if (rol == 'ADMINISTRADOR') {
        pantallaDestino = AdminDashboard(nombre: nombre);
      } else if (rol == 'RECEPCION') {
        pantallaDestino = ReceptionDashboard(nombre: nombre);
      } else {
        pantallaDestino = MemberDashboard(nombre: nombre, correo: correoUsuario);
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => pantallaDestino),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorGeneral = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Widget _cuadroDigito(int indice) {
    return SizedBox(
      width: 45,
      height: 55,
      child: TextField(
        controller: _controladores[indice],
        focusNode: _focos[indice],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(color: AppColors.neutral, fontSize: 22, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.secondary,
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
        onChanged: (valor) {
          if (valor.isNotEmpty && indice < 5) {
            _focos[indice + 1].requestFocus();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double progreso = _segundosRestantes / _duracionTotal;

    // Si viene qrImagen, la decodificamos de base64 a bytes para mostrarla
    Uint8List? bytesQr;
    if (widget.qrImagen != null) {
      final base64Limpio = widget.qrImagen!.split(',').last; // quita el "data:image/png;base64,"
      bytesQr = base64Decode(base64Limpio);
    }

    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('PASO 2 / 2', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progreso,
                              strokeWidth: 3,
                              backgroundColor: AppColors.tertiary,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                            const Icon(Icons.shield, color: AppColors.primary, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'CONFIRMACIÓN DE IDENTIDAD',
                    style: TextStyle(color: AppColors.secondary, fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Si es primera vez, muestra el QR para escanear
                  if (bytesQr != null) ...[
                    Text(
                      'Escanea este código con Google Authenticator',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.memory(bytesQr, width: 180, height: 180),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ] else
                    Text(
                      'Ingresa el código de 6 dígitos de tu app autenticadora.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),

                  const SizedBox(height: 8),
                  Text(
                    'El código expira en $_segundosRestantes s',
                    style: const TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                  const SizedBox(height: 24),

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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) => _cuadroDigito(i)),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _verificarCodigo,
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
                              'VERIFICAR',
                              style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                    ),
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