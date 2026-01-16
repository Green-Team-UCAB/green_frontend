// features/kahoot/domain/repositories/ikahoot_repository.dart

import '../entities/kahoot.dart';

abstract class KahootRepository {
  Future<Kahoot> saveKahoot(Kahoot kahoot);
  Future<List<Kahoot>> getKahoots();
  Future<void> deleteKahoot(String id);
  
  // NUEVO: Agregar método para obtener kahoot por ID
  Future<Kahoot> getKahootById(String id);
}