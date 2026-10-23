import 'package:dio/dio.dart';

import '../auth/auth_service.dart';
import '../config/app_config.dart';

/// Set `extra: {skipAuth: true}` on requests that must not carry a token (e.g. GET /config).
const skipAuthKey = 'skipAuth';
const _retriedKey = 'authRetried';

/// Dio configured for the Podwózka API: base URL, timeouts and Bearer token handling.
/// Pass it to the generated client: `PodwozkaApi(dio: dio)`.
Dio createApiDio(AppConfig config, AuthService auth) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: const {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(auth, dio));
  return dio;
}

/// Adds `Authorization: Bearer <token>`; on 401 refreshes the token once and retries.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._auth, this._dio);

  final AuthService _auth;
  final Dio _dio;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.extra[skipAuthKey] == true) {
      handler.next(options);
      return;
    }
    try {
      final token = await _auth.validAccessToken();
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } on SessionExpiredException catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isUnauthorized = err.response?.statusCode == 401;
    if (!isUnauthorized || options.extra[skipAuthKey] == true || options.extra[_retriedKey] == true) {
      handler.next(err);
      return;
    }
    try {
      final token = await _auth.validAccessToken(forceRefresh: true);
      options.headers['Authorization'] = 'Bearer $token';
      options.extra[_retriedKey] = true;
      handler.resolve(await _dio.fetch<Object?>(options));
    } on SessionExpiredException {
      handler.next(err);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
