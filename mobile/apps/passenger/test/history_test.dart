import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_passenger/data/passenger_repository.dart';
import 'package:podwozka_passenger/features/history/history_screens.dart';

import 'fakes.dart';

/// 45 finished rides, served page by page like the API.
class PagedRepository extends FakePassengerRepository {
  final all = [for (var i = 0; i < 45; i++) aRide(id: 'r$i', status: RideStatus.completed)];
  final offsets = <int>[];

  @override
  Future<RidePage> history({int offset = 0, int limit = 20}) async {
    offsets.add(offset);
    return RidePage(
      items: all.skip(offset).take(limit).toList(),
      total: all.length,
      limit: limit,
      offset: offset,
    );
  }
}

Future<void> pumpDetails(WidgetTester tester, FakePassengerRepository repo, String rideId) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        passengerRepositoryProvider.overrideWithValue(repo),
        mapTilesProvider.overrideWithValue(
          const MapTilesConfig(urlTemplate: 'about:blank', userAgentPackageName: 'test'),
        ),
      ],
      child: MaterialApp(
        theme: podwozkaTheme(Brightness.light),
        home: RideDetailsScreen(rideId: rideId),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(initPodwozkaFormatting);

  test('history loads page by page and stops at the total', () async {
    final repo = PagedRepository();
    final container = ProviderContainer(
      overrides: [passengerRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.listen(historyProvider, (_, _) {});

    expect((await container.read(historyProvider.future)).items, hasLength(20));
    await container.read(historyProvider.notifier).loadMore();
    await container.read(historyProvider.notifier).loadMore();
    final state = container.read(historyProvider).requireValue;
    expect(state.items, hasLength(45));
    expect(state.hasMore, isFalse);

    await container.read(historyProvider.notifier).loadMore();
    expect(repo.offsets, [0, 20, 40]);
  });

  testWidgets('a reservation can be cancelled from its details, with a reason', (tester) async {
    final repo = FakePassengerRepository()
      ..rides['res'] = aRide(
        id: 'res',
        status: RideStatus.scheduled,
        scheduledAt: DateTime(2026, 11, 20, 8, 30),
      );
    await pumpDetails(tester, repo, 'res');

    expect(find.text('Rezerwacja'), findsOneWidget);
    expect(find.text('Odbiór: 20.11.2026, 08:30'), findsOneWidget);

    await tester.tap(find.text('Anuluj rezerwację'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zmiana planów'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(repo.cancels, [('res', 'Zmiana planów')]);
  });

  testWidgets('a finished ride cannot be cancelled', (tester) async {
    final repo = FakePassengerRepository()
      ..rides['done'] = aRide(id: 'done', status: RideStatus.completed);
    await pumpDetails(tester, repo, 'done');

    expect(find.text('Zakończony'), findsOneWidget);
    expect(find.textContaining('Anuluj'), findsNothing);
  });
}
