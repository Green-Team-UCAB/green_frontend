import 'package:green_frontend/features/media/domain/repositories/imedia_repository.dart';

class DeleteMediaUseCase {
  final MediaRepository repository;

  DeleteMediaUseCase(this.repository);

  Future<void> execute(String mediaId) async {
    return await repository.deleteMedia(mediaId);
  }
}