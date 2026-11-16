import 'dart:async';

import 'package:flutter_appauth/flutter_appauth.dart';

import '../config/app_config.dart';
import 'auth_tokens.dart';
import 'token_storage.dart';

/// Thrown when the user closed the login page without signing in.
class LoginCancelledException implements Exception {
  const LoginCancelledException();
}

/// Thrown when the session can no longer be refreshed (user must log in again).
class SessionExpiredException implements Exception {
  const SessionExpiredException();
}

/// Talks to the OIDC provider (Keycloak). Abstract so tests and Flutter Web
/// (admin panel) can provide their own implementation.
abstract interface class OidcClient {
  Future<AuthTokens> login();
  Future<AuthTokens> refresh(String refreshToken);
  Future<void> endSession(String? idToken);
}

/// Mobile implementation (Android/iOS) using AppAuth — system browser + PKCE.
class AppAuthOidcClient implements OidcClient {
  AppAuthOidcClient(this._config, {FlutterAppAuth? appAuth})
    : _appAuth = appAuth ?? const FlutterAppAuth();

  final AppConfig _config;
  final FlutterAppAuth _appAuth;

  @override
  Future<AuthTokens> login() async {
    try {
      final response = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _config.clientId,
          _config.redirectUrl,
          issuer: _config.oidcIssuer,
          scopes: _config.scopes,
          allowInsecureConnections: _config.allowInsecureHttp,
          additionalParameters: const {'ui_locales': 'pl'},
        ),
      );
      return _toTokens(response);
    } on FlutterAppAuthUserCancelledException {
      throw const LoginCancelledException();
    }
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    try {
      final response = await _appAuth.token(
        TokenRequest(
          _config.clientId,
          _config.redirectUrl,
          issuer: _config.oidcIssuer,
          refreshToken: refreshToken,
          scopes: _config.scopes,
          allowInsecureConnections: _config.allowInsecureHttp,
        ),
      );
      return _toTokens(response);
    } on FlutterAppAuthPlatformException catch (e) {
      // invalid_grant = refresh token expired or revoked (logout elsewhere, password change).
      // Other errors (e.g. no network) are rethrown so the user is NOT logged out offline.
      if (e.platformErrorDetails.error == 'invalid_grant') {
        throw const SessionExpiredException();
      }
      rethrow;
    }
  }

  @override
  Future<void> endSession(String? idToken) async {
    if (idToken == null) return;
    await _appAuth.endSession(
      EndSessionRequest(
        idTokenHint: idToken,
        postLogoutRedirectUrl: _config.postLogoutRedirectUrl,
        issuer: _config.oidcIssuer,
        allowInsecureConnections: _config.allowInsecureHttp,
      ),
    );
  }

  AuthTokens _toTokens(TokenResponse response) {
    final accessToken = response.accessToken;
    if (accessToken == null) {
      throw StateError('Keycloak returned no access token');
    }
    return AuthTokens(
      accessToken: accessToken,
      accessTokenExpiry:
          response.accessTokenExpirationDateTime ?? DateTime.now().add(const Duration(minutes: 5)),
      refreshToken: response.refreshToken,
      idToken: response.idToken,
    );
  }
}

/// Owns the session: login, logout, and a valid access token on demand.
class AuthService {
  AuthService({required OidcClient oidc, required TokenStorage storage, DateTime Function()? clock})
    : _oidc = oidc,
      _storage = storage,
      _clock = clock ?? DateTime.now;

  final OidcClient _oidc;
  final TokenStorage _storage;
  final DateTime Function() _clock;

  AuthTokens? _tokens;
  bool _loaded = false;
  Future<AuthTokens>? _refreshInFlight;

  final _changes = StreamController<AuthTokens?>.broadcast();

  /// Emits new tokens after login/refresh and `null` after logout / expired session.
  Stream<AuthTokens?> get changes => _changes.stream;

  Future<AuthTokens?> currentTokens() async {
    if (!_loaded) {
      _tokens = await _storage.read();
      _loaded = true;
    }
    return _tokens;
  }

  Future<AuthTokens> login() async {
    final tokens = await _oidc.login();
    await _save(tokens);
    return tokens;
  }

  /// Returns a non-expired access token, refreshing it if needed.
  /// Concurrent callers share one refresh request (Keycloak rotates refresh tokens,
  /// so two parallel refreshes would invalidate each other).
  /// Throws [SessionExpiredException] if the user has to log in again.
  Future<String> validAccessToken({bool forceRefresh = false}) async {
    final tokens = await currentTokens();
    if (tokens == null) throw const SessionExpiredException();
    if (!forceRefresh && !tokens.isExpiringSoon(now: _clock())) {
      return tokens.accessToken;
    }
    final refreshed = await (_refreshInFlight ??= _refresh(tokens).whenComplete(() {
      _refreshInFlight = null;
    }));
    return refreshed.accessToken;
  }

  Future<AuthTokens> _refresh(AuthTokens tokens) async {
    final refreshToken = tokens.refreshToken;
    if (refreshToken == null) {
      await _expire();
      throw const SessionExpiredException();
    }
    try {
      final refreshed = await _oidc.refresh(refreshToken);
      await _save(refreshed);
      return refreshed;
    } on SessionExpiredException {
      await _expire();
      rethrow;
    }
  }

  Future<void> logout() async {
    final idToken = _tokens?.idToken;
    await _expire();
    try {
      await _oidc.endSession(idToken);
    } on Object {
      // Local logout already happened; ending the Keycloak SSO session is best-effort.
    }
  }

  Future<void> _save(AuthTokens tokens) async {
    _tokens = tokens;
    _loaded = true;
    await _storage.write(tokens);
    _changes.add(tokens);
  }

  Future<void> _expire() async {
    _tokens = null;
    _loaded = true;
    await _storage.clear();
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();
}
