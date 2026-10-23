import 'dart:convert';

/// Tokens returned by Keycloak. Persisted in secure storage.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.accessTokenExpiry,
    this.refreshToken,
    this.idToken,
  });

  factory AuthTokens.fromJson(Map<String, Object?> json) => AuthTokens(
    accessToken: json['access_token']! as String,
    accessTokenExpiry: DateTime.parse(json['access_token_expiry']! as String),
    refreshToken: json['refresh_token'] as String?,
    idToken: json['id_token'] as String?,
  );

  final String accessToken;
  final DateTime accessTokenExpiry;
  final String? refreshToken;
  final String? idToken;

  Map<String, Object?> toJson() => {
    'access_token': accessToken,
    'access_token_expiry': accessTokenExpiry.toUtc().toIso8601String(),
    'refresh_token': refreshToken,
    'id_token': idToken,
  };

  /// True if the access token expires within [margin] (refresh before calling the API).
  bool isExpiringSoon({DateTime? now, Duration margin = const Duration(seconds: 30)}) {
    final current = (now ?? DateTime.now()).toUtc();
    return !current.add(margin).isBefore(accessTokenExpiry.toUtc());
  }

  /// Claims of the access token. For UI decisions only (e.g. which screen to show) —
  /// the backend verifies the signature and enforces permissions.
  Map<String, Object?> get claims => decodeJwtPayload(accessToken);

  String? get subject => claims['sub'] as String?;
  String? get email => claims['email'] as String?;
  String? get name => claims['name'] as String?;

  /// Realm roles from `realm_access.roles` (passenger, driver, admin, ...).
  Set<String> get roles {
    final realmAccess = claims['realm_access'];
    if (realmAccess is! Map<String, Object?>) return const {};
    final roles = realmAccess['roles'];
    if (roles is! List<Object?>) return const {};
    return roles.whereType<String>().toSet();
  }

  bool hasRole(String role) => roles.contains(role);
}

/// Decodes the payload (middle part) of a JWT without verifying the signature.
Map<String, Object?> decodeJwtPayload(String jwt) {
  final parts = jwt.split('.');
  if (parts.length != 3) return const {};
  try {
    final normalized = base64Url.normalize(parts[1]);
    final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    return decoded is Map<String, Object?> ? decoded : const {};
  } on FormatException {
    return const {};
  }
}
