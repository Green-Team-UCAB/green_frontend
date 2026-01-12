import '../entities/theme_image.dart';

abstract class ThemeRepository {
  Future<List<ThemeImage>> getThemes();
}
