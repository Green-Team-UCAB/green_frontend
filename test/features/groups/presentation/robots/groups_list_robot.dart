import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GroupsListRobot {
  final WidgetTester tester;
  GroupsListRobot(this.tester);

  // --- ACCIONES (El "Cómo") ---

  Future<void> tapFabNuevo() async {
    final fab = find.widgetWithText(FloatingActionButton, 'Nuevo');
    await tester.tap(fab);
    await tester.pumpAndSettle();
  }

  Future<void> tapOpcionCrearGrupo() async {
    final option = find.text('Crear Grupo');
    await tester.tap(option);
    await tester.pumpAndSettle();
  }

  Future<void> llenarFormularioCreacion(
      String nombre, String descripcion) async {
    final nameField = find.widgetWithText(TextField, 'Nombre del Grupo');
    final descField = find.widgetWithText(TextField, 'Descripción');

    await tester.enterText(nameField, nombre);
    await tester.enterText(descField, descripcion);
  }

  Future<void> tapConfirmarCrear() async {
    final btn = find.widgetWithText(ElevatedButton, 'Crear');
    await tester.tap(btn);
    await tester.pump();
  }

  // --- VERIFICACIONES (El "Qué") ---

  void verifyEmptyState() {
    expect(find.text("No perteneces a ningún grupo aún."), findsOneWidget);
    expect(find.byIcon(Icons.group_off_outlined), findsOneWidget);
  }

  void verifyGroupVisible(String groupName) {
    expect(find.text(groupName), findsOneWidget);
  }
}
