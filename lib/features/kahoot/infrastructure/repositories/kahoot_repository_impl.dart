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
    // TODO: Implementar cuando se tenga el endpoint
    return [];
  }

  @override
  Future<void> deleteKahoot(String id) async {
    await remoteDataSource.deleteKahoot(id);
  }

  // ✅ NUEVO: Obtener un kahoot por ID
  Future<Kahoot> getKahootById(String id) async {
    return await remoteDataSource.getKahoot(id);
  }

  // ✅ NUEVO: Actualizar un kahoot existente
  Future<Kahoot> updateKahoot(Kahoot kahoot) async {
    if (kahoot.id == null || kahoot.id!.isEmpty) {
      throw Exception('No se puede actualizar un kahoot sin ID');
    }
    return await remoteDataSource.updateKahoot(kahoot);
  }

  // ✅ NUEVO: Duplicar un kahoot
  Future<Kahoot> duplicateKahoot(String kahootId) async {
    return await remoteDataSource.duplicateKahoot(kahootId);
  }
}