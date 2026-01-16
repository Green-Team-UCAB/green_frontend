import '../entities/media.dart';

abstract class MediaRepository {
  Future<MediaAsset> uploadMedia(String filePath, String fileName);
  Future<MediaAsset> getMediaMetadata(String mediaId);
  Future<void> deleteMedia(String mediaId);
  Future<String> getSignedUrl(String mediaId, {Duration? expiry});
  Future<List<MediaAsset>> getUserMedia();
  Future<String> downloadMedia(String mediaId, String savePath);
  Future<MediaAsset> saveMediaLocally(MediaAsset media, String localPath);
}