import 'package:green_frontend/features/kahoot/domain/entities/theme_image.dart';
import 'package:green_frontend/features/kahoot/domain/repositories/itheme_repository.dart';
import 'package:green_frontend/features/kahoot/infrastructure/datasources/theme_remote_datasource.dart';
import 'package:green_frontend/features/kahoot/infrastructure/repositories/mappers/theme_mappers.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeRemoteDataSource remoteDataSource;

  ThemeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ThemeImage>> getThemes() async {
    try {
      final themesData = await remoteDataSource.getThemes();
      
      // Filtrar solo los elementos que son temas (contienen "Tema" en el nombre)
      final filteredThemes = themesData.where((item) {
        final name = item['name']?.toString() ?? '';
        return name.contains('Tema') || name.contains('tema');
      }).toList();
      
      final themes = filteredThemes.map((json) => ThemeMapper.fromJson(json)).toList();
      
      return themes;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadMedia(String filePath, String fileName) async {
    try {
      final response = await remoteDataSource.uploadMedia(filePath, fileName);
      return response['id'];
    } catch (e) {
      rethrow;
    }
  }
}

