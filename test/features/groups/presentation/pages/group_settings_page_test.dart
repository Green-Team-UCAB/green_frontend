import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:green_frontend/injection_container.dart';
import 'package:green_frontend/features/groups/presentation/pages/group_settings_page.dart';
import 'package:green_frontend/features/groups/presentation/bloc/group_settings_bloc.dart';
import 'package:green_frontend/features/groups/domain/entities/group.dart';
// Importa tus entidades necesarias para la lista de miembros (aunque aquí la pasaremos vacía para H8.5)
import 'package:green_frontend/features/groups/domain/entities/group_leaderboard.dart';

import '../robots/settings_robot.dart';

// Generamos Mock para este Bloc específico
@GenerateMocks([GroupSettingsBloc])
import 'group_settings_page_test.mocks.dart';

void main() {
  late MockGroupSettingsBloc mockBloc;

  setUp(() async {
    await sl.reset();
    mockBloc = MockGroupSettingsBloc();
    sl.registerFactory<GroupSettingsBloc>(() => mockBloc);

    when(mockBloc.state).thenReturn(GroupSettingsInitial());
    when(mockBloc.stream)
        .thenAnswer((_) => Stream.value(GroupSettingsInitial()));
  });

  // Datos de prueba
  final tGroup = Group(
    id: '123',
    name: 'Física Avanzada',
    description: 'Grupo inicial',
    role: 'admin',
    memberCount: 1,
    createdAt: DateTime.now(),
  );

  // Lista de miembros vacía para estos tests (no relevante para editar info)
  final List<GroupLeaderboardEntry> tEmptyMembers = [];

  testWidgets('H8.5: Debe permitir editar la información del grupo (Admin)',
      (tester) async {
    final robot = SettingsRobot(tester);

    // Arrange: Cargar página
    await tester.pumpWidget(MaterialApp(
      home: GroupSettingsPage(group: tGroup, members: tEmptyMembers),
    ));

    // Act: Editar información
    await robot.editarInformacion('Física II', 'Preparación intensiva');
    await robot.tapGuardarCambios();

    // Assert: Verificar evento Update
    verify(mockBloc.add(
      argThat(isA<UpdateGroupInfoEvent>()
          .having((e) => e.name, 'name', 'Física II')
          .having(
              (e) => e.description, 'description', 'Preparación intensiva')),
    )).called(1);
  });

  testWidgets('H8.5: Debe permitir eliminar el grupo permanentemente (Admin)',
      (tester) async {
    final robot = SettingsRobot(tester);

    // Arrange
    await tester.pumpWidget(MaterialApp(
      home: GroupSettingsPage(group: tGroup, members: tEmptyMembers),
    ));

    // Act: Eliminar
    await robot.tapEliminarGrupo();
    robot.verifyDialogoEliminacionVisible(); // Verificación intermedia
    await robot.confirmarEliminacion();

    // Assert: Verificar evento Delete
    verify(mockBloc.add(
      argThat(
          isA<DeleteGroupEvent>().having((e) => e.groupId, 'groupId', '123')),
    )).called(1);
  });
}
