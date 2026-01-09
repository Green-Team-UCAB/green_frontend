class GroupEntity {
  final String id;
  final String name;
  final String? description;
  final String role; // 'admin' | 'member'
  final int memberCount;
  final DateTime createdAt;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    required this.role,
    required this.memberCount,
    required this.createdAt,
  });

  bool get isAdmin {
    final r = role.toLowerCase();
    return r == 'admin' || r == 'owner' || r == 'creator';
  }
}
