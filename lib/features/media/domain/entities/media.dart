class MediaAsset {
  final String id;
  final String path;
  final String url;
  final String mimeType;
  final int size;
  final String originalName;
  final DateTime createdAt;
  final String format;
  final String category;
  final String? localPath; // Ruta local del archivo
  final String? thumbnailUrl; // URL para vista previa
  final bool isLocal; // Indica si el archivo está solo localmente

  MediaAsset({
    required this.id,
    required this.path,
    required this.url,
    required this.mimeType,
    required this.size,
    required this.originalName,
    required this.createdAt,
    required this.format,
    required this.category,
    this.localPath,
    this.thumbnailUrl,
    this.isLocal = false,
  });

  bool get isImage =>
      mimeType.startsWith('image/') &&
      ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(format.toLowerCase());

  bool get isAudio => mimeType.startsWith('audio/');

  bool get isVideo => mimeType.startsWith('video/');

  factory MediaAsset.empty() => MediaAsset(
        id: '',
        path: '',
        url: '',
        mimeType: '',
        size: 0,
        originalName: '',
        createdAt: DateTime.now(),
        format: '',
        category: '',
        isLocal: true,
      );

  MediaAsset copyWith({
    String? id,
    String? path,
    String? url,
    String? mimeType,
    int? size,
    String? originalName,
    DateTime? createdAt,
    String? format,
    String? category,
    String? localPath,
    String? thumbnailUrl,
    bool? isLocal,
  }) {
    return MediaAsset(
      id: id ?? this.id,
      path: path ?? this.path,
      url: url ?? this.url,
      mimeType: mimeType ?? this.mimeType,
      size: size ?? this.size,
      originalName: originalName ?? this.originalName,
      createdAt: createdAt ?? this.createdAt,
      format: format ?? this.format,
      category: category ?? this.category,
      localPath: localPath ?? this.localPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isLocal: isLocal ?? this.isLocal,
    );
  }
}