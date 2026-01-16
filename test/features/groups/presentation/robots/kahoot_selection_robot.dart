import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class KahootSelectionRobot {
  final WidgetTester tester;
  KahootSelectionRobot(this.tester);

  Future<void> seleccionarKahoot(String tituloKahoot) async {
    final card = find.widgetWithText(ListTile, tituloKahoot);
    await tester.tap(card);
    await tester.pumpAndSettle(); // Espera a que abra el DatePicker
  }

  Future<void> seleccionarFechaYConfirmar() async {
    // En el DatePicker de Flutter, usualmente hay un botón "OK" o "ASIGNAR" (según tu código)
    // Tu código dice: confirmText: "ASIGNAR"
    final btnAsignar = find.text('ASIGNAR');

    // A veces el DatePicker necesita un poco de tiempo o interacción
    await tester.tap(btnAsignar);
    await tester
        .pumpAndSettle(); // Espera a que se cierre el diálogo y la página
  }
}
