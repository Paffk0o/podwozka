/// Runtime configuration of an app. Values come from `--dart-define` so the same build
/// can point at local, staging or production backends:
///
/// ```
/// flutter run --dart-define=API_BASE_URL=https://api.staging.example \
///             --dart-define=OIDC_ISSUER=https://auth.staging.example/realms/podwozka
/// ```
///
/// Defaults target the local `docker compose` setup. On an Android emulator/device run
/// `adb reverse tcp:8000 tcp:8000 && adb reverse tcp:8080 tcp:8080` first, so that
/// `localhost` inside the phone reaches your computer.
class AppConfig {
  const AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.oidcIssuer,
    required this.clientId,
    required this.redirectScheme,
    this.allowInsecureHttp = false,
  });

  /// Local defaults for the passenger app.
  factory AppConfig.passenger() => const AppConfig(
    appName: 'Podwózka',
    apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: _localApi),
    oidcIssuer: String.fromEnvironment('OIDC_ISSUER', defaultValue: _localIssuer),
    clientId: 'passenger-app',
    redirectScheme: 'pl.podwozka.passenger',
    allowInsecureHttp: bool.fromEnvironment('ALLOW_INSECURE_HTTP', defaultValue: true),
  );

  /// Local defaults for the driver app.
  factory AppConfig.driver() => const AppConfig(
    appName: 'Podwózka Kierowca',
    apiBaseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: _localApi),
    oidcIssuer: String.fromEnvironment('OIDC_ISSUER', defaultValue: _localIssuer),
    clientId: 'driver-app',
    redirectScheme: 'pl.podwozka.driver',
    allowInsecureHttp: bool.fromEnvironment('ALLOW_INSECURE_HTTP', defaultValue: true),
  );

  static const _localApi = 'http://localhost:8000';
  static const _localIssuer = 'http://localhost:8080/realms/podwozka';

  final String appName;
  final String apiBaseUrl;
  final String oidcIssuer;

  /// Keycloak client id (`passenger-app`, `driver-app`, `admin-panel`).
  final String clientId;

  /// Custom URL scheme registered in AndroidManifest (appAuthRedirectScheme) and Info.plist.
  final String redirectScheme;

  /// Only for local development against http://localhost (Android AppAuth refuses http otherwise).
  final bool allowInsecureHttp;

  String get redirectUrl => '$redirectScheme:/oauthredirect';
  String get postLogoutRedirectUrl => '$redirectScheme:/logout';

  /// OIDC scopes requested at login. `offline_access` is intentionally not requested:
  /// sessions are bounded by the realm's SSO session lifetime.
  List<String> get scopes => const ['openid', 'profile', 'email'];
}
