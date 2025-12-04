import 'package:kahoot_project/features/kahoot/domain/repositories/itheme_repository.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/repositories/mappers/theme_mappers.dart';
import 'package:kahoot_project/features/kahoot/domain/entities/theme_image.dart';
import 'package:kahoot_project/features/kahoot/infrastructure/datasources/theme_remote_datasource.dart';


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