class ThemeImage {
  final String id;
  final String name;
  final String imageUrl;

  const ThemeImage({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeImage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ThemeImage(id: $id, name: $name)';
}

