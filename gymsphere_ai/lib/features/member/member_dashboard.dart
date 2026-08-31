import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/gym_bottom_nav.dart';
import '../../shared/widgets/body_heatmap_painter.dart';
import '../../core/services/session_service.dart';

class MemberDashboard extends StatefulWidget {
  final String nombre;
  final String correo;

  const MemberDashboard({
    super.key,
    required this.nombre,
    required this.correo,
  });

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  int _indiceActual = 0;

  final List<NavItem> _items = const [
    NavItem(icono: Icons.grid_view_rounded, etiqueta: 'Home'),
    NavItem(icono: Icons.qr_code_scanner, etiqueta: 'Scan'),
    NavItem(icono: Icons.smart_toy_outlined, etiqueta: 'Coach'),
    NavItem(icono: Icons.person_outline, etiqueta: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = [
      _InicioTab(nombre: widget.nombre),
      const _PantallaEnConstruccion(titulo: 'Scan'),
      const _PantallaEnConstruccion(titulo: 'Coach'),
      _ProfileTab(nombre: widget.nombre, correo: widget.correo),
    ];

    // El fondo cambia según la pestaña: la de Profile usa fondo blanco
    final fondoOscuro = _indiceActual != 3;

    return Scaffold(
      backgroundColor: fondoOscuro ? AppColors.neutral : Colors.white,
      body: SafeArea(
        child: IndexedStack(index: _indiceActual, children: pantallas),
      ),
      bottomNavigationBar: GymBottomNav(
        items: _items,
        indiceActual: _indiceActual,
        onTap: (i) => setState(() => _indiceActual = i),
      ),
    );
  }
}

// Pestaña "Home": todo el contenido del Dashboard
class _InicioTab extends StatelessWidget {
  final String nombre;

  const _InicioTab({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: avatar + título + campana
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.tertiary,
                child: Icon(Icons.person, color: AppColors.secondary),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'METABÓLICO',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const Icon(Icons.notifications_none, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 24),

          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'Sistema ', style: TextStyle(color: AppColors.secondary)),
                TextSpan(text: 'En Línea', style: TextStyle(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bienvenido de nuevo, $nombre. ¿Listo para calibrar?',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MI RACHA',
                      style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
                    ),
                    const Icon(Icons.local_fire_department, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      '14',
                      style: TextStyle(color: AppColors.secondary, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 6),
                    Text('Días', style: TextStyle(color: AppColors.secondary, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ritmo metabólico óptimo mantenido.',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CARGA MUSCULAR',
                      style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Datos en vivo',
                        style: TextStyle(color: AppColors.primary, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _barraMusculo('Pectoral Mayor', 0.9),
                const SizedBox(height: 10),
                _barraMusculo('Abdominales', 0.6),
                const SizedBox(height: 10),
                _barraMusculo('Cuádriceps', 0.2),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 220,
                    child: CustomPaint(
                      painter: BodyHeatmapPainter(intensidadTorso: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REGISTRO DE ACTIVIDAD',
                  style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.2),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        '14',
                        style: TextStyle(color: AppColors.secondary, fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'RACHA DE DÍAS',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _barrasActividad(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'MEMBRESÍA',
                      style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '● ACTIVA',
                        style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Volt Elite',
                  style: TextStyle(color: AppColors.neutral, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Acceso concedido a todas las instalaciones.',
                  style: TextStyle(color: AppColors.neutral, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.qr_code, color: AppColors.secondary, size: 18),
                    label: const Text(
                      'Ver código QR',
                      style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neutral,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _barraMusculo(String nombre, double progreso) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nombre, style: const TextStyle(color: AppColors.secondary, fontSize: 13)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progreso,
            minHeight: 6,
            backgroundColor: const Color(0xFF3A3B40),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _barrasActividad() {
    final alturas = [0.25, 0.35, 0.3, 0.5, 0.65, 0.55, 1.0];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: alturas.asMap().entries.map((entrada) {
        final esUltima = entrada.key == alturas.length - 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              height: 40 * entrada.value,
              decoration: BoxDecoration(
                color: esUltima
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.25 + (entrada.value * 0.4)),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Pestaña "Profile": datos del usuario + menú de opciones
class _ProfileTab extends StatelessWidget {
  final String nombre;
  final String correo;

  const _ProfileTab({required this.nombre, required this.correo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Encabezado negro con la marca
          Container(
            width: double.infinity,
            color: AppColors.neutral,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: const Row(
              children: [
                Icon(Icons.account_circle_outlined, color: AppColors.primary, size: 26),
                SizedBox(width: 8),
                Text(
                  'GYMSPHERE',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                Spacer(),
                Icon(Icons.notifications_none, color: AppColors.secondary),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Avatar
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tertiary,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 60),
          ),
          const SizedBox(height: 20),

          // Nombre real del usuario
          Text(
            nombre,
            style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),

          // Correo real del usuario
          Text(
            correo,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Estado de membresía
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.neutral,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: AppColors.primary, size: 8),
                SizedBox(width: 6),
                Text(
                  'ACTIVA',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Menú de opciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _opcionMenu(Icons.emoji_events_outlined, 'Logros'),
                const SizedBox(height: 14),
                _opcionMenu(Icons.history, 'Historial de Entrenamientos'),
                const SizedBox(height: 14),
                _opcionMenu(Icons.settings_outlined, 'Configuración'),
                const SizedBox(height: 14),
                _opcionMenu(Icons.support_agent_outlined, 'Soporte'),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Botón cerrar sesión
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => SessionService.cerrarSesion(context),
                icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                label: const Text(
                  'CERRAR SESIÓN',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _opcionMenu(IconData icono, String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icono, color: AppColors.secondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(texto, style: const TextStyle(color: AppColors.secondary, fontSize: 15)),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[500]),
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