import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF315D50),
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: const Color(0xFFF5F2EA),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F2EA),
      foregroundColor: Color(0xFF252C29),
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF315D50),
      brightness: Brightness.dark,
    ),
  );
}