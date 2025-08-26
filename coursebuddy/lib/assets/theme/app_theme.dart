import 'package:flutter/material.dart';

class AppTheme {
  static final Color primaryColor = Colors.orangeAccent;

  static final Color secondaryColor = Colors.lightBlueAccent;

  static final Color backgroundColor = Colors.white;

  static final Color textColor = Colors.black87;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    primaryColor: primaryColor,

    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),

    scaffoldBackgroundColor: backgroundColor,

    textTheme: TextTheme(bodyMedium: TextStyle(color: textColor)),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,

        foregroundColor: Colors.white,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
