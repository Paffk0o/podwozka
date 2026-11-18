import 'package:podwozka_api/podwozka_api.dart';

/// Profile is complete when we know how to address the user and how to call them
/// (the driver phones the passenger, the passenger sees the driver's number).
bool isProfileComplete(Me me) =>
    (me.fullName?.trim().isNotEmpty ?? false) && (me.phone?.trim().isNotEmpty ?? false);

/// Returns a Polish error or null.
String? validateFullName(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Podaj imię i nazwisko.';
  if (text.length < 3) return 'Imię i nazwisko jest za krótkie.';
  if (text.length > 200) return 'Imię i nazwisko jest za długie.';
  return null;
}

/// Normalises a Polish phone number to E.164 (`+48600100200`) — the format the API accepts.
/// Accepts `600 100 200`, `600-100-200`, `48600100200`, `+48 600 100 200`, `0048…`
/// and international numbers starting with `+`. Returns null when invalid.
String? normalizePhone(String? value) {
  var text = (value ?? '').replaceAll(RegExp(r'[\s\-().]'), '');
  if (text.isEmpty) return null;
  if (text.startsWith('00')) text = '+${text.substring(2)}';
  if (!text.startsWith('+')) {
    if (RegExp(r'^\d{9}$').hasMatch(text)) {
      text = '+48$text';
    } else if (RegExp(r'^48\d{9}$').hasMatch(text)) {
      text = '+$text';
    } else {
      return null;
    }
  }
  if (text.startsWith('+48') && text.length != 12) return null;
  return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(text) ? text : null;
}

String? validatePhone(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Podaj numer telefonu.';
  return normalizePhone(value) == null ? 'Podaj poprawny numer, np. 600 100 200.' : null;
}
