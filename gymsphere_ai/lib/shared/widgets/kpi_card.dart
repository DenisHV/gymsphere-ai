import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData? icono;
  final bool alerta; // true = borde y textos en rojo (ej. incidentes abiertos)

  const KpiCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    this.icono,
    this.alerta = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorAcento = alerta ? Colors.redAccent : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.tertiary,
        borderRadius: BorderRadius.circular(10),
        border: alerta ? Border.all(color: Colors.redAccent.withOpacity(0.6)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: alerta ? Colors.redAccent : Colors.grey,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (icono != null) Icon(icono, color: colorAcento, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: TextStyle(color: colorAcento, fontSize: 34, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitulo,
            style: TextStyle(color: alerta ? Colors.redAccent[100] : Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }
}