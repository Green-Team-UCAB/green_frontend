import 'package:green_frontend/features/single_player/domain/repositories/async_game_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:green_frontend/core/error/failures.dart';
import 'package:green_frontend/features/single_player/domain/entities/kahoot.dart';


class GetKahootPreview {
  final AsyncGameRepository repository;
  GetKahootPreview(this.repository);

  Future<Either<Failure,Kahoot>> call(String kahootId) async {
    if (kahootId.isEmpty){
      return left(InvalidInputFailure('EL ID del kahoot no puede estar vacío'));
    }
    return await repository.getKahootPreview(kahootId: kahootId);
  }
}