import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Minimal model of `GET /me`.
///
/// TODO(agent-mobile): after running ./scripts/gen-api-client.sh replace this file with the
/// generated `MeApi` + `Me` model from `podwozka_api` (dzień 2, pierwsze zadanie).
class Profile {
  const Profile({
    required this.id,
    required this.roles,
    this.email,
    this.fullName,
    this.phone,
    this.phoneVerified = false,
  });

  factory Profile.fromJson(Map<String, Object?> json) => Profile(
    id: json['id']! as String,
    email: json['email'] as String?,
    fullName: json['full_name'] as String?,
    phone: json['phone'] as String?,
    phoneVerified: json['phone_verified'] as bool? ?? false,
    roles: (json['roles'] as List<Object?>? ?? const []).whereType<String>().toList(),
  );

  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final bool phoneVerified;
  final List<String> roles;
}

/// Loads my profile; creates it (`PUT /me`) on the first login.
final myProfileProvider = FutureProvider<Profile>((ref) async {
  // Re-fetch after login/logout.
  ref.watch(authControllerProvider.select((auth) => auth.value?.subject));
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get<Map<String, Object?>>('/me');
    return Profile.fromJson(response.data!);
  } on DioException catch (e) {
    if (e.response?.statusCode != 404) rethrow;
    final created = await dio.put<Map<String, Object?>>('/me', data: const <String, Object?>{});
    return Profile.fromJson(created.data!);
  }
});
