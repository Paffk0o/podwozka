import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_core/podwozka_core.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPodwozkaFormatting();
  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(AppConfig.passenger())],
      child: const PassengerApp(),
    ),
  );
}
