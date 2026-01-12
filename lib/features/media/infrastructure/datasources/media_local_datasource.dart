import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:green_frontend/features/media/domain/entities/media.dart';

class MediaLocalDataSource {
  static const String _mediaDir = 'media';
  static const String _thumbnailsDir = 'thumbnails';

  Future<MediaAsset> saveMediaLocally(String filePath, String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/$_mediaDir');
    
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    
    final originalFile = File(filePath);
    final stats = await originalFile.stat();
    
    // Generar nombre único
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final localPath = '${mediaDir.path}/$uniqueName';
    
    // Copiar archivo
    await originalFile.copy(localPath);
    
    // Crear thumbnail para imágenes
    String? thumbnailPath;
    if (_isImage(fileName)) {
      thumbnailPath = await _createThumbnail(filePath, uniqueName);
    }
    
    return MediaAsset(
      id: uniqueName, // ID temporal local
      path: localPath,
      url: localPath, // Usamos la ruta local como URL temporal
      mimeType: _getMimeType(fileName),
      size: stats.size,
      originalName: fileName,
      createdAt: DateTime.now(),
      format: path.extension(fileName).replaceFirst('.', ''),
      category: _getCategory(fileName),
      localPath: localPath,
      thumbnailUrl: thumbnailPath,
      isLocal: true,
    );
  }

  Future<String?> getLocalPath(String mediaId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/$_mediaDir');
    
    if (!await mediaDir.exists()) {
      return null;
    }
    
    final files = await mediaDir.list().toList();
    for (var file in files) {
      if (file is File && path.basename(file.path).contains(mediaId)) {
        return file.path;
      }
    }
    
    return null;
  }

  Future<void> deleteMedia(String mediaId) async {
    final localPath = await getLocalPath(mediaId);
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    
    // Eliminar thumbnail si existe
    final appDir = await getApplicationDocumentsDirectory();
    final thumbnailFile = File('${appDir.path}/$_thumbnailsDir/$mediaId');
    if (await thumbnailFile.exists()) {
      await thumbnailFile.delete();
    }
  }

  Future<String> downloadMedia(String mediaId, String savePath) async {
    final localPath = await getLocalPath(mediaId);
    if (localPath != null) {
      final sourceFile = File(localPath);
      final destFile = File(savePath);
      await sourceFile.copy(destFile.path);
      return savePath;
    }
    
    throw Exception('Media not found locally');
  }

  Future<MediaAsset> updateMediaLocalPath(MediaAsset media, String localPath) async {
    return media.copyWith(localPath: localPath, isLocal: true);
  }

  // Métodos auxiliares
  bool _isImage(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(ext);
  }

  String _getMimeType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mp3':
        return 'audio/mp3';
      default:
        return 'application/octet-stream';
    }
  }

  String _getCategory(String fileName) {
    final mimeType = _getMimeType(fileName);
    if (mimeType.startsWith('image/')) return 'image';
    if (mimeType.startsWith('video/')) return 'video';
    if (mimeType.startsWith('audio/')) return 'audio';
    return 'other';
  }

  Future<String?> _createThumbnail(String filePath, String baseName) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbnailsDir = Directory('${appDir.path}/$_thumbnailsDir');
      
      if (!await thumbnailsDir.exists()) {
        await thumbnailsDir.create(recursive: true);
      }
      
      final thumbnailPath = '${thumbnailsDir.path}/${baseName}_thumb.jpg';
      
      // En una implementación real, usaríamos un paquete como image
      // para crear thumbnails. Por ahora, simplemente copiamos el archivo.
      final originalFile = File(filePath);
      await originalFile.copy(thumbnailPath);
      
      return thumbnailPath;
    } catch (e) {
      print('Error creando thumbnail: $e');
      return null;
    }
  }
}