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

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGroupDetails(
    String groupId,
  ) {
    return _execute(() => remoteDataSource.getGroupDetails(groupId), () async {
      // Enforce finding the group in our local state to ensure consistency
      // If not found (e.g. came from real API?), fallback to a generic one or error
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

      return {
        'group': group,
        // Lista de Quizes Asignados (H8.7)
        'quizzes': [
          {
            'assignmentId': 'a-1',
            'title': 'Álgebra Básica',
            'status': 'COMPLETED',
            'availableUntil': DateTime.now()
                .add(const Duration(days: 2))
                .toIso8601String(),
            'userResult': {'score': 1200},
          },
          if (isAdmin) // Add an extra quiz for admin view demo
            {
              'assignmentId': 'a-2',
              'title': 'Geometría y Espacio',
              'status': 'PENDING',
              'availableUntil': DateTime.now()
                  .add(const Duration(days: 5))
                  .toIso8601String(),
              'userResult': null,
            },
        ],
        // Ranking del Grupo (H8.9)
        'leaderboard': [
          {
            'userId': 'u-1',
            'name': 'Ana García',
            'totalPoints': 5400,
            'position': 1,
          },
          {
            'userId': 'u-2',
            'name': 'Carlos Perez',
            'totalPoints': 4800,
            'position': 2,
          },
          if (isAdmin) // Show "You" differently if admin? mostly same
            {
              'userId': 'u-me',
              'name': 'Tú (Admin)',
              'totalPoints': 3200,
              'position': 3,
            }
          else
            {
              'userId': 'u-me',
              'name': 'Tú',
              'totalPoints': 3200,
              'position': 3,
            },
          {
            'userId': 'u-4',
            'name': 'Luis Diaz',
            'totalPoints': 1000,
            'position': 4,
          },
        ],
        // Miembros (Para gestión H8.4)
        'members': [
          // Include 'Me'
          {'userId': 'u-me', 'name': 'Tú', 'role': group.role},
          {'userId': 'u-1', 'name': 'Ana García', 'role': 'member'},
          {'userId': 'u-4', 'name': 'Luis Diaz', 'role': 'member'},
        ],
      };
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
    String availableUntil,
  ) {
    return _execute(
      () => remoteDataSource.assignQuiz(groupId, quizId, availableUntil),
      () async {}, // Void success
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
