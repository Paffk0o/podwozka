import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_driver/features/board/board_repository.dart';
import 'package:podwozka_driver/features/board/board_screen.dart';
import 'package:podwozka_driver/features/earnings/earnings_screen.dart';

import 'work_fakes.dart';

Ride reservation(String id, DateTime at, {RideStatus status = RideStatus.scheduled}) =>
    aRide(id: id, status: status).copyWith(scheduledAt: at);

class FakeRecords implements DriverRecordsRepository {
  List<Ride> boardRides = [];
  List<Ride> mine = [];
  int boardLoads = 0;
  final calls = <String>[];
  Object? claimError;
  ({DateTime from, DateTime to})? lastRange;

  @override
  Future<List<Ride>> board() async {
    boardLoads++;
    return boardRides;
  }

  @override
  Future<Ride> claim(String rideId) async {
    final error = claimError;
    if (error != null) throw error;
    calls.add('claim:$rideId');
    final ride = boardRides.firstWhere((r) => r.id == rideId);
    boardRides = boardRides.where((r) => r.id != rideId).toList();
    final claimed = ride.copyWith(status: RideStatus.accepted);
    mine = [...mine, claimed];
    return claimed;
  }

  @override
  Future<Ride> giveBack(String rideId, {required String reason}) async {
    calls.add('giveBack:$rideId');
    final ride = mine.firstWhere((r) => r.id == rideId);
    mine = mine.where((r) => r.id != rideId).toList();
    boardRides = [...boardRides, ride.copyWith(status: RideStatus.scheduled)];
    return ride;
  }

  @override
  Future<EarningsSummary> earnings({required DateTime from, required DateTime to}) async {
    lastRange = (from: from, to: to);
    return EarningsSummary(
      dateFrom: from,
      dateTo: to,
      ridesCount: 3,
      gross: 20088,
      commission: 2010,
      net: 18078,
      cashCollected: 20088,
      commissionDueFromCash: 2010,
      items: [
        EarningEntry(
          rideId: 'r1',
          completedAt: DateTime.utc(2026, 11, 18, 9),
          paymentMethod: PaymentMethod.cash,
          gross: 6696,
          commission: 670,
          net: 6026,
        ),
      ],
    );
  }

  @override
  Future<RidePage> rides({required bool active, int offset = 0, int limit = 20}) async => RidePage(
    items: active ? mine : const [],
    total: active ? mine.length : 0,
    limit: limit,
    offset: offset,
  );
}

void main() {
  setUpAll(initPodwozkaFormatting);

  group('earnings periods', () {
    final now = DateTime(2026, 11, 18, 21, 30);

    test('inclusive calendar days', () {
      expect(periodRange(EarningsPeriod.today, now), (
        from: DateTime(2026, 11, 18),
        to: DateTime(2026, 11, 18),
      ));
      expect(periodRange(EarningsPeriod.week, now).from, DateTime(2026, 11, 12));
      expect(periodRange(EarningsPeriod.month, now).from, DateTime(2026, 11));
    });

    test('Polish plural of „kurs”', () {
      expect([1, 2, 4, 5, 11, 12, 14, 21, 22, 25, 112, 122].map(ridesWord), [
        'kurs',
        'kursy',
        'kursy',
        'kursów',
        'kursów',
        'kursów',
        'kursów',
        'kursów',
        'kursy',
        'kursów',
        'kursów',
        'kursy',
      ]);
    });
  });

  group('board', () {
    late FakeRecords records;
    late SocketHarness ws;
    late ProviderContainer container;

    setUp(() async {
      records = FakeRecords()
        ..boardRides = [
          reservation('late', DateTime.utc(2026, 11, 20, 10)),
          reservation('soon', DateTime.utc(2026, 11, 19, 8)),
        ];
      ws = SocketHarness()..socket.start();
      await ws.connect();
      container = ProviderContainer(
        overrides: [
          driverRecordsRepositoryProvider.overrideWithValue(records),
          podwozkaSocketProvider.overrideWithValue(ws.socket),
        ],
      );
      container
        ..listen(boardProvider, (_, _) {})
        ..listen(myReservationsProvider, (_, _) {});
    });

    tearDown(() async {
      container.dispose();
      await ws.socket.dispose();
    });

    test('soonest reservation first', () async {
      final board = await container.read(boardProvider.future);
      expect(board.map((r) => r.id), ['soon', 'late']);
    });

    test('reloads when another driver changes the board (board.updated)', () async {
      await container.read(boardProvider.future);
      final loads = records.boardLoads;

      records.boardRides = [reservation('late', DateTime.utc(2026, 11, 20, 10))];
      ws.server.server({'type': 'board.updated', 'region_id': 'reg'});
      await pumpQueue();
      final board = await container.read(boardProvider.future);

      expect(records.boardLoads, greaterThan(loads));
      expect(board.map((r) => r.id), ['late']);
    });

    test('claiming moves the reservation from the board to „Twoje rezerwacje”', () async {
      await container.read(boardProvider.future);

      await container.read(boardProvider.notifier).claim('soon');

      expect(records.calls, ['claim:soon']);
      expect((await container.read(boardProvider.future)).map((r) => r.id), ['late']);
      expect((await container.read(myReservationsProvider.future)).map((r) => r.id), ['soon']);
    });

    test('a reservation taken by someone else shows the backend message', () async {
      records.claimError = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(),
          statusCode: 409,
          data: {'detail': 'Rezerwację wziął już inny kierowca'},
        ),
      );
      await container.read(boardProvider.future);

      await expectLater(
        container.read(boardProvider.notifier).claim('soon'),
        throwsA(
          predicate<Object>((e) => apiErrorMessage(e) == 'Rezerwację wziął już inny kierowca'),
        ),
      );
    });
  });

  testWidgets('earnings: net amount, breakdown and the cash commission to settle', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final records = FakeRecords();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [driverRecordsRepositoryProvider.overrideWithValue(records)],
        child: MaterialApp(
          theme: podwozkaTheme(Brightness.light),
          home: const Scaffold(body: EarningsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('180,78 zł'), findsOneWidget);
    expect(find.text('3 kursy'), findsOneWidget);
    expect(find.text('− 20,10 zł'), findsOneWidget);
    expect(find.textContaining('Prowizja do rozliczenia z gotówki: 20,10'), findsOneWidget);

    await tester.tap(find.text('7 dni'));
    await tester.pumpAndSettle();
    expect(records.lastRange!.to.difference(records.lastRange!.from).inDays, 6);
  });

  testWidgets('board screen: claim asks for confirmation first', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final records = FakeRecords()
      ..boardRides = [reservation('soon', DateTime.utc(2026, 11, 19, 8))];
    final ws = SocketHarness();
    addTearDown(ws.socket.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          driverRecordsRepositoryProvider.overrideWithValue(records),
          podwozkaSocketProvider.overrideWithValue(ws.socket),
        ],
        child: MaterialApp(
          theme: podwozkaTheme(Brightness.light),
          home: const Scaffold(body: BoardScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rynek Górny 1, Wieliczka'), findsOneWidget);
    await tester.tap(find.text('Przyjmij'));
    await tester.pumpAndSettle();
    expect(find.text('Przyjąć rezerwację?'), findsOneWidget);
    await tester.tap(find.text('Przyjmuję'));
    await tester.pumpAndSettle();

    expect(records.calls, ['claim:soon']);
    expect(find.text('Twoje rezerwacje'), findsOneWidget);
    expect(find.text('Oddaj'), findsOneWidget);
    expect(find.text('Na giełdzie nie ma teraz rezerwacji.'), findsOneWidget);
  });
}
