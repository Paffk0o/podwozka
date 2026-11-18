import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_core/podwozka_core.dart';

DioException _response(int status, [Object? data]) {
  final options = RequestOptions(path: '/rides');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  setUpAll(initPodwozkaFormatting);

  group('formatMoney', () {
    test('grosze → złote with a Polish comma and non-breaking space', () {
      expect(formatMoney(6696), '66,96 zł');
      expect(formatMoney(500), '5,00 zł');
      expect(formatMoney(0), '0,00 zł');
      expect(formatMoney(123456), '1 234,56 zł');
    });
  });

  test('formatDistance', () {
    expect(formatDistance(850), '850 m');
    expect(formatDistance(12400), '12,4 km');
    expect(formatDistance(3000), '3 km');
  });

  test('formatDuration rounds up to whole minutes', () {
    expect(formatDuration(0), '1 min');
    expect(formatDuration(45), '1 min');
    expect(formatDuration(720), '12 min');
    expect(formatDuration(3600), '1 godz.');
    expect(formatDuration(3900), '1 godz. 5 min');
  });

  test('formatDateTime uses Polish format in local time', () {
    final local = DateTime(2026, 11, 18, 8, 5);
    expect(formatDateTime(local), '18.11.2026, 08:05');
    expect(formatTime(local), '08:05');
  });

  group('apiErrorMessage', () {
    test('shows the Polish business message from the backend', () {
      expect(
        apiErrorMessage(_response(409, {'detail': 'Rezerwację wziął już inny kierowca'})),
        'Rezerwację wziął już inny kierowca',
      );
      expect(
        apiErrorMessage(_response(422, {'detail': 'Wycena wygasła — poproś o nową'})),
        'Wycena wygasła — poproś o nową',
      );
    });

    test('hides English details and validation lists behind Polish texts', () {
      expect(apiErrorMessage(_response(404, {'detail': 'Ride not found'})), 'Nie znaleziono.');
      expect(
        apiErrorMessage(
          _response(422, {
            'detail': [
              {
                'loc': ['body', 'phone'],
                'msg': 'String should match pattern',
              },
            ],
          }),
        ),
        'Sprawdź wprowadzone dane.',
      );
      expect(apiErrorMessage(_response(503)), 'Problem po stronie serwera. Spróbuj za chwilę.');
      expect(
        apiErrorMessage(_response(501, {'detail': 'Not implemented'})),
        'Ta funkcja będzie dostępna wkrótce.',
      );
    });

    test('network problems and expired sessions', () {
      final options = RequestOptions(path: '/me');
      expect(
        apiErrorMessage(
          DioException(requestOptions: options, type: DioExceptionType.connectionError),
        ),
        'Brak połączenia z internetem.',
      );
      expect(
        apiErrorMessage(
          DioException(requestOptions: options, type: DioExceptionType.receiveTimeout),
        ),
        startsWith('Serwer nie odpowiada'),
      );
      expect(
        apiErrorMessage(
          DioException(requestOptions: options, error: const SessionExpiredException()),
        ),
        'Sesja wygasła. Zaloguj się ponownie.',
      );
      expect(apiErrorMessage(StateError('x')), 'Coś poszło nie tak. Spróbuj ponownie.');
    });

    test('apiErrorStatus', () {
      expect(apiErrorStatus(_response(404)), 404);
      expect(apiErrorStatus(Exception()), isNull);
    });
  });

  group('profile validation', () {
    test('normalizes Polish numbers to E.164', () {
      expect(normalizePhone('600 100 200'), '+48600100200');
      expect(normalizePhone('600-100-200'), '+48600100200');
      expect(normalizePhone('+48 600 100 200'), '+48600100200');
      expect(normalizePhone('48600100200'), '+48600100200');
      expect(normalizePhone('0048600100200'), '+48600100200');
      expect(normalizePhone('+420 601 234 567'), '+420601234567');
    });

    test('rejects invalid numbers', () {
      expect(normalizePhone(''), isNull);
      expect(normalizePhone('12345'), isNull);
      expect(normalizePhone('+48 600 100 20'), isNull);
      expect(normalizePhone('abc'), isNull);
      expect(validatePhone('600100200'), isNull);
      expect(validatePhone('600'), contains('poprawny'));
    });

    test('name is required', () {
      expect(validateFullName(' '), 'Podaj imię i nazwisko.');
      expect(validateFullName('Al'), isNotNull);
      expect(validateFullName('Anna Nowak'), isNull);
    });
  });
}
