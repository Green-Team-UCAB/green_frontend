import 'package:green_frontend/features/media/domain/entities/media.dart';
import 'package:green_frontend/features/media/domain/repositories/imedia_repository.dart';

class GetMediaMetadataUseCase {
  final MediaRepository repository;

  GetMediaMetadataUseCase(this.repository);

  Future<MediaAsset> execute(String mediaId) async {
    return await repository.getMediaMetadata(mediaId);
  }
}