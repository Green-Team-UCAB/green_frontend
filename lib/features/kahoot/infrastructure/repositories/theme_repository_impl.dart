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
      return themesData.map((json) => ThemeMapper.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}