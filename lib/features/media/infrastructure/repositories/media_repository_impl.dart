import 'dart:io';
import 'package:green_frontend/features/media/domain/entities/media.dart';
import 'package:green_frontend/features/media/domain/repositories/imedia_repository.dart';
import 'package:green_frontend/features/media/infrastructure/datasources/media_local_datasource.dart';
import 'package:green_frontend/features/media/infrastructure/datasources/media_remote_datasource.dart';
import 'package:green_frontend/features/media/infrastructure/mappers/media_mapper.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaLocalDataSource localDataSource;
  final MediaRemoteDataSource remoteDataSource;

  MediaRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<MediaAsset> uploadMedia(String filePath, String fileName) async {
    try {
      // Primero guardamos localmente
      final localMedia = await localDataSource.saveMediaLocally(filePath, fileName);
      
      // Luego subimos al servidor
      final remoteResponse = await remoteDataSource.uploadMedia(filePath, fileName);
      
      // Mapeamos la respuesta remota
      final mediaAsset = MediaMapper.fromRemoteMap(remoteResponse);
      
      // Combinamos con la información local
      return mediaAsset.copyWith(
        localPath: localMedia.localPath,
        isLocal: true,
      );
    } catch (e) {
      // Si falla el upload remoto, retornamos solo el archivo local
      final localMedia = await localDataSource.saveMediaLocally(filePath, fileName);
      return localMedia;
    }
  }

  @override
  Future<MediaAsset> getMediaMetadata(String mediaId) async {
    final remoteData = await remoteDataSource.getMediaMetadata(mediaId);
    final mediaAsset = MediaMapper.fromRemoteMap(remoteData);
    
    // Verificamos si tenemos una copia local
    final localPath = await localDataSource.getLocalPath(mediaId);
    if (localPath != null) {
      return mediaAsset.copyWith(
        localPath: localPath,
        isLocal: true,
      );
    }
    
    return mediaAsset;
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    // Eliminamos localmente
    await localDataSource.deleteMedia(mediaId);
    
    // Eliminamos remotamente
    try {
      await remoteDataSource.deleteMedia(mediaId);
    } catch (e) {
      // Si falla la eliminación remota, al menos borramos localmente
      print('Error al eliminar media remotamente: $e');
    }
  }

  @override
  Future<String> getSignedUrl(String mediaId, {Duration? expiry}) async {
    return await remoteDataSource.getSignedUrl(mediaId, expiry: expiry);
  }

  @override
  Future<List<MediaAsset>> getUserMedia() async {
    final remoteMedia = await remoteDataSource.getUserMedia();
    final mediaAssets = remoteMedia.map(MediaMapper.fromRemoteMap).toList();
    
    // Verificamos cuáles tenemos localmente
    final List<MediaAsset> result = [];
    for (var media in mediaAssets) {
      final localPath = await localDataSource.getLocalPath(media.id);
      if (localPath != null) {
        result.add(media.copyWith(localPath: localPath, isLocal: true));
      } else {
        result.add(media);
      }
    }
    
    return result;
  }

  @override
  Future<String> downloadMedia(String mediaId, String savePath) async {
    return await localDataSource.downloadMedia(mediaId, savePath);
  }

  @override
  Future<MediaAsset> saveMediaLocally(MediaAsset media, String localPath) async {
    return await localDataSource.updateMediaLocalPath(media, localPath);
  }
}