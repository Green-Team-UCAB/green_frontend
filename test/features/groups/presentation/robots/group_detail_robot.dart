import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GroupDetailRobot {
  final WidgetTester tester;
  GroupDetailRobot(this.tester);

  // --- ACCIONES ---

  Future<void> tapBotonInvitar() async {
    // Buscamos el icono de agregar persona en el AppBar
    final iconBtn = find.widgetWithIcon(IconButton, Icons.person_add);

    expect(iconBtn, findsOneWidget,
        reason: "No se encontró el botón de invitar");

    await tester.tap(iconBtn);
    await tester.pumpAndSettle(); // Esperar al diálogo
  }

  Future<void> tapCopiarEnlace() async {
    final btn = find.text('Copiar'); // TextButton con icono
    await tester.tap(btn);
    await tester.pumpAndSettle(); // Esperar al SnackBar
  }

  Future<void> tapAsignarKahoot() async {
    final fab = find.widgetWithText(FloatingActionButton, 'Asignar Kahoot');
    await tester.tap(fab);
    await tester.pumpAndSettle(); // Espera la navegación a la nueva página
  }

  Future<void> tapTabRanking() async {
    // Buscamos la pestaña por su texto o icono
    final tab = find.text('Ranking');
    await tester.tap(tab);
    await tester.pumpAndSettle(); // Esperar animación del TabController
  }

  void verifyMiembroEnRanking(int posicion, String nombre, String puntos) {
    // Buscamos el CircleAvatar que tiene el número de posición
    final avatarFinder = find.widgetWithText(CircleAvatar, posicion.toString());

    // Buscamos el tile que contiene ese avatar
    final tileFinder = find.ancestor(
      of: avatarFinder,
      matching: find.byType(ListTile),
    );

    // Verificamos que dentro de ese tile estén el nombre y los puntos
    expect(find.descendant(of: tileFinder, matching: find.text(nombre)),
        findsOneWidget,
        reason: "No se encontró a $nombre en la posición $posicion");

    expect(find.descendant(of: tileFinder, matching: find.text(puntos)),
        findsOneWidget,
        reason: "No se encontraron los puntos $puntos para $nombre");
  }

  void verifyQuizEnLista(String titulo, String estado) {
    expect(find.text(titulo), findsOneWidget);
    expect(find.text(estado), findsOneWidget);
  }

  void verifyMensajeExito(String mensaje) {
    expect(find.text(mensaje), findsOneWidget);
  }

  void verifyDialogoInvitacion(String enlaceEsperado) {
    expect(find.text('Invitación Generada'), findsOneWidget);
    expect(find.text(enlaceEsperado), findsOneWidget);
  }

  void verifySnackBarCopiado() {
    expect(find.text('Enlace copiado'), findsOneWidget);
  }
}
