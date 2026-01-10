import 'package:green_frontend/features/media/domain/entities/media.dart';

class MediaMapper {
  static MediaAsset fromRemoteMap(Map<String, dynamic> map) {
    return MediaAsset(
      id: map['assetId'] ?? map['id'] ?? '',
      path: map['path'] ?? '',
      url: map['url'] ?? '',
      mimeType: map['mimeType'] ?? '',
      size: map['size'] ?? 0,
      originalName: map['originalName'] ?? map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      format: map['format'] ?? '',
      category: map['category'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      isLocal: false,
    );
  }

  static Map<String, dynamic> toRemoteMap(MediaAsset media) {
    return {
      'assetId': media.id,
      'url': media.url,
      'mimeType': media.mimeType,
      'size': media.size,
      'originalName': media.originalName,
      'createdAt': media.createdAt.toIso8601String(),
      'format': media.format,
      'category': media.category,
      'thumbnailUrl': media.thumbnailUrl,
    };
  }
}