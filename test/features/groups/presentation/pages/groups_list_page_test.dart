import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:green_frontend/injection_container.dart';
import 'package:green_frontend/features/groups/presentation/pages/groups_list_page.dart';
import 'package:green_frontend/features/groups/presentation/bloc/groups_bloc.dart'; // Importa tus Blocs
import 'package:green_frontend/features/groups/domain/entities/group.dart';

// Importamos el Robot Corregido
import '../robots/groups_list_robot.dart';

// Generamos el Mock del Bloc
@GenerateMocks([GroupsBloc])
import 'groups_list_page_test.mocks.dart';

void main() {
  late MockGroupsBloc mockBloc;

  setUp(() async {
    await sl.reset();
    mockBloc = MockGroupsBloc();
    sl.registerFactory<GroupsBloc>(() => mockBloc);

    // Configuración base para evitar errores de null
    when(mockBloc.state).thenReturn(GroupsInitial());
    when(mockBloc.stream).thenAnswer((_) => Stream.value(GroupsInitial()));
  });

  // Datos de prueba (Fixtures)
  final tGroup = Group(
    id: '1',
    name: 'Matemáticas 101',
    description: 'Clase lunes',
    role: 'member',
    memberCount: 5,
    createdAt: DateTime.now(),
  );

  testWidgets('H8.1: Debe mostrar el Empty State cuando no hay grupos',
      (tester) async {
    final robot = GroupsListRobot(tester);

    // Arrange: Simulamos que el Bloc cargó una lista vacía
    when(mockBloc.state).thenReturn(GroupsLoaded(const []));
    when(mockBloc.stream)
        .thenAnswer((_) => Stream.value(GroupsLoaded(const [])));

    // Act: Renderizamos la UI
    await tester.pumpWidget(const MaterialApp(home: GroupsListPage()));
    await tester.pump(); // Esperamos que se pinte el estado inicial

    // Assert: El robot verifica que se vea el icono y texto de vacío
    robot.verifyEmptyState();
  });

  testWidgets('H8.1: Debe mostrar la tarjeta del grupo cuando existen datos',
      (tester) async {
    final robot = GroupsListRobot(tester);

    // Arrange: Simulamos que el Bloc tiene 1 grupo
    when(mockBloc.state).thenReturn(GroupsLoaded([tGroup]));
    when(mockBloc.stream)
        .thenAnswer((_) => Stream.value(GroupsLoaded([tGroup])));

    // Act
    await tester.pumpWidget(const MaterialApp(home: GroupsListPage()));
    await tester.pump();

    // Assert: El robot verifica que aparezca el nombre del grupo
    robot.verifyGroupVisible('Matemáticas 101');
  });

  testWidgets('H8.2: Debe permitir crear un grupo nuevo exitosamente',
      (tester) async {
    final robot = GroupsListRobot(tester);

    // Arrange: Iniciamos en la lista (estado inicial)
    when(mockBloc.state).thenReturn(GroupsLoaded(const []));
    when(mockBloc.stream)
        .thenAnswer((_) => Stream.value(GroupsLoaded(const [])));

    // Act & Assert (Flujo BDD)
    await tester.pumpWidget(const MaterialApp(home: GroupsListPage()));
    await tester.pump();

    // Pasos del usuario (interactuando con el Robot)
    await robot.tapFabNuevo();
    await robot.tapOpcionCrearGrupo();
    await robot.llenarFormularioCreacion(
        'Física Avanzada', 'Grupo para el final');
    await robot.tapConfirmarCrear();

    // Verificamos que el Bloc recibió el evento exacto
    verify(mockBloc.add(
      argThat(isA<CreateGroupEvent>()
          .having((e) => e.name, 'name', 'Física Avanzada')
          .having((e) => e.description, 'description', 'Grupo para el final')),
    )).called(1);
  });
}
