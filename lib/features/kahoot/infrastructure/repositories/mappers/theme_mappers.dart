import 'package:green_frontend/features/kahoot/domain/entities/theme_image.dart';

class ThemeMapper {
  static ThemeImage fromJson(Map<String, dynamic> json) {
    final id = json['AssetId'] ?? json['assetId']?.toString() ?? '';
    final name = json['Name'] ?? json['name']?.toString() ?? '';
    final imageUrl = json['Url'] ?? json['url']?.toString() ?? '';

    return ThemeImage(
      id: id,
      name: name,
      imageUrl: imageUrl,
    );
  }

  static Map<String, dynamic> toJson(ThemeImage theme) {
    return {
      'Id': theme.id,
      'Name': theme.name,
      'ImageUrl': theme.imageUrl,
    };
  }
}
