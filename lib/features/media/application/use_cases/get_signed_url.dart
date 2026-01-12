import 'package:green_frontend/features/media/domain/repositories/imedia_repository.dart';

class GetSignedUrlUseCase {
  final MediaRepository repository;

  GetSignedUrlUseCase(this.repository);

  Future<String> execute(String mediaId, {Duration? expiry}) async {
    return await repository.getSignedUrl(mediaId, expiry: expiry);
  }
}