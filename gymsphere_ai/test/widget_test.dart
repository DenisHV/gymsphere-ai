//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsphere_ai/main.dart';

void main() {
  testWidgets('La app arranca sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(const GymSphereApp());

    // Verifica que la pantalla de login cargó correctamente
    expect(find.text('ACCESO AL SISTEMA'), findsOneWidget);
  });
}