import 'package:green_frontend/features/kahoot/domain/entities/kahoot.dart';
import 'package:green_frontend/features/kahoot/domain/repositories/ikahoot_repository.dart';
import 'package:green_frontend/features/kahoot/infrastructure/datasources/kahoot_remote_datasource.dart';


class KahootRepositoryImpl implements KahootRepository {
  final KahootRemoteDataSource remoteDataSource;

  KahootRepositoryImpl(this.remoteDataSource);

  @override
  Future<Kahoot> saveKahoot(Kahoot kahoot) async {
    return await remoteDataSource.saveKahoot(kahoot);
  }

  @override
  Future<List<Kahoot>> getKahoots() async {
    // Implementar cuando se tenga  el endpoint
    return [];
  }

  @override
  Future<void> deleteKahoot(String id) async {
    // Implementar cuando se tenga  el endpoint
  }
}