import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SidebarItem {
  final IconData icono;
  final String etiqueta;

  const SidebarItem({required this.icono, required this.etiqueta});
}

class GymSidebar extends StatelessWidget {
  final List<SidebarItem> items;
  final int indiceActual;
  final ValueChanged<int> onTap;
  final VoidCallback? onNuevoRegistro;
  final VoidCallback? onCerrarSesion;

  const GymSidebar({
    super.key,
    required this.items,
    required this.indiceActual,
    required this.onTap,
    this.onNuevoRegistro,
    this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.neutral,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STRATCOM',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 1,
            ),
          ),
          const Text(
            'Gym Admin v1.0',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNuevoRegistro,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text(
                'NUEVO REGISTRO',
                style: TextStyle(color: AppColors.neutral, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
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
                    leading: Icon(
                      items[i].icono,
                      color: activo ? AppColors.primary : Colors.grey,
                      size: 20,
                    ),
                    title: Text(
                      items[i].etiqueta,
                      style: TextStyle(
                        color: activo ? AppColors.primary : Colors.grey[300],
                        fontWeight: activo ? FontWeight.bold : FontWeight.normal,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onTap: () => onTap(i),
                  ),
                );
              },
            ),
          ),

          const Divider(color: AppColors.tertiary),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: Colors.grey, size: 20),
            title: const Text('AJUSTES', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.grey, size: 20),
            title: const Text('CERRAR SESIÓN', style: TextStyle(color: Colors.grey)),
            onTap: onCerrarSesion,
          ),
        ],
      ),
    );
  }
}