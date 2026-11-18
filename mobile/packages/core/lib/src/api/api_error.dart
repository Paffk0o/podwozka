import 'package:dio/dio.dart';

import '../auth/auth_service.dart';

/// Turns any error from the API layer into a short Polish message for the UI.
///
/// Business errors (400/409/410/422 with a string `detail`) from the backend are in Polish
/// (e.g. „Rezerwację wziął już inny kierowca”) — those are shown as is.
/// Everything else is mapped by status code, so English internals never reach the user.
String apiErrorMessage(Object error) {
  if (error is SessionExpiredException) {
    return 'Sesja wygasła. Zaloguj się ponownie.';
  }
  if (error is! DioException) {
    return 'Coś poszło nie tak. Spróbuj ponownie.';
  }
  if (error.error is SessionExpiredException) {
    return 'Sesja wygasła. Zaloguj się ponownie.';
  }
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return 'Serwer nie odpowiada. Sprawdź połączenie i spróbuj ponownie.';
    case DioExceptionType.connectionError:
      return 'Brak połączenia z internetem.';
    case DioExceptionType.cancel:
      return 'Anulowano.';
    case DioExceptionType.badCertificate:
      return 'Nie udało się bezpiecznie połączyć z serwerem.';
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      break;
  }
  final response = error.response;
  if (response == null) return 'Brak połączenia z internetem.';
  final status = response.statusCode ?? 0;
  final detail = _detail(response.data);
  return switch (status) {
    400 || 409 || 410 || 422 when detail != null => detail,
    400 => 'Nieprawidłowe dane.',
    401 => 'Sesja wygasła. Zaloguj się ponownie.',
    403 => 'Nie masz uprawnień do tej operacji.',
    404 => 'Nie znaleziono.',
    409 => 'Operacja jest teraz niemożliwa — odśwież i spróbuj ponownie.',
    422 => 'Sprawdź wprowadzone dane.',
    429 => 'Za dużo prób. Odczekaj chwilę.',
    501 => 'Ta funkcja będzie dostępna wkrótce.',
    >= 500 => 'Problem po stronie serwera. Spróbuj za chwilę.',
    _ => 'Coś poszło nie tak. Spróbuj ponownie.',
  };
}

/// HTTP status of an API error, if any (for logic like "404 → no active ride").
int? apiErrorStatus(Object error) => error is DioException ? error.response?.statusCode : null;

String? _detail(Object? data) {
  if (data is Map && data['detail'] is String) {
    final text = (data['detail'] as String).trim();
    return text.isEmpty ? null : text;
  }
  return null;
}
