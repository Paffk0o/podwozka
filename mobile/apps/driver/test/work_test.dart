import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_driver/features/work/data/location_publisher.dart';
import 'package:podwozka_driver/features/work/data/work_repository.dart';
import 'package:podwozka_driver/features/work/providers/ride_flow.dart';
import 'package:podwozka_driver/features/work/providers/work_controller.dart';
import 'package:podwozka_driver/features/work/ui/work_screen.dart';

import 'work_fakes.dart';

void main() {
  group('ride flow', () {
    test('one button per stage, in the backend order', () {
      expect(nextAction(aRide(status: RideStatus.accepted))!.action, DriverRideAction.depart);
      expect(
        nextAction(aRide(status: RideStatus.driverArriving))!.action,
        DriverRideAction.arrived,
      );
      expect(nextAction(aRide(status: RideStatus.arrived))!.action, DriverRideAction.start);
      expect(nextAction(aRide(status: RideStatus.inProgress))!.action, DriverRideAction.complete);
      expect(nextAction(aRide(status: RideStatus.completed)), isNull);
    });

    test('after completion: cash first, then the rating', () {
      expect(driverStage(aRide(status: RideStatus.completed)), DriverStage.collectCash);
      expect(
        driverStage(aRide(status: RideStatus.completed, payment: PaymentStatus.cashCollected)),
        DriverStage.ratePassenger,
      );
      expect(driverStage(aRide(status: RideStatus.cancelledByPassenger)), DriverStage.cancelled);
    });

    test('the driver may cancel only before the passenger is on board', () {
      expect(driverCanCancel(aRide(status: RideStatus.arrived)), isTrue);
      expect(driverCanCancel(aRide(status: RideStatus.inProgress)), isFalse);
    });

    test('navigation: to the pickup first, then to the destination', () {
      expect(navigationTarget(aRide(status: RideStatus.driverArriving)), pickup);
      expect(navigationTarget(aRide(status: RideStatus.inProgress)), destination);

      final google = navigationUris(const LatLng(50.0617, 19.9373), NavigationApp.googleMaps);
      expect(google.first.toString(), 'google.navigation:q=50.0617,19.9373&mode=d');
      expect(google.last.queryParameters['destination'], '50.0617,19.9373');
      final waze = navigationUris(const LatLng(50.0617, 19.9373), NavigationApp.waze).single;
      expect(waze.host, 'waze.com');
      expect(waze.queryParameters, {'ll': '50.0617,19.9373', 'navigate': 'yes'});
    });

    test('offer countdown rounds up and never goes negative', () {
      final now = DateTime.utc(2026, 11, 18, 10);
      expect(offerSecondsLeft(now.add(const Duration(milliseconds: 19100)), now: now), 20);
      expect(offerSecondsLeft(now.add(const Duration(seconds: 3)), now: now), 3);
      expect(offerSecondsLeft(now.subtract(const Duration(seconds: 1)), now: now), 0);
    });
  });

  group('LocationPublisher', () {
    late SocketHarness ws;
    late FakeLocation location;
    late DateTime now;
    late LocationPublisher publisher;

    setUp(() async {
      ws = SocketHarness()..socket.start();
      await ws.connect();
      location = FakeLocation();
      now = DateTime.utc(2026, 11, 18, 10);
      publisher = LocationPublisher(
        location: location,
        socket: ws.socket,
        heartbeat: const Duration(milliseconds: 100),
        clock: () => now,
      );
    });

    tearDown(() async {
      await publisher.dispose();
      await ws.socket.dispose();
    });

    test('uses the foreground-service stream and throttles to one position per 3 s', () async {
      publisher.start();
      expect(location.lastDriverOnline, isTrue);

      location.fixes.add(const LocationFix(lat: 50, lng: 20));
      await pumpQueue();
      now = now.add(const Duration(seconds: 1));
      location.fixes.add(const LocationFix(lat: 50.001, lng: 20)); // too soon — skipped
      await pumpQueue();
      now = now.add(const Duration(seconds: 3));
      location.fixes.add(const LocationFix(lat: 50.002, lng: 20));
      await pumpQueue();

      final sent = ws.server.ofType('driver.location');
      expect(sent.map((m) => (m['location']! as Map)['lat']), [50.0, 50.002]);
    });

    test('repeats the last position while parked (presence TTL) and stops when offline', () async {
      publisher.start();
      location.fixes.add(const LocationFix(lat: 50, lng: 20));
      await pumpQueue();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final beforeStop = ws.server.ofType('driver.location').length;
      expect(beforeStop, greaterThanOrEqualTo(2));

      await publisher.stop();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(ws.server.ofType('driver.location'), hasLength(beforeStop));
      expect(publisher.isRunning, isFalse);
    });
  });

  group('WorkController', () {
    late FakeWorkRepository repo;
    late FakeLocation location;
    late FakeNotificationPermission notifications;
    late SocketHarness ws;
    late ProviderContainer container;

    WorkState state() => container.read(workProvider).requireValue;
    WorkController controller() => container.read(workProvider.notifier);

    Future<void> start() async {
      container.listen(workProvider, (_, _) {});
      await container.read(workProvider.future);
    }

    setUp(() async {
      repo = FakeWorkRepository();
      location = FakeLocation();
      notifications = FakeNotificationPermission();
      ws = SocketHarness()..socket.start();
      await ws.connect();
      container = ProviderContainer(
        overrides: [
          workRepositoryProvider.overrideWithValue(repo),
          locationServiceProvider.overrideWithValue(location),
          notificationPermissionProvider.overrideWithValue(notifications),
          podwozkaSocketProvider.overrideWithValue(ws.socket),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await ws.socket.dispose();
    });

    test('going online asks for permissions, tells the API and streams the position', () async {
      await start();

      await controller().goOnline();

      expect(repo.calls, ['online:true']);
      expect(notifications.asked, 1);
      expect(location.watchers, 1);
      expect(state().online, isTrue);
    });

    test('without location permission the driver stays offline with a Polish reason', () async {
      location.access = LocationAccess.deniedForever;
      await start();

      await expectLater(
        controller().goOnline(),
        throwsA(
          isA<GoOnlineException>().having((e) => e.message, 'message', contains('ustawieniach')),
        ),
      );
      expect(repo.calls, isEmpty);
      expect(location.watchers, 0);
    });

    test('GPS switched off while online → offline with a Polish reason, service stopped', () async {
      await start();
      await controller().goOnline();

      location.fixes.addError(const LocationUnavailableException(LocationAccess.serviceDisabled));
      await pumpEventQueue();

      expect(repo.calls, ['online:true', 'online:false']);
      expect(state().online, isFalse);
      expect(state().locationProblem, contains('Włącz GPS'));
      expect(container.read(locationPublisherProvider).isRunning, isFalse);

      await controller().goOnline();
      expect(state().locationProblem, isNull);
      expect(location.watchers, 2);
    });

    test('GPS lost during a ride: the driver stays online and is told why', () async {
      repo
        ..online = true
        ..active = aRide(status: RideStatus.driverArriving);
      await start();

      location.fixes.addError(const LocationUnavailableException(LocationAccess.serviceDisabled));
      await pumpEventQueue();

      expect(repo.calls, isEmpty);
      expect(state().online, isTrue);
      expect(state().locationProblem, isNotNull);
    });

    test(
      'after a restart an online driver is streaming again and the active ride is followed',
      () async {
        repo
          ..online = true
          ..active = aRide(status: RideStatus.driverArriving);

        await start();

        expect(location.watchers, 1);
        expect(ws.server.ofType('subscribe').single['ride_id'], 'r1');
        expect(driverStage(state().ride!), DriverStage.toPickup);
      },
    );

    test('an offer from the WebSocket → accept → the whole ride → cash → rating', () async {
      repo.online = true;
      await start();

      repo.offer = anOffer();
      ws.server.server({
        'type': 'offer.new',
        'offer_id': 'o1',
        'ride_id': 'r1',
        'expires_at': '2030-01-01T00:00:00Z',
      });
      await pumpQueue();
      expect(state().offer!.id, 'o1');

      await controller().acceptOffer();
      expect(state().offer, isNull);
      expect(state().ride!.status, RideStatus.accepted);

      for (var i = 0; i < 4; i++) {
        await controller().advance();
      }
      expect(repo.calls.where((c) => c.startsWith('action:')), [
        'action:depart',
        'action:arrived',
        'action:start',
        'action:complete',
      ]);
      // The API no longer reports it as active, the panel keeps it for the payment.
      expect(driverStage(state().ride!), DriverStage.collectCash);

      await controller().confirmCash();
      expect(driverStage(state().ride!), DriverStage.ratePassenger);

      await controller().ratePassenger(stars: 5);
      expect(repo.calls.last, 'rate:5');
      expect(state().ride, isNull);
    });

    test('an expired offer disappears', () async {
      repo
        ..online = true
        ..offer = anOffer();
      await start();
      expect(state().offer, isNotNull);

      repo.offer = null;
      ws.server.server({'type': 'offer.expired', 'offer_id': 'o1'});
      await pumpQueue();

      expect(state().offer, isNull);
    });

    test('a ride cancelled by the passenger is shown as such', () async {
      repo
        ..online = true
        ..active = aRide(status: RideStatus.driverArriving);
      await start();

      repo.active = null;
      ws.server.server({
        'type': 'ride.status',
        'ride_id': 'r1',
        'status': 'cancelled_by_passenger',
      });
      await pumpQueue();

      expect(state().ride!.status, RideStatus.cancelledByPassenger);
      controller().dismissFinished();
      expect(state().ride, isNull);
    });

    test('state is reloaded from REST after a reconnect (missed offer)', () async {
      repo.online = true;
      await start();
      repo.offer = anOffer();

      ws.server.drop();
      await pumpQueue();
      await ws.connect();
      await pumpQueue();

      expect(state().offer, isNotNull);
    });
  });

  group('screen', () {
    Future<FakeWorkRepository> pump(WidgetTester tester, FakeWorkRepository repo) async {
      tester.view
        ..physicalSize = const Size(1080, 2400)
        ..devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      final ws = SocketHarness(); // not started — no network in widget tests
      addTearDown(ws.socket.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workRepositoryProvider.overrideWithValue(repo),
            locationServiceProvider.overrideWithValue(FakeLocation()),
            notificationPermissionProvider.overrideWithValue(FakeNotificationPermission()),
            podwozkaSocketProvider.overrideWithValue(ws.socket),
            mapTilesProvider.overrideWithValue(
              const MapTilesConfig(urlTemplate: 'about:blank', userAgentPackageName: 'test'),
            ),
          ],
          child: MaterialApp(
            theme: podwozkaTheme(Brightness.light),
            home: const Scaffold(body: WorkPanelScreen()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      return repo;
    }

    testWidgets('offer: countdown, route, price, accept / decline', (tester) async {
      final repo = await pump(
        tester,
        FakeWorkRepository()
          ..online = true
          ..offer = anOffer(),
      );

      expect(find.text('Nowe zlecenie'), findsOneWidget);
      expect(find.text('80,35 zł'), findsOneWidget);
      expect(find.textContaining('979 m od Ciebie'), findsOneWidget);
      expect(find.text('Uwagi: Czekam przy fontannie'), findsOneWidget);
      // Real clock: under load (CI, emulators) a second may pass before the first frame.
      expect(find.byWidgetPredicate((w) => w is Text && ['19', '20'].contains(w.data)), findsOne);

      await tester.tap(find.text('Przyjmij'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(repo.calls, ['accept:o1']);
      expect(find.text('Jadę po pasażera'), findsOneWidget);
      expect(find.text('Nawiguj'), findsOneWidget);
      expect(find.byTooltip('Zadzwoń do pasażera'), findsOneWidget);
    });

    testWidgets('offline driver sees the switch and an explanation before going online', (
      tester,
    ) async {
      await pump(tester, FakeWorkRepository());

      expect(find.text('Jesteś offline'), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('Przejść w tryb online?'), findsOneWidget);
      expect(find.textContaining('powiadomienie „Jesteś online”'), findsOneWidget);
    });
  });
}
