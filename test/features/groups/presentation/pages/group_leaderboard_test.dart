import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:green_frontend/injection_container.dart';
import 'package:green_frontend/features/groups/presentation/pages/group_detail_page.dart';
import 'package:green_frontend/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:green_frontend/features/groups/domain/entities/group.dart';
import 'package:green_frontend/features/groups/domain/entities/group_leaderboard.dart';

import '../robots/group_detail_robot.dart';

// Reutilizamos el mock generado anteriormente, no hace falta generar uno nuevo
// si apuntamos al archivo que ya existe. Pero por orden, generamos uno local.
@GenerateMocks([GroupDetailBloc])
import 'group_leaderboard_test.mocks.dart';

void main() {
  late MockGroupDetailBloc mockBloc;

  setUp(() async {
    await sl.reset();
    mockBloc = MockGroupDetailBloc();
    sl.registerFactory<GroupDetailBloc>(() => mockBloc);
  });

  final tGroup = Group(
    id: '1',
    name: 'Matemáticas',
    description: 'Clase',
    role: 'member',
    memberCount: 5,
    createdAt: DateTime.now(),
  );

  testWidgets('H8.9: Ver Ranking específico del Grupo', (tester) async {
    final robot = GroupDetailRobot(tester);

    // Datos de prueba para el leaderboard
    final leaderUsers = [
      const GroupLeaderboardEntry(
          userId: 'u1',
          name: 'María',
          position: 1,
          totalPoints: 1500,
          completedQuizzes: 5),
      const GroupLeaderboardEntry(
          userId: 'u2',
          name: 'Pedro',
          position: 2,
          totalPoints: 1200,
          completedQuizzes: 4),
    ];

    // Configurar Bloc
    when(mockBloc.state)
        .thenReturn(GroupDetailLoaded(quizzes: [], leaderboard: leaderUsers));
    when(mockBloc.stream).thenAnswer((_) =>
        Stream.value(GroupDetailLoaded(quizzes: [], leaderboard: leaderUsers)));

    // Renderizar
    await tester.pumpWidget(MaterialApp(home: GroupDetailPage(group: tGroup)));
    await tester.pump();

    // Acción: Cambiar a la pestaña de Ranking
    await robot.tapTabRanking();

    // Verificación
    robot.verifyMiembroEnRanking(1, 'María', '1500 pts');
    robot.verifyMiembroEnRanking(2, 'Pedro', '1200 pts');
  });
}
