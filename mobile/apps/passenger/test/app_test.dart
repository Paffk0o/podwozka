import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_passenger/app.dart';
import 'package:podwozka_core/podwozka_core.dart';

class _NoopOidc implements OidcClient {
  @override
  Future<AuthTokens> login() => throw const LoginCancelledException();

  @override
  Future<AuthTokens> refresh(String refreshToken) => throw const SessionExpiredException();

  @override
  Future<void> endSession(String? idToken) async {}
}

void main() {
  testWidgets('signed-out user sees the login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.passenger()),
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
          oidcClientProvider.overrideWithValue(_NoopOidc()),
        ],
        child: const PassengerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Zaloguj się lub załóż konto'), findsOneWidget);
  });

  testWidgets('cancelling the Keycloak page keeps the user on the login screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig.passenger()),
          tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
          oidcClientProvider.overrideWithValue(_NoopOidc()),
        ],
        child: const PassengerApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zaloguj się lub załóż konto'));
    await tester.pumpAndSettle();

    expect(find.text('Zaloguj się lub załóż konto'), findsOneWidget);
  });
}
