import 'package:dartz/dartz.dart';
import 'dart:math';
import '../../../../core/error/failures.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/groups_repository.dart';
import '../datasources/groups_remote_data_source.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;

  // 🛠️ MOCK STATE (In-Memory persistence for the session)
  // Initializes with some default groups
  final List<GroupEntity> _mockGroups = [
    GroupEntity(
      id: 'g-1',
      name: 'Matemáticas 101',
      description: 'Grupo avanzado de cálculo y álgebra.',
      role: 'admin',
      memberCount: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    GroupEntity(
      id: 'g-2',
      name: 'Historia Universal',
      description: 'Desde la antigüedad hasta el siglo XXI.',
      role: 'member',
      memberCount: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  GroupsRepositoryImpl({required this.remoteDataSource});

  // ===========================================================================
  // ⚙️ HELPER DE EJECUCIÓN
  // ===========================================================================
  Future<Either<Failure, T>> _execute<T>(
    Future<T> Function() call,
    Future<T> Function() mockFallback,
  ) async {
    try {
      final result = await call();
      return Right(result);
    } catch (e) {
      print("⚠️ [GroupsRepo] Falló API ($e). Usando Mock.");
      await Future.delayed(
        const Duration(milliseconds: 600),
      ); // Latencia simulada
      return Right(await mockFallback());
    }
  }

  // ===========================================================================
  // IMPLEMENTACIÓN DE MÉTODOS
  // ===========================================================================

  @override
  Future<Either<Failure, List<GroupEntity>>> getMyGroups() {
    return _execute(
      () => remoteDataSource.getMyGroups(),
      () async => List.from(_mockGroups), // Return copy of current state
    );
  }

  @override
  Future<Either<Failure, GroupEntity>> createGroup(
    String name,
    String description,
  ) {
    return _execute(
      () async {
        final group = await remoteDataSource.createGroup(name, description);
        // If API succeeds, we can opt to sync our mock list or just return
        return group;
      },
      () async {
        final newGroup = GroupEntity(
          id: 'new-g-${Random().nextInt(1000)}',
          name: name,
          description: description,
          role: 'admin', // Creator is always admin
          memberCount: 1,
          createdAt: DateTime.now(),
        );
        _mockGroups.add(newGroup);
        return newGroup;
      },
    );
  }

  @override
  Future<Either<Failure, GroupEntity>> joinGroup(String token) {
    return _execute(() => remoteDataSource.joinGroup(token), () async {
      final joinedGroup = GroupEntity(
        id: 'joined-g-${Random().nextInt(1000)}',
        name: 'Grupo Unido ($token)',
        description: 'Grupo al que te uniste con código.',
        role: 'member',
        memberCount: 5 + Random().nextInt(10),
        createdAt: DateTime.now(),
      );
      _mockGroups.add(joinedGroup);
      return joinedGroup;
    });
  }

  // Cache para los detalles generados (para mantener persistencia en sesión)
  final Map<String, Map<String, dynamic>> _mockDetailsCache = {};

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupDetails(
    String groupId,
  ) {
    return _execute(() => remoteDataSource.getGroupDetails(groupId), () async {
      // 1. Si ya tenemos detalles cacheados para este grupo, los devolvemos.
      // Esto permite que si asignamos un quiz o eliminamos, se mantenga el cambio.
      if (_mockDetailsCache.containsKey(groupId)) {
        return _mockDetailsCache[groupId]!;
      }

      // Intenta encontrar el grupo en el estado local
      final group = _mockGroups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => GroupEntity(
          id: groupId,
          name: 'Grupo Desconocido',
          role: 'member',
          memberCount: 0,
          createdAt: DateTime.now(),
        ),
      );

      final bool isAdmin = group.role == 'admin';

      // 🎲 Generador determinista basado en el ID del grupo
      // Esto asegura que cada grupo tenga datos distintos pero consistentes
      final random = Random(groupId.hashCode);

      // Generar 1-3 quizzes aleatorios
      final quizzesCount = 1 + random.nextInt(3);
      final generatedQuizzes = List.generate(quizzesCount, (index) {
        final isCompleted = random.nextBool();
        return {
          'assignmentId': 'mock-quiz-$groupId-$index',
          'title':
              'Actividad ${index + 1}: ${['Conceptos Básicos', 'Evaluación Final', 'Repaso', 'Historia', 'Ciencias'][random.nextInt(5)]}',
          'status': isCompleted ? 'COMPLETED' : 'PENDING',
          'availableUntil': DateTime.now()
              .add(Duration(days: 1 + random.nextInt(10)))
              .toIso8601String(),
          'userResult': isCompleted
              ? {'score': 500 + random.nextInt(1000)}
              : null,
        };
      });

      // Generar ranking aleatorio (3-8 personas)
      final membersCount = 3 + random.nextInt(6);
      final memberNames = [
        'Ana García',
        'Carlos Perez',
        'Luis Diaz',
        'Maria Lopez',
        'Juan Silva',
        'Elena Gomez',
        'Pedro Ruiz',
        'Sofia Torres',
        'Diego Castro',
        'Lucia Vives',
      ];

      final generatedLeaderboard = List.generate(membersCount, (index) {
        final name = memberNames[random.nextInt(memberNames.length)];
        return {
          'userId': 'mock-u-$groupId-$index',
          'name': name,
          'totalPoints': 100 + random.nextInt(5000),
        };
      });

      // Ordenar por puntos descendente
      generatedLeaderboard.sort(
        (a, b) => (b['totalPoints'] as int).compareTo(a['totalPoints'] as int),
      );

      // Asignar posición
      for (var i = 0; i < generatedLeaderboard.length; i++) {
        generatedLeaderboard[i]['position'] = i + 1;
      }

      // Añadir al usuario actual en una posición aleatoria o fija
      generatedLeaderboard.add({
        'userId': 'u-me',
        'name': 'Tú ${isAdmin ? '(Admin)' : ''}',
        'totalPoints': 3200, // Tus puntos fijos para demo
        'position': membersCount + 1, // Al final por simplicidad de mezcla
      });
      // Reordenar final
      generatedLeaderboard.sort(
        (a, b) => (b['totalPoints'] as int).compareTo(a['totalPoints'] as int),
      );
      for (var i = 0; i < generatedLeaderboard.length; i++) {
        generatedLeaderboard[i]['position'] = i + 1;
      }

      final generatedMembers = generatedLeaderboard
          .map(
            (e) => {
              'userId': e['userId'],
              'name': e['name'],
              'role': e['userId'] == 'u-me' ? group.role : 'member',
            },
          )
          .toList();

      final details = {
        'group': group,
        'quizzes': generatedQuizzes,
        'leaderboard': generatedLeaderboard,
        'members': generatedMembers,
      };

      // Guardamos en caché
      _mockDetailsCache[groupId] = details;
      return details;
    });
  }

  @override
  Future<Either<Failure, String>> generateInvitationLink(String groupId) {
    return _execute(
      () => remoteDataSource.generateInvitationLink(groupId),
      () async =>
          "https://kahoot-clone.com/join/${groupId.substring(0, 4)}-xyz", // Mock Link
    );
  }

  @override
  Future<Either<Failure, void>> assignQuiz(
    String groupId,
    String quizId,
    String availableUntil, {
    String? quizTitle,
  }) {
    return _execute(
      () => remoteDataSource.assignQuiz(groupId, quizId, availableUntil),
      () async {
        // Actualizamos la caché mock para que aparezca el nuevo quiz
        if (_mockDetailsCache.containsKey(groupId)) {
          final details = _mockDetailsCache[groupId]!;
          final quizzes = details['quizzes'] as List;
          quizzes.add({
            'assignmentId':
                'mock-assign-${DateTime.now().millisecondsSinceEpoch}',
            'title': quizTitle ?? 'Nueva Actividad Asignada',
            'status': 'PENDING',
            'availableUntil': availableUntil,
            'userResult': null,
          });
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> updateGroup(
    String groupId,
    String name,
    String description,
  ) {
    return _execute(
      () => remoteDataSource.updateGroup(groupId, name, description),
      () async {
        final index = _mockGroups.indexWhere((g) => g.id == groupId);
        if (index != -1) {
          final old = _mockGroups[index];
          _mockGroups[index] = GroupEntity(
            id: old.id,
            name: name,
            description: description,
            role: old.role,
            memberCount: old.memberCount,
            createdAt: old.createdAt,
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> kickMember(String groupId, String memberId) {
    return _execute(
      () => remoteDataSource.kickMember(groupId, memberId),
      () async {
        // In a real mock we would remove from 'members' list inside the group details,
        // but since details are generated on the fly, we just simulate success.
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteGroup(String groupId) {
    return _execute(() => remoteDataSource.deleteGroup(groupId), () async {
      _mockGroups.removeWhere((g) => g.id == groupId);
    });
  }
}
