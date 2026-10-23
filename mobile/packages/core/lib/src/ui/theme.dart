import 'package:flutter/material.dart';

/// Brand seed colour — every Material 3 colour is derived from it.
const podwozkaSeedColor = Color(0xFF1B6E5A);

ThemeData podwozkaTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(seedColor: podwozkaSeedColor, brightness: brightness);
  return ThemeData(
    colorScheme: colorScheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
    ),
    inputDecorationTheme: const InputDecorationThemeData(border: OutlineInputBorder()),
  );
}
