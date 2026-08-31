import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class NavItem {
  final IconData icono;
  final String etiqueta;

  const NavItem({required this.icono, required this.etiqueta});
}

class GymBottomNav extends StatelessWidget {
  final List<NavItem> items;
  final int indiceActual;
  final ValueChanged<int> onTap;

  const GymBottomNav({
    super.key,
    required this.items,
    required this.indiceActual,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutral,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final activo = i == indiceActual;
            return GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: activo ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].icono,
                      color: activo ? AppColors.neutral : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].etiqueta,
                      style: TextStyle(
                        color: activo ? AppColors.neutral : Colors.grey,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}