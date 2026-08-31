import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// Dibuja una silueta humana simple con el torso resaltado en verde
// (zona trabajada recientemente) y extremidades en gris (en reposo).
class BodyHeatmapPainter extends CustomPainter {
  final double intensidadTorso; // 0.0 a 1.0

  BodyHeatmapPainter({this.intensidadTorso = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final centroX = size.width / 2;

    final pinturaGris = Paint()..color = const Color(0xFF3A3B40);
    final pinturaTorso = Paint()
      ..color = Color.lerp(const Color(0xFF3A3B40), AppColors.primary, intensidadTorso)!;

    // Cabeza
    canvas.drawCircle(Offset(centroX, size.height * 0.08), size.width * 0.09, pinturaGris);

    // Torso (resaltado con el color de intensidad)
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centroX, size.height * 0.30),
        width: size.width * 0.42,
        height: size.height * 0.30,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(torsoRect, pinturaTorso);

    // Brazo izquierdo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centroX - size.width * 0.30, size.height * 0.33),
          width: size.width * 0.12,
          height: size.height * 0.32,
        ),
        const Radius.circular(10),
      ),
      pinturaGris,
    );

    // Brazo derecho
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centroX + size.width * 0.30, size.height * 0.33),
          width: size.width * 0.12,
          height: size.height * 0.32,
        ),
        const Radius.circular(10),
      ),
      pinturaGris,
    );

    // Pierna izquierda
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centroX - size.width * 0.11, size.height * 0.72),
          width: size.width * 0.16,
          height: size.height * 0.38,
        ),
        const Radius.circular(10),
      ),
      pinturaGris,
    );

    // Pierna derecha
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centroX + size.width * 0.11, size.height * 0.72),
          width: size.width * 0.16,
          height: size.height * 0.38,
        ),
        const Radius.circular(10),
      ),
      pinturaGris,
    );

    // Línea de brillo bajo los pies
    final pinturaLinea = Paint()
      ..color = AppColors.primary.withOpacity(0.6)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(centroX - size.width * 0.25, size.height * 0.98),
      Offset(centroX + size.width * 0.25, size.height * 0.98),
      pinturaLinea,
    );
  }

  @override
  bool shouldRepaint(covariant BodyHeatmapPainter oldDelegate) =>
      oldDelegate.intensidadTorso != intensidadTorso;
}