import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/gym_sidebar.dart';
import '../../shared/widgets/kpi_card.dart';
import '../../core/services/session_service.dart';

class AdminDashboard extends StatefulWidget {
  final String nombre;

  const AdminDashboard({super.key, required this.nombre});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _indiceActual = 0;

  final List<SidebarItem> _items = const [
    SidebarItem(icono: Icons.grid_view_rounded, etiqueta: 'DASHBOARD'),
    SidebarItem(icono: Icons.groups_outlined, etiqueta: 'MEMBRESÍAS'),
    SidebarItem(icono: Icons.vpn_key_outlined, etiqueta: 'CONTROL DE ACCESO'),
    SidebarItem(icono: Icons.fitness_center, etiqueta: 'BIBLIOTECA DE RUTINAS'),
    SidebarItem(icono: Icons.warning_amber_rounded, etiqueta: 'INCIDENCIAS'),
  ];

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final esEscritorio = anchoPantalla >= 900;

    final List<Widget> pantallas = [
      const _DashboardTab(),
      const _PantallaEnConstruccion(titulo: 'Membresías'),
      const _PantallaEnConstruccion(titulo: 'Control de Acceso'),
      const _PantallaEnConstruccion(titulo: 'Biblioteca de Rutinas'),
      const _PantallaEnConstruccion(titulo: 'Incidencias'),
    ];

    final sidebar = GymSidebar(
      items: _items,
      indiceActual: _indiceActual,
      onTap: (i) {
        setState(() => _indiceActual = i);
        if (!esEscritorio) Navigator.pop(context); // cierra el drawer en móvil
      },
      onNuevoRegistro: () {},
      onCerrarSesion: () => SessionService.cerrarSesion(context),
    );

    return Scaffold(
      backgroundColor: AppColors.neutral,
      // En móvil, el sidebar se convierte en un menú lateral (Drawer)
      drawer: esEscritorio ? null : Drawer(child: sidebar),
      body: Row(
        children: [
          if (esEscritorio) sidebar,
          Expanded(
            child: Column(
              children: [
                _BarraSuperior(esEscritorio: esEscritorio),
                const Divider(color: AppColors.tertiary, height: 1),
                Expanded(child: pantallas[_indiceActual]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Barra superior con buscador, título, botones y avatar
class _BarraSuperior extends StatelessWidget {
  final bool esEscritorio;

  const _BarraSuperior({required this.esEscritorio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          if (!esEscritorio)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.secondary),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),

          // Buscador (se oculta en pantallas muy angostas para no saturar)
          if (esEscritorio) ...[
            Container(
              width: 220,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Text('SYS.QUERY...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 20),
          ],

          Expanded(
            child: Text(
              'GYM_COMMAND',
              textAlign: esEscritorio ? TextAlign.center : TextAlign.left,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: 1,
              ),
            ),
          ),

          if (esEscritorio) ...[
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('CHECK IN', style: TextStyle(color: AppColors.secondary, fontSize: 11)),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('EMERGENCIA', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
            ),
            const SizedBox(width: 16),
          ],

          const Icon(Icons.notifications_none, color: AppColors.secondary),
          const SizedBox(width: 12),
          const Icon(Icons.settings_outlined, color: AppColors.secondary),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.tertiary,
            child: Icon(Icons.person, color: AppColors.primary, size: 18),
          ),
        ],
      ),
    );
  }
}

// Pestaña "Dashboard": KPIs + Registro de Acceso
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final registros = [
      {'hora': '14:41:59.02', 'id': '#MN-8842', 'nombre': 'Alexios V.', 'terminal': 'Portón Alpha', 'estado': 'CONCEDIDO'},
      {'hora': '14:40:12.88', 'id': '#MN-9102', 'nombre': 'Sarah J.', 'terminal': 'Portón Beta', 'estado': 'DENEGADO'},
      {'hora': '14:38:45.11', 'id': '#MN-7731', 'nombre': 'Marcus T.', 'terminal': 'Portón Alpha', 'estado': 'CONCEDIDO'},
      {'hora': '14:35:22.05', 'id': '#MN-1092', 'nombre': 'Elena R.', 'terminal': 'Portón Gamma', 'estado': 'CONCEDIDO'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs — se acomodan solos según el ancho disponible
          LayoutBuilder(
            builder: (context, constraints) {
              final columnas = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;
              return GridView.count(
                crossAxisCount: columnas,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: const [
                  KpiCard(
                    titulo: 'MIEMBROS ACTIVOS',
                    valor: '4,821',
                    subtitulo: '↑ 12% vs. mes anterior',
                    icono: Icons.person_outline,
                  ),
                  KpiCard(
                    titulo: 'INGRESOS HOY',
                    valor: '1,044',
                    subtitulo: '↑ 5% vs. lo esperado',
                    icono: Icons.login,
                  ),
                  KpiCard(
                    titulo: 'INCIDENCIAS ABIERTAS',
                    valor: '03',
                    subtitulo: 'Requiere atención inmediata',
                    icono: Icons.warning_amber_rounded,
                    alerta: true,
                  ),
                  KpiCard(
                    titulo: 'RUTINAS EN BIBLIOTECA',
                    valor: '89',
                    subtitulo: 'Inventario estable',
                    icono: Icons.archive_outlined,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          Row(
            children: [
              const Text(
                'REGISTRO DE ACCESO',
                style: TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              const Text('● EN VIVO', style: TextStyle(color: AppColors.primary, fontSize: 12)),
              const Spacer(),
              Text(
                'HORA SISTEMA // 14:42:09',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.tertiary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.neutral),
                dataRowColor: WidgetStateProperty.all(Colors.transparent),
                columns: const [
                  DataColumn(label: Text('HORA (UTC)', style: TextStyle(color: Colors.grey, fontSize: 11))),
                  DataColumn(label: Text('CÓDIGO ID', style: TextStyle(color: Colors.grey, fontSize: 11))),
                  DataColumn(label: Text('MIEMBRO', style: TextStyle(color: Colors.grey, fontSize: 11))),
                  DataColumn(label: Text('TERMINAL', style: TextStyle(color: Colors.grey, fontSize: 11))),
                  DataColumn(label: Text('ESTADO', style: TextStyle(color: Colors.grey, fontSize: 11))),
                ],
                rows: registros.map((r) {
                  final concedido = r['estado'] == 'CONCEDIDO';
                  return DataRow(cells: [
                    DataCell(Text(r['hora']!, style: const TextStyle(color: AppColors.secondary))),
                    DataCell(Text(r['id']!, style: TextStyle(color: Colors.grey[400]))),
                    DataCell(Text(r['nombre']!, style: const TextStyle(color: AppColors.secondary))),
                    DataCell(Text(r['terminal']!, style: TextStyle(color: Colors.grey[400]))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: concedido ? AppColors.primary : Colors.redAccent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          r['estado']!,
                          style: TextStyle(
                            color: concedido ? AppColors.primary : Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
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