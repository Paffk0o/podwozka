import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';

import '../providers.dart';

/// Generated API client on top of [dioProvider] (base URL + Bearer token from `AuthInterceptor`).
/// `interceptors: []` skips the generator's own auth interceptors — ours already set the header.
final podwozkaApiProvider = Provider<PodwozkaApi>(
  (ref) => PodwozkaApi(dio: ref.watch(dioProvider), interceptors: const []),
);

/// My profile (`GET /me`); created with `PUT /me` on the first login.
final meProvider = AsyncNotifierProvider<MeController, Me>(MeController.new);

class MeController extends AsyncNotifier<Me> {
  @override
  Future<Me> build() async {
    // Re-fetch after login/logout.
    ref.watch(authControllerProvider.select((auth) => auth.value?.subject));
    final api = ref.watch(podwozkaApiProvider).getMeApi();
    try {
      return (await api.getMe()).data!;
    } on DioException catch (e) {
      if (e.response?.statusCode != 404) rethrow;
      return (await api.upsertMe(meUpsert: MeUpsert())).data!;
    }
  }

  /// Saves name/phone (profile completion screen) and updates the cached profile.
  Future<void> save({required String fullName, required String phone}) async {
    final api = ref.read(podwozkaApiProvider).getMeApi();
    final updated = await api.upsertMe(
      meUpsert: MeUpsert(fullName: fullName, phone: phone),
    );
    state = AsyncData(updated.data!);
  }
}
