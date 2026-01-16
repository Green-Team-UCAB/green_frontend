import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SettingsRobot {
  final WidgetTester tester;
  SettingsRobot(this.tester);

  // --- ACCIONES ---

  Future<void> editarInformacion(String nuevoNombre, String nuevaDesc) async {
    final nameField = find.widgetWithText(TextField, 'Nombre del Grupo');
    final descField = find.widgetWithText(TextField, 'Descripción');

    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, nuevoNombre);

    await tester.ensureVisible(descField);
    await tester.enterText(descField, nuevaDesc);

    // CORRECCIÓN: Quitamos el 'await' porque .hide() no retorna futuro
    tester.testTextInput.hide();
    // Mantenemos esto para esperar la animación de bajada del teclado
    await tester.pumpAndSettle();
  }

  Future<void> tapGuardarCambios() async {
    // ESTRATEGIA: Buscar el Icono Directamente
    final iconFinder = find.byIcon(Icons.save);
    expect(iconFinder, findsOneWidget,
        reason: "No se encontró el icono de guardar");

    await tester.ensureVisible(iconFinder);
    await tester.tap(iconFinder);
    await tester.pump();
  }

  Future<void> tapEliminarGrupo() async {
    // CORRECCIÓN: Quitamos el 'await' aquí también
    tester.testTextInput.hide();
    await tester.pumpAndSettle();

    final iconFinder = find.byIcon(Icons.delete_forever);
    expect(iconFinder, findsOneWidget,
        reason: "No se encontró el icono de eliminar grupo");

    await tester.ensureVisible(iconFinder);
    await tester.tap(iconFinder);
    await tester.pumpAndSettle(); // Esperamos el diálogo
  }

  Future<void> confirmarEliminacion() async {
    final btn = find.widgetWithText(ElevatedButton, 'SÍ, ELIMINAR');
    await tester.tap(btn);
    await tester.pump();
  }

  // --- VERIFICACIONES ---

  void verifyDialogoEliminacionVisible() {
    expect(find.text('¿Eliminar Grupo?'), findsOneWidget);
    expect(find.textContaining('irreversible'), findsOneWidget);
  }
}
