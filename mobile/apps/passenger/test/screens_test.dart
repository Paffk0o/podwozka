import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_passenger/data/passenger_repository.dart';
import 'package:podwozka_passenger/features/ordering/providers/order_controller.dart';
import 'package:podwozka_passenger/home_screen.dart';

import 'fakes.dart';

final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

class _OfflineTiles extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) => MemoryImage(_png);
}

Future<ProviderContainer> pumpHome(WidgetTester tester, FakePassengerRepository repo) async {
  // Phone-sized screen (like the emulator), so the whole bottom panel is laid out.
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  final socket = PodwozkaSocket(
    url: Uri.parse('ws://test/ws'),
    tokenProvider: ({bool forceRefresh = false}) async => 'token',
    connect: (_) => FakeTransport(),
  ); // not started: no network in widget tests
  addTearDown(socket.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        passengerRepositoryProvider.overrideWithValue(repo),
        locationServiceProvider.overrideWithValue(FakeLocationService()),
        podwozkaSocketProvider.overrideWithValue(socket),
        mapTilesProvider.overrideWithValue(
          MapTilesConfig(
            urlTemplate: 'https://t/{z}/{x}/{y}.png',
            userAgentPackageName: 'test',
            tileProvider: _OfflineTiles(),
          ),
        ),
      ],
      child: const MaterialApp(
        locale: podwozkaLocale,
        supportedLocales: podwozkaSupportedLocales,
        localizationsDelegates: podwozkaLocalizationsDelegates,
        home: HomeScreen(),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.pump(const Duration(milliseconds: 300));
  return ProviderScope.containerOf(tester.element(find.byType(HomeScreen)));
}

void main() {
  setUpAll(initPodwozkaFormatting);

  testWidgets('no ride: ordering with quote, cash selected, card/BLIK „wkrótce”', (tester) async {
    final repo = FakePassengerRepository();
    final container = await pumpHome(tester, repo);

    expect(find.text('Dokąd jedziesz?'), findsOneWidget);
    // My position was used as the pickup.
    expect(find.textContaining('Ulica przy'), findsOneWidget);
    expect(find.text('Zamów przejazd'), findsNothing);

    container.read(orderControllerProvider.notifier).setDestination(krakow);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('66,93 zł'), findsOneWidget);
    expect(find.textContaining('Gmina Wieliczka'), findsOneWidget);
    expect(find.text('Zamów przejazd'), findsOneWidget);
    final card = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Karta — wkrótce'));
    final blik = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'BLIK — wkrótce'));
    final cash = tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Gotówka'));
    expect(card.onSelected, isNull);
    expect(blik.onSelected, isNull);
    expect(cash.selected, isTrue);

    await tester.tap(find.text('Zamów przejazd'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(repo.orders, ['q1/cash']);
    expect(find.text('Szukamy kierowcy…'), findsOneWidget);
    expect(find.text('Anuluj przejazd'), findsOneWidget);
  });

  testWidgets('after a restart the ongoing ride is shown with the driver and ETA', (tester) async {
    final repo = FakePassengerRepository()
      ..active = [aRide(status: RideStatus.driverArriving, driver: jan)];

    await pumpHome(tester, repo);

    expect(find.text('Kierowca jedzie po Ciebie'), findsOneWidget);
    expect(find.text('Jan Kierowca'), findsOneWidget);
    expect(find.text('KWI12345'), findsOneWidget);
    expect(find.byTooltip('Zadzwoń do kierowcy'), findsOneWidget);
    expect(find.text('Anuluj przejazd'), findsOneWidget);
  });

  testWidgets('cancelling asks for a reason first', (tester) async {
    final repo = FakePassengerRepository()
      ..active = [aRide(status: RideStatus.accepted, driver: jan)];
    await pumpHome(tester, repo);

    await tester.tap(find.text('Anuluj przejazd'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nie anuluj'));
    await tester.pumpAndSettle();
    expect(repo.cancels, isEmpty);

    await tester.tap(find.text('Anuluj przejazd'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zmiana planów'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(repo.cancels, [('r1', 'Zmiana planów')]);
    expect(find.text('Kurs anulowany'), findsOneWidget);
    expect(find.text('Zamów ponownie'), findsOneWidget);
  });

  testWidgets('a ride in progress cannot be cancelled', (tester) async {
    final repo = FakePassengerRepository()
      ..active = [aRide(status: RideStatus.inProgress, driver: jan)];
    await pumpHome(tester, repo);

    expect(find.text('Jesteś w drodze'), findsOneWidget);
    expect(find.text('Anuluj przejazd'), findsNothing);
  });
}
