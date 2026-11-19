import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_driver/features/onboarding/data/onboarding_repository.dart';
import 'package:podwozka_driver/features/work/data/location_publisher.dart';
import 'package:podwozka_driver/features/work/data/work_repository.dart';
import 'package:podwozka_driver/home_screen.dart';

import 'onboarding_test.dart' show FakeOnboardingRepository, profile;
import 'work_fakes.dart' hide profile;

/// Unsigned token with the given realm roles (the app only reads claims for UI decisions).
String jwt(List<String> roles) {
  String part(Map<String, Object?> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  final claims = {
    'sub': 'd1',
    'realm_access': {'roles': roles},
  };
  return '${part({'alg': 'RS256'})}.${part(claims)}.sig';
}

class _NoopOidc implements OidcClient {
  @override
  Future<AuthTokens> login() => throw const LoginCancelledException();

  @override
  Future<AuthTokens> refresh(String refreshToken) => throw const SessionExpiredException();

  @override
  Future<void> endSession(String? idToken) async {}
}

Future<void> pumpHome(
  WidgetTester tester, {
  required List<String> roles,
  required DriverStatus status,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  final storage = InMemoryTokenStorage();
  await storage.write(AuthTokens(accessToken: jwt(roles), accessTokenExpiry: DateTime.utc(2030)));
  final ws = SocketHarness(); // not started — no network in widget tests
  addTearDown(ws.socket.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig.driver()),
        tokenStorageProvider.overrideWithValue(storage),
        oidcClientProvider.overrideWithValue(_NoopOidc()),
        onboardingRepositoryProvider.overrideWithValue(
          FakeOnboardingRepository()..current = profile(status: status),
        ),
        workRepositoryProvider.overrideWithValue(FakeWorkRepository()),
        locationServiceProvider.overrideWithValue(FakeLocation()),
        notificationPermissionProvider.overrideWithValue(FakeNotificationPermission()),
        podwozkaSocketProvider.overrideWithValue(ws.socket),
        mapTilesProvider.overrideWithValue(
          const MapTilesConfig(urlTemplate: 'about:blank', userAgentPackageName: 'test'),
        ),
      ],
      child: MaterialApp(theme: podwozkaTheme(Brightness.light), home: const HomeScreen()),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(initPodwozkaFormatting);

  testWidgets('approved driver with the driver role → work mode with tabs', (tester) async {
    await pumpHome(tester, roles: ['passenger', 'driver'], status: DriverStatus.approved);

    expect(find.text('Jesteś offline'), findsOneWidget);
    expect(find.text('Giełda'), findsOneWidget);
    expect(find.text('Zarobki'), findsOneWidget);
  });

  testWidgets('approved in the API, token without the role yet → still the application', (
    tester,
  ) async {
    await pumpHome(tester, roles: ['passenger'], status: DriverStatus.approved);

    expect(find.text('Wniosek kierowcy'), findsOneWidget);
    expect(find.text('Sprawdź status'), findsOneWidget);
  });

  testWidgets('suspended driver cannot work even with the role in an old token', (tester) async {
    await pumpHome(tester, roles: ['driver'], status: DriverStatus.suspended);

    expect(find.text('Konto zawieszone'), findsOneWidget);
    expect(find.text('Jesteś offline'), findsNothing);
  });
}
