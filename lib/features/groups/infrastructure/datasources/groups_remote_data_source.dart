import '../../../../core/network/api_client.dart';
import '../models/group_model.dart';

abstract class GroupsRemoteDataSource {
  Future<List<GroupModel>> getMyGroups();
  Future<GroupModel> createGroup(String name, String description);
  Future<GroupModel> joinGroup(String token);
  Future<List<dynamic>> getGroupQuizzes(String groupId);
  Future<Map<String, dynamic>> getGroupDetails(String groupId);
  Future<String> generateInvitationLink(String groupId);
  Future<void> assignQuiz(String groupId, String quizId, String availableUntil);
  Future<void> updateGroup(String groupId, String name, String description);
  Future<void> kickMember(String groupId, String memberId);
  Future<void> deleteGroup(String groupId);
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final ApiClient apiClient;

  GroupsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<GroupModel>> getMyGroups() async {
    // Usamos el ApiClient que ya inyecta el token automáticamente
    final response = await apiClient.get(path: '/groups');

    // La API devuelve una lista directa: [ {...}, {...} ]
    return (response.data as List).map((e) => GroupModel.fromJson(e)).toList();
  }

  @override
  Future<GroupModel> createGroup(String name, String description) async {
    final response = await apiClient.post(
      path: '/groups',
      data: {'name': name, 'description': description},
    );

    return GroupModel.fromJson(response.data);
  }

  @override
  Future<GroupModel> joinGroup(String token) async {
    final response = await apiClient.post(
      path: '/groups/join',
      data: {'token': token},
    );
    return GroupModel.fromJson(response.data);
  }

  @override
  Future<List<dynamic>> getGroupQuizzes(String groupId) async {
    final response = await apiClient.get(path: '/groups/$groupId/quizzes');
    // La respuesta según el usuario es { data: [...] } o directamente [...]?
    // El "Esqueleto JSON (Response)" muestra "{ data: [...] }"
    if (response.data is Map && response.data.containsKey('data')) {
      return response.data['data'];
    } else if (response.data is List) {
      return response.data;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getGroupDetails(String groupId) async {
    // 1. Obtener Metadatos del Grupo
    final groupResponse = await apiClient.get(path: '/groups/$groupId');

    // 2. Obtener Quizzes del Grupo (Nuevo Endpoint)
    List<dynamic> quizzes = [];
    try {
      quizzes = await getGroupQuizzes(groupId);
    } catch (e) {
      print("⚠️ Error fetching quizzes separately: $e");
    }

    // 3. Obtener Ranking/Miembros (Si hay endpoints separados, agregarlos aquí.
    // Por ahora asumimos que vienen en el endpoint principal o se manejan separados,
    // pero para mantener compatibilidad con el Repository, mezclamos aquí).

    final data = Map<String, dynamic>.from(groupResponse.data);
    data['quizzes'] = quizzes;

    return data;
  }

  @override
  Future<String> generateInvitationLink(String groupId) async {
    final response = await apiClient.post(path: '/groups/$groupId/invite');
    return response.data['link'];
  }

  @override
  Future<void> assignQuiz(
    String groupId,
    String quizId,
    String availableUntil,
  ) async {
    // Nuevo path y body según documentación
    await apiClient.post(
      path: '/groups/$groupId/quizzes',
      data: {
        'quizId': quizId,
        'availableFrom': DateTime.now().toIso8601String(),
        'availableUntil': availableUntil,
      },
    );
  }

  @override
  Future<void> updateGroup(
    String groupId,
    String name,
    String description,
  ) async {
    await apiClient.put(
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
