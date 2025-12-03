import '../entities/kahoot.dart';

abstract class KahootRepository {
  Future<Kahoot> saveKahoot(Kahoot kahoot);
  Future<List<Kahoot>> getKahoots();
  Future<void> deleteKahoot(String id);
}