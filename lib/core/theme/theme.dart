import 'package:flutter/material.dart';
import 'app_pallete.dart';

class AppTheme{
  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
  );

}