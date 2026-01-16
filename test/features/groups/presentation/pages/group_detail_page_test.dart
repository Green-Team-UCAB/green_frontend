import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:green_frontend/injection_container.dart';
import 'package:green_frontend/features/groups/presentation/pages/group_detail_page.dart';
import 'package:green_frontend/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:green_frontend/features/groups/domain/entities/group.dart';

import '../robots/group_detail_robot.dart';

@GenerateMocks([GroupDetailBloc])
import 'group_detail_page_test.mocks.dart';

void main() {
  late MockGroupDetailBloc mockBloc;

  setUp(() async {
    await sl.reset();
    mockBloc = MockGroupDetailBloc();
    sl.registerFactory<GroupDetailBloc>(() => mockBloc);

    // Configuración Base
    when(mockBloc.state).thenReturn(GroupDetailLoaded(
      quizzes: [],
      leaderboard: [],
    ));
    when(mockBloc.stream).thenAnswer((_) => Stream.value(GroupDetailLoaded(
          quizzes: [],
          leaderboard: [],
        )));
  });

  final tGroup = Group(
    id: '1',
    name: 'Matemáticas',
    description: 'Clase',
    role: 'admin',
    memberCount: 5,
    createdAt: DateTime.now(),
  );

  testWidgets('H8.3: Admin genera invitación y copia el enlace',
      (tester) async {
    final robot = GroupDetailRobot(tester);
    const tLink = "https://green.app/invite/abc-123";

    // ARRANGE
    // Simulamos la secuencia de estados en el Stream
    when(mockBloc.stream).thenAnswer(
      (_) => Stream.fromIterable([
        GroupDetailLoaded(quizzes: [], leaderboard: []), // 1. Carga inicial
        InvitationGenerated(tLink, [], []), // 2. Diálogo aparece
      ]),
    );

    // Mantenemos el estado actual sincronizado con el último evento esperado
    when(mockBloc.state).thenReturn(InvitationGenerated(tLink, [], []));

    // ACT
    await tester.pumpWidget(MaterialApp(
      home: GroupDetailPage(group: tGroup),
    ));
    await tester.pump(); // Procesa el primer estado
    await tester.pump(); // Procesa la transición al segundo estado

    // Si el diálogo no ha aparecido automáticamente por el Stream, forzamos la interacción
    if (find.text('Invitación Generada').evaluate().isEmpty) {
      await robot.tapBotonInvitar();
    }

    // ASSERT
    robot.verifyDialogoInvitacion(tLink);

    await robot.tapCopiarEnlace();
    robot.verifySnackBarCopiado();
  });
}
