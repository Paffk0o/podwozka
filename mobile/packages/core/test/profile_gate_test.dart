import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

Me _me({String? name, String? phone}) => Me(
  id: 'u1',
  email: 'anna@podwozka.test',
  fullName: name,
  phone: phone,
  phoneVerified: false,
  roles: const ['passenger'],
);

/// Replaces the API-backed profile with an in-memory one.
class FakeMeController extends MeController {
  FakeMeController(this.initial);

  final Me initial;
  final saved = <(String, String)>[];

  @override
  Future<Me> build() async => initial;

  @override
  Future<void> save({required String fullName, required String phone}) async {
    saved.add((fullName, phone));
    state = AsyncData(_me(name: fullName, phone: phone));
  }
}

Future<FakeMeController> _pump(WidgetTester tester, Me me) async {
  final fake = FakeMeController(me);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [meProvider.overrideWith(() => fake)],
      child: const MaterialApp(home: ProfileGate(child: Text('EKRAN GŁÓWNY'))),
    ),
  );
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('complete profile goes straight to the home screen', (tester) async {
    await _pump(tester, _me(name: 'Anna Nowak', phone: '+48600100200'));

    expect(find.text('EKRAN GŁÓWNY'), findsOneWidget);
    expect(find.text('Uzupełnij profil'), findsNothing);
  });

  testWidgets('first login: form validates, saves E.164 phone and opens the app', (tester) async {
    final fake = await _pump(tester, _me());
    expect(find.text('Uzupełnij profil'), findsOneWidget);

    await tester.tap(find.text('Zapisz i przejdź dalej'));
    await tester.pumpAndSettle();
    expect(find.text('Podaj imię i nazwisko.'), findsOneWidget);
    expect(find.text('Podaj numer telefonu.'), findsOneWidget);
    expect(fake.saved, isEmpty);

    await tester.enterText(find.widgetWithText(TextFormField, 'Imię i nazwisko'), ' Anna Nowak ');
    await tester.enterText(find.widgetWithText(TextFormField, 'Telefon'), '600 100 200');
    await tester.tap(find.text('Zapisz i przejdź dalej'));
    await tester.pumpAndSettle();

    expect(fake.saved, [('Anna Nowak', '+48600100200')]);
    expect(find.text('EKRAN GŁÓWNY'), findsOneWidget);
  });

  testWidgets('a stored Polish number is edited without the +48 prefix', (tester) async {
    await _pump(tester, _me(phone: '+48600100200'));

    expect(find.text('600100200'), findsOneWidget);
  });
}
