import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_core/podwozka_core.dart';

String fakeJwt(Map<String, Object?> claims) {
  String part(Map<String, Object?> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'RS256'})}.${part(claims)}.signature';
}

AuthTokens tokens(String name, DateTime expiry, {String? refresh = 'refresh-1'}) => AuthTokens(
  accessToken: fakeJwt({
    'sub': 'user-1',
    'name': name,
    'realm_access': {
      'roles': ['passenger', 'driver'],
    },
  }),
  accessTokenExpiry: expiry,
  refreshToken: refresh,
  idToken: 'id-token',
);

class FakeOidcClient implements OidcClient {
  FakeOidcClient(this.now);

  final DateTime now;
  int loginCalls = 0;
  int refreshCalls = 0;
  int endSessionCalls = 0;
  Object? refreshError;
  Completer<void>? refreshGate;

  @override
  Future<AuthTokens> login() async {
    loginCalls++;
    return tokens('login', now.add(const Duration(minutes: 5)));
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    refreshCalls++;
    await refreshGate?.future;
    final error = refreshError;
    if (error != null) throw error;
    return tokens('refreshed', now.add(const Duration(minutes: 5)), refresh: 'refresh-2');
  }

  @override
  Future<void> endSession(String? idToken) async {
    endSessionCalls++;
  }
}

void main() {
  final now = DateTime.utc(2026, 10, 24, 12);
  late FakeOidcClient oidc;
  late InMemoryTokenStorage storage;
  late AuthService service;

  setUp(() {
    oidc = FakeOidcClient(now);
    storage = InMemoryTokenStorage();
    service = AuthService(oidc: oidc, storage: storage, clock: () => now);
  });

  tearDown(() => service.dispose());

  test('login persists tokens and exposes roles from the access token', () async {
    final result = await service.login();

    expect(result.roles, {'passenger', 'driver'});
    expect(result.subject, 'user-1');
    expect(await storage.read(), isNotNull);
  });

  test('returns the stored token without refreshing while it is still valid', () async {
    await storage.write(tokens('stored', now.add(const Duration(minutes: 4))));

    final token = await service.validAccessToken();

    expect(decodeJwtPayload(token)['name'], 'stored');
    expect(oidc.refreshCalls, 0);
  });

  test('refreshes a token that expires within 30 seconds', () async {
    await storage.write(tokens('old', now.add(const Duration(seconds: 10))));

    final token = await service.validAccessToken();

    expect(decodeJwtPayload(token)['name'], 'refreshed');
    expect((await storage.read())!.refreshToken, 'refresh-2');
  });

  test('parallel callers share a single refresh request', () async {
    await storage.write(tokens('old', now.subtract(const Duration(minutes: 1))));
    oidc.refreshGate = Completer<void>();

    final futures = [service.validAccessToken(), service.validAccessToken()];
    oidc.refreshGate!.complete();
    final results = await Future.wait(futures);

    expect(oidc.refreshCalls, 1);
    expect(results.toSet(), hasLength(1));
  });

  test('expired session clears tokens and emits sign-out', () async {
    await storage.write(tokens('old', now.subtract(const Duration(minutes: 1))));
    oidc.refreshError = const SessionExpiredException();
    final emitted = <AuthTokens?>[];
    final sub = service.changes.listen(emitted.add);

    await expectLater(service.validAccessToken(), throwsA(isA<SessionExpiredException>()));
    await Future<void>.delayed(Duration.zero);

    expect(await storage.read(), isNull);
    expect(emitted, [null]);
    await sub.cancel();
  });

  test('network error during refresh does NOT log the user out', () async {
    await storage.write(tokens('old', now.subtract(const Duration(minutes: 1))));
    oidc.refreshError = Exception('offline');

    await expectLater(service.validAccessToken(), throwsA(isA<Exception>()));

    expect(await storage.read(), isNotNull);
  });

  test('logout clears local tokens and ends the Keycloak session', () async {
    await service.login();

    await service.logout();

    expect(await storage.read(), isNull);
    expect(oidc.endSessionCalls, 1);
    await expectLater(service.validAccessToken(), throwsA(isA<SessionExpiredException>()));
  });

  test('decodeJwtPayload tolerates garbage', () {
    expect(decodeJwtPayload('not-a-jwt'), isEmpty);
    expect(decodeJwtPayload('a.b.c'), isEmpty);
  });
}
