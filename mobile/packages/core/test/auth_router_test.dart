import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_core/podwozka_core.dart';

void main() {
  final tokens = AuthTokens(accessToken: 'a.b.c', accessTokenExpiry: DateTime.utc(2030));

  String? redirect(AsyncValue<AuthTokens?> auth, String location) =>
      authRedirect(auth: auth, location: location, homePath: '/home');

  test('waits on the splash while the session is being restored', () {
    expect(redirect(const AsyncLoading(), '/home'), AuthRoutes.splash);
  });

  test('signed-out users always land on the login screen', () {
    expect(redirect(const AsyncData(null), '/'), AuthRoutes.login);
    expect(redirect(const AsyncData(null), '/home'), AuthRoutes.login);
    expect(redirect(const AsyncData(null), AuthRoutes.login), isNull);
  });

  test('a failed login shows the login screen (with the error)', () {
    expect(redirect(AsyncError(Exception('x'), StackTrace.empty), '/'), AuthRoutes.login);
  });

  test('signed-in users skip login and splash', () {
    expect(redirect(AsyncData(tokens), AuthRoutes.login), '/home');
    expect(redirect(AsyncData(tokens), AuthRoutes.splash), '/home');
    expect(redirect(AsyncData(tokens), '/home/rides'), isNull);
  });
}
