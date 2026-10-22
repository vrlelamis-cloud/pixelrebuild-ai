import 'package:flutter/material.dart';

/// Thème sombre Material 3 de l’application.
ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: const Color(0xFF4285FF),
    scaffoldBackgroundColor: const Color(0xFF0B0F19),
  );
}
