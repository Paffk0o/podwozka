import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

/// Polish only (UI texts, date picker, `pl_PL` formats).
const podwozkaLocale = Locale('pl', 'PL');
const podwozkaSupportedLocales = [podwozkaLocale];
const podwozkaLocalizationsDelegates = <LocalizationsDelegate<Object?>>[
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
