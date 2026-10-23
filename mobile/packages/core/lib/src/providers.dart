import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_dio.dart';
import 'auth/auth_controller.dart';
import 'auth/auth_service.dart';
import 'auth/auth_tokens.dart';
import 'auth/token_storage.dart';
import 'config/app_config.dart';

/// Must be overridden in each app's `main()`:
/// `ProviderScope(overrides: [appConfigProvider.overrideWithValue(AppConfig.passenger())])`.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('Override appConfigProvider in main()'),
);

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

final oidcClientProvider = Provider<OidcClient>(
  (ref) => AppAuthOidcClient(ref.watch(appConfigProvider)),
);

final authServiceProvider = Provider<AuthService>((ref) {
  final service = AuthService(
    oidc: ref.watch(oidcClientProvider),
    storage: ref.watch(tokenStorageProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthTokens?>(
  AuthController.new,
);

/// Dio with base URL and Bearer token. Use with the generated client: `PodwozkaApi(dio: ...)`.
final dioProvider = Provider<Dio>((ref) {
  final dio = createApiDio(ref.watch(appConfigProvider), ref.watch(authServiceProvider));
  ref.onDispose(dio.close);
  return dio;
});
