class GroupMember {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin', 'member'

  const GroupMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });
}
