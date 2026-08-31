import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/session_service.dart';

class ReceptionDashboard extends StatefulWidget {
  final String nombre;

  const ReceptionDashboard({super.key, required this.nombre});

  @override
  State<ReceptionDashboard> createState() => _ReceptionDashboardState();
}

class _ReceptionDashboardState extends State<ReceptionDashboard> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esEscritorio = anchoPantalla >= 900;

    final sidebar = _ReceptionSidebar(
      indiceActual: _indiceActual,
      onTap: (i) {
        setState(() => _indiceActual = i);
        if (!esEscritorio) Navigator.pop(context);
      },
      onCerrarSesion: () => SessionService.cerrarSesion(context),
    );

    final pantallas = [
      const _AccessControlTab(),
      const _PantallaEnConstruccion(titulo: 'Membership Lookup'),
    ];

    return Scaffold(
      backgroundColor: AppColors.neutral,
      drawer: esEscritorio ? null : Drawer(child: sidebar),
      body: Row(
        children: [
          if (esEscritorio) sidebar,
          Expanded(
            child: Column(
              children: [
                if (!esEscritorio)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: AppColors.secondary),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: pantallas[_indiceActual]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------- SIDEBAR ----------------------

class _ReceptionSidebar extends StatelessWidget {
  final int indiceActual;
  final ValueChanged<int> onTap;
  final VoidCallback onCerrarSesion;

  const _ReceptionSidebar({
    required this.indiceActual,
    required this.onTap,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      (icono: Icons.badge_outlined, etiqueta: 'Access Control'),
      (icono: Icons.person_search_outlined, etiqueta: 'Membership Lookup'),
    ];

    return Container(
      width: 260,
      color: AppColors.neutral,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GYMSPHERE',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),

          // Identidad de la terminal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.neutral,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.dvr_outlined, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FRONT_DESK_01', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                      Text('Terminal Active', style: TextStyle(color: AppColors.primary, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Navegación
          ...List.generate(items.length, (i) {
            final activo = i == indiceActual;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: activo ? AppColors.tertiary : Colors.transparent,
                border: activo
                    ? const Border(left: BorderSide(color: AppColors.primary, width: 3))
                    : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListTile(
                leading: Icon(items[i].icono, color: activo ? AppColors.primary : Colors.grey, size: 20),
                title: Text(
                  items[i].etiqueta,
                  style: TextStyle(
                    color: activo ? AppColors.primary : Colors.grey[300],
                    fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () => onTap(i),
              ),
            );
          }),

          const Spacer(),

          // Botón de emergencia
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
              label: const Text(
                'EMERGENCY LOCKOUT',
                style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.redAccent.withOpacity(0.6)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey, size: 20),
            title: const Text('Logout', style: TextStyle(color: Colors.grey)),
            onTap: onCerrarSesion,
          ),
        ],
      ),
    );
  }
}

// ---------------------- ACCESS CONTROL TAB ----------------------

class _AccessControlTab extends StatefulWidget {
  const _AccessControlTab();

  @override
  State<_AccessControlTab> createState() => _AccessControlTabState();
}

class _AccessControlTabState extends State<_AccessControlTab> {
  Timer? _reloj;
  String _horaActual = '';

  // Datos de ejemplo — luego esto vendrá del backend en tiempo real
  final List<Map<String, String>> _registrosHoy = const [
    {'hora': '09:42', 'nombre': 'Alex Rivers', 'terminal': 'FD_01', 'estado': 'GRANTED'},
    {'hora': '09:38', 'nombre': 'Jordan Chen', 'terminal': 'FD_01', 'estado': 'GRANTED'},
    {'hora': '09:15', 'nombre': 'Sam Taylor', 'terminal': 'FD_02', 'estado': 'DENIED'},
    {'hora': '09:02', 'nombre': 'Casey Smith', 'terminal': 'FD_01', 'estado': 'GRANTED'},
    {'hora': '08:55', 'nombre': 'Morgan Lee', 'terminal': 'FD_01', 'estado': 'GRANTED'},
  ];

  @override
  void initState() {
    super.initState();
    _actualizarHora();
    _reloj = Timer.periodic(const Duration(seconds: 1), (_) => _actualizarHora());
  }

  void _actualizarHora() {
    final ahora = DateTime.now();
    setState(() {
      _horaActual =
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}:${ahora.second.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _reloj?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final esAncho = constraints.maxWidth > 900;

          final columnaEscaner = _PanelEscaner();
          final columnaLog = _PanelLogDiario(registros: _registrosHoy);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TERMINAL SCANNER',
                        style: TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'AWAITING INPUT... SYNC: OK',
                        style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '● LIVE',
                          style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_horaActual, style: TextStyle(color: Colors.grey[400], fontFamily: 'monospace')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: esAncho
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: columnaEscaner),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: columnaLog),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 400, child: columnaEscaner),
                            const SizedBox(height: 20),
                            columnaLog,
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Panel del escáner con la tarjeta de resultado superpuesta
class _PanelEscaner extends StatelessWidget {
  const _PanelEscaner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.tertiary),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Esquinas tipo "mira de cámara"
          const Positioned(top: 12, left: 12, child: _EsquinaMira()),
          Positioned(
            top: 12,
            right: 12,
            child: Transform.rotate(angle: 1.5708, child: const _EsquinaMira()),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Transform.rotate(angle: -1.5708, child: const _EsquinaMira()),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Transform.rotate(angle: 3.1416, child: const _EsquinaMira()),
          ),

          // Tarjeta de resultado (demo estático — luego reacciona a un escaneo real)
          Container(
            width: 260,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(10),
              border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.neutral,
                  child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                ),
                const SizedBox(height: 14),
                const Text(
                  'ACCESS GRANTED',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                const Text('Alex Rivers', style: TextStyle(color: AppColors.secondary, fontSize: 15)),
                const SizedBox(height: 4),
                Text('ID: MEM-8472-X', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EsquinaMira extends StatelessWidget {
  const _EsquinaMira();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _EsquinaPainter()),
    );
  }
}

class _EsquinaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pintura = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), pintura);
    canvas.drawLine(Offset.zero, Offset(0, size.height), pintura);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Panel del registro diario (tabla de accesos)
class _PanelLogDiario extends StatelessWidget {
  final List<Map<String, String>> registros;

  const _PanelLogDiario({required this.registros});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY LOG',
            style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(flex: 2, child: Text('TIME', style: TextStyle(color: Colors.grey, fontSize: 11))),
              Expanded(flex: 3, child: Text('MEMBER', style: TextStyle(color: Colors.grey, fontSize: 11))),
              Expanded(flex: 2, child: Text('TERM', style: TextStyle(color: Colors.grey, fontSize: 11))),
              Expanded(flex: 2, child: Text('STATUS', style: TextStyle(color: Colors.grey, fontSize: 11))),
            ],
          ),
          const Divider(color: Color(0xFF3A3B40)),
          ...registros.map((r) {
            final concedido = r['estado'] == 'GRANTED';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(r['hora']!, style: const TextStyle(color: AppColors.secondary, fontSize: 12))),
                  Expanded(flex: 3, child: Text(r['nombre']!, style: const TextStyle(color: AppColors.secondary, fontSize: 12))),
                  Expanded(flex: 2, child: Text(r['terminal']!, style: TextStyle(color: Colors.grey[400], fontSize: 12))),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (concedido ? AppColors.primary : Colors.redAccent).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        r['estado']!,
                        style: TextStyle(
                          color: concedido ? AppColors.primary : Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PantallaEnConstruccion extends StatelessWidget {
  final String titulo;

  const _PantallaEnConstruccion({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$titulo\n(en construcción)',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}