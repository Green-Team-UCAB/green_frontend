class Group {
  final String id;
  final String name;
  final String? description;
  final String role; // 'admin' | 'member'
  final int memberCount;
  final DateTime createdAt;

  const Group({
    required this.id,
    required this.name,
    this.description,
    required this.role,
    required this.memberCount,
    required this.createdAt,
  });

  // Helpers útiles
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isMember => role.toLowerCase() == 'member';
}
