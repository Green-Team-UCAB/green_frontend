import '../../../../core/network/api_client.dart';
import '../models/group_model.dart';
import '../models/group_quiz_assignment_model.dart';
import '../models/group_leaderboard_entry_model.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getMyGroups();
  Future<GroupModel> createGroup(String name, String description);
  Future<GroupModel> joinGroup(String token);

  // ✅ Métodos separados y tipados correctamente
  Future<List<GroupQuizAssignmentModel>> getGroupQuizzes(String groupId);
  Future<List<GroupLeaderboardEntryModel>> getGroupLeaderboard(String groupId);

  Future<String> generateInvitationLink(String groupId);

  // ✅ Asignación con fechas correctas
  Future<void> assignQuiz(String groupId, String quizId, DateTime availableFrom,
      DateTime availableUntil);

  Future<void> updateGroup(String groupId, String name, String description);
  Future<void> kickMember(String groupId, String memberId);
  Future<void> deleteGroup(String groupId);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final ApiClient apiClient;

  GroupsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<GroupModel>> getMyGroups() async {
    final response = await apiClient.get(path: '/groups');
    // Mapeo seguro de la lista
    return (response.data as List).map((e) => GroupModel.fromJson(e)).toList();
  }

  @override
  Future<GroupModel> createGroup(String name, String description) async {
    final response = await apiClient.post(
      path: '/groups',
      data: {
        'name': name,
        'description': description
      }, // Descripción opcional según tu doc?
    );
    return GroupModel.fromJson(response.data);
  }

  @override
  Future<GroupModel> joinGroup(String token) async {
    final response = await apiClient.post(
      path: '/groups/join',
      // ⚠️ CORRECCIÓN IMPORTANTE: La doc dice "invitationToken", no "token"
      data: {'invitationToken': token},
    );

    // La doc dice que retorna info del grupo al unirse.
    return GroupModel.fromJson(response.data);
  }

  @override
  Future<List<GroupQuizAssignmentModel>> getGroupQuizzes(String groupId) async {
    // ✅ URL ESPECÍFICA: Esto evita mezclar kahoots de otros grupos
    final response = await apiClient.get(path: '/groups/$groupId/quizzes');

    // La doc dice: { data: [...] }
    final data = response.data;
    List listData = [];

    if (data is Map && data.containsKey('data')) {
      listData = data['data'];
    } else if (data is List) {
      listData = data;
    }

    return listData.map((e) => GroupQuizAssignmentModel.fromJson(e)).toList();
  }

  @override
  Future<List<GroupLeaderboardEntryModel>> getGroupLeaderboard(
      String groupId) async {
    // ✅ URL ESPECÍFICA
    final response = await apiClient.get(path: '/groups/$groupId/leaderboard');

    // La doc dice que retorna un array directo [...]
    return (response.data as List)
        .map((e) => GroupLeaderboardEntryModel.fromJson(e))
        .toList();
  }

  @override
  Future<String> generateInvitationLink(String groupId) async {
    // ⚠️ CORRECCIÓN: La doc dice "/invitations", no "/invite"
    // ⚠️ CORRECCIÓN: La doc dice body { "expiresIn": "7d" }
    final response = await apiClient.post(
      path: '/groups/$groupId/invitations',
      data: {'expiresIn': '7d'},
    );

    // La doc dice response: { "invitationLink": "..." }
    return response.data['invitationLink'];
  }

  @override
  Future<void> assignQuiz(
    String groupId,
    String quizId,
    DateTime availableFrom,
    DateTime availableUntil,
  ) async {
    await apiClient.post(
      path: '/groups/$groupId/quizzes',
      data: {
        'quizId': quizId,
        'availableFrom': availableFrom.toIso8601String(),
        'availableUntil': availableUntil.toIso8601String(),
      },
    );
  }

  @override
  Future<void> updateGroup(
      String groupId, String name, String description) async {
    await apiClient.patch(
      // La doc dice PATCH, tu código tenía PUT
      path: '/groups/$groupId',
      data: {'name': name, 'description': description},
    );
  }

  @override
  Future<void> kickMember(String groupId, String memberId) async {
    await apiClient.delete(path: '/groups/$groupId/members/$memberId');
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await apiClient.delete(path: '/groups/$groupId');
  }
}
