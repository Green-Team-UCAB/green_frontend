import 'package:kahoot_project/features/kahoot/domain/entities/theme_image.dart';



class ThemeMapper {
  static ThemeImage fromJson(Map<String, dynamic> json) {
    return ThemeImage(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  static Map<String, dynamic> toJson(ThemeImage theme) {
    return {
      'id': theme.id,
      'name': theme.name,
      'imageUrl': theme.imageUrl,
    };
  }
}