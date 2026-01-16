import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:green_frontend/injection_container.dart';
import 'package:green_frontend/features/groups/presentation/pages/group_detail_page.dart';
import 'package:green_frontend/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:green_frontend/features/groups/presentation/bloc/kahoot_selection_bloc.dart';

import 'package:green_frontend/features/groups/domain/entities/group.dart';
import 'package:green_frontend/features/groups/domain/entities/group_quiz_assignment.dart';
import 'package:green_frontend/features/library/domain/entities/kahoot_summary.dart';

import '../robots/group_detail_robot.dart';
import '../robots/kahoot_selection_robot.dart';

@GenerateMocks([GroupDetailBloc, KahootSelectionBloc])
import 'group_activities_test.mocks.dart';

void main() {
  late MockGroupDetailBloc mockDetailBloc;
  late MockKahootSelectionBloc mockSelectionBloc;

  setUp(() async {
    await sl.reset();
    mockDetailBloc = MockGroupDetailBloc();
    mockSelectionBloc = MockKahootSelectionBloc();

    sl.registerFactory<GroupDetailBloc>(() => mockDetailBloc);
    sl.registerFactory<KahootSelectionBloc>(() => mockSelectionBloc);

    // Configuración Base
    when(mockDetailBloc.state)
        .thenReturn(GroupDetailLoaded(quizzes: [], leaderboard: []));
    when(mockDetailBloc.stream).thenAnswer(
        (_) => Stream.value(GroupDetailLoaded(quizzes: [], leaderboard: [])));

    when(mockSelectionBloc.state).thenReturn(KahootSelectionLoading());
    when(mockSelectionBloc.stream)
        .thenAnswer((_) => Stream.value(KahootSelectionLoading()));
  });

  final tGroup = Group(
    id: '1',
    name: 'Matemáticas',
    description: 'Clase',
    role: 'admin',
    memberCount: 5,
    createdAt: DateTime.now(),
  );

  final tKahoot = KahootSummary(
    id: 'k1',
    title: 'Examen Final',
    description: 'Difícil',
  );

  testWidgets('H8.6: Flujo completo de asignación de actividad (Admin)',
      (tester) async {
    final detailRobot = GroupDetailRobot(tester);
    final selectionRobot = KahootSelectionRobot(tester);

    // Configurar SelectionBloc para mostrar kahoots
    when(mockSelectionBloc.state).thenReturn(KahootSelectionLoaded([tKahoot]));
    when(mockSelectionBloc.stream)
        .thenAnswer((_) => Stream.value(KahootSelectionLoaded([tKahoot])));

    await tester.pumpWidget(MaterialApp(home: GroupDetailPage(group: tGroup)));
    await tester.pump();

    await detailRobot.tapAsignarKahoot();

    expect(find.text('Examen Final'), findsOneWidget);

    await selectionRobot.seleccionarKahoot('Examen Final');
    await selectionRobot.seleccionarFechaYConfirmar();

    verify(mockDetailBloc.add(argThat(isA<AssignQuizEvent>()
            .having((e) => e.quizId, 'quizId', 'k1')
            .having((e) => e.groupId, 'groupId', '1'))))
        .called(1);
  });

  testWidgets('H8.7: Ver actividades asignadas en la lista', (tester) async {
    final detailRobot = GroupDetailRobot(tester);

    // CORRECCIÓN AQUÍ: Agregamos el leaderboard vacío
    final tQuiz = GroupQuizAssignment(
      assignmentId: 'q1',
      quizId: 'k_origin_1',
      title: 'Álgebra Básica',
      status: 'PENDIENTE',
      availableUntil: DateTime.now().add(const Duration(days: 1)),
      score: null,
      leaderboard: [], // ✅ Corrección: Lista vacía requerida
    );

    when(mockDetailBloc.state)
        .thenReturn(GroupDetailLoaded(quizzes: [tQuiz], leaderboard: []));
    when(mockDetailBloc.stream).thenAnswer((_) =>
        Stream.value(GroupDetailLoaded(quizzes: [tQuiz], leaderboard: [])));

    await tester.pumpWidget(MaterialApp(home: GroupDetailPage(group: tGroup)));
    await tester.pump();

    detailRobot.verifyQuizEnLista('Álgebra Básica', 'PENDIENTE');
  });
}
