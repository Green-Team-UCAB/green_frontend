import 'package:green_frontend/features/media/domain/entities/media.dart';
import 'package:green_frontend/features/media/domain/repositories/imedia_repository.dart';

class UploadMediaUseCase {
  final MediaRepository repository;

  UploadMediaUseCase(this.repository);

  Future<MediaAsset> execute(String filePath, String fileName) async {
    return await repository.uploadMedia(filePath, fileName);
  }
}