import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'auth_service.dart';
import 'auth_tokens.dart';

/// Session state for the UI: `AsyncData(null)` = signed out, `AsyncData(tokens)` = signed in.
class AuthController extends AsyncNotifier<AuthTokens?> {
  @override
  Future<AuthTokens?> build() async {
    final service = ref.watch(authServiceProvider);
    final subscription = service.changes.listen((tokens) => state = AsyncData(tokens));
    ref.onDispose(subscription.cancel);
    return service.currentTokens();
  }

  Future<void> login() async {
    final service = ref.read(authServiceProvider);
    state = const AsyncLoading();
    try {
      state = AsyncData(await service.login());
    } on LoginCancelledException {
      state = const AsyncData(null);
    } on Object catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> logout() => ref.read(authServiceProvider).logout();
}
