import 'package:fpdart/fpdart.dart'; // Usamos fpdart, no dartz
import '../error/failures.dart';

// Renombramos 'Type' a 'T' para evitar conflictos con la palabra reservada
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}
