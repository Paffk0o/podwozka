import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_passenger/data/passenger_repository.dart';
import 'package:podwozka_passenger/features/ride_tracking/providers/active_ride_controller.dart';
import 'package:podwozka_passenger/features/ride_tracking/providers/ride_stage.dart';

import 'fakes.dart';

void main() {
  group('passenger stages', () {
    final now = DateTime.utc(2026, 11, 18, 10);

    test('every status maps to a screen state', () {
      expect(stageOf(RideStatus.dispatching), PassengerStage.searching);
      expect(stageOf(RideStatus.driverArriving), PassengerStage.driverArriving);
      expect(stageOf(RideStatus.arrived), PassengerStage.driverArrived);
      expect(stageOf(RideStatus.noDriver), PassengerStage.noDriver);
      for (final status in RideStatus.values) {
        expect(stageOf(status).title, isNotEmpty);
      }
    });

    test('cancellation follows the backend state machine (not once the ride started)', () {
      expect(PassengerStage.driverArrived.canCancel, isTrue);
      expect(PassengerStage.scheduled.canCancel, isTrue);
      expect(PassengerStage.inProgress.canCancel, isFalse);
      expect(PassengerStage.completed.canCancel, isFalse);
    });

    test('a reservation claimed days ahead is still a reservation, not a ride in progress', () {
      final claimed = aRide(
        status: RideStatus.accepted,
        scheduledAt: now.add(const Duration(days: 2)),
        driver: jan,
      );
      expect(passengerStage(claimed, now: now), PassengerStage.scheduled);
      expect(isOngoing(claimed, now: now), isFalse);

      final soon = aRide(
        status: RideStatus.accepted,
        scheduledAt: now.add(const Duration(minutes: 40)),
      );
      expect(passengerStage(soon, now: now), PassengerStage.driverAssigned);
      expect(isOngoing(soon, now: now), isTrue);
    });
  });

  group('ActiveRideController', () {
    late FakePassengerRepository repo;
    late List<FakeTransport> transports;
    late PodwozkaSocket socket;
    late ProviderContainer container;

    FakeTransport server() => transports.last;
    TrackedRide? tracked() => container.read(activeRideProvider).value;

    /// Builds the controller after the test arranged the backend state.
    Future<TrackedRide?> start() {
      container.listen(activeRideProvider, (_, _) {});
      return container.read(activeRideProvider.future);
    }

    Future<void> connect() async {
      await pumpEventQueue();
      server().server({
        'type': 'auth_ok',
        'user_id': 'u1',
        'roles': ['passenger'],
      });
      await pumpEventQueue();
    }

    setUp(() async {
      repo = FakePassengerRepository();
      transports = [];
      socket = PodwozkaSocket(
        url: Uri.parse('ws://test/ws'),
        tokenProvider: ({bool forceRefresh = false}) async => 'token',
        connect: (_) {
          final t = FakeTransport();
          transports.add(t);
          return t;
        },
        backoff: const [Duration.zero],
      )..start();
      container = ProviderContainer(
        overrides: [
          passengerRepositoryProvider.overrideWithValue(repo),
          podwozkaSocketProvider.overrideWithValue(socket),
        ],
      );
      await connect();
    });

    tearDown(() async {
      container.dispose();
      await socket.dispose();
    });

    test('after a restart returns to the ongoing ride and follows every active ride', () async {
      repo.active = [
        aRide(
          id: 'future',
          status: RideStatus.scheduled,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        ),
        aRide(id: 'now', status: RideStatus.driverArriving, driver: jan),
      ];

      await start();

      expect(tracked()!.ride.id, 'now');
      expect(tracked()!.driverLocation, const LatLng(49.99, 20.06));
      expect(server().subscribedRides(), containsAll(['future', 'now']));
    });

    test('no ongoing ride → order screen (null)', () async {
      repo.active = [
        aRide(
          status: RideStatus.scheduled,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        ),
      ];

      expect(await start(), isNull);
    });

    test(
      'live: driver position updates the map, a status change re-reads the ride via REST',
      () async {
        await start();
        final ordered = aRide();
        container.read(activeRideProvider.notifier).track(ordered);
        expect(server().subscribedRides(), contains('r1'));

        server().server({
          'type': 'ride.driver_location',
          'ride_id': 'r1',
          'location': {'lat': 49.995, 'lng': 20.058},
          'eta_s': 180,
        });
        await pumpEventQueue();
        expect(tracked()!.driverLocation, const LatLng(49.995, 20.058));
        expect(tracked()!.etaSeconds, 180);

        repo.rides['r1'] = aRide(status: RideStatus.accepted, driver: jan);
        server().server({'type': 'ride.status', 'ride_id': 'r1', 'status': 'accepted'});
        await pumpEventQueue();

        expect(tracked()!.stage, PassengerStage.driverAssigned);
        expect(tracked()!.ride.driver!.fullName, 'Jan Kierowca');
        // The live position is kept until the next update.
        expect(tracked()!.driverLocation, isNotNull);
      },
    );

    test('after a reconnect the state is reloaded from REST (missed events)', () async {
      repo.active = [aRide(status: RideStatus.dispatching)];
      await start();
      expect(tracked()!.stage, PassengerStage.searching);

      repo.active = [aRide(status: RideStatus.arrived, driver: jan)];
      server().drop();
      await pumpEventQueue();
      await Future<void>.delayed(Duration.zero);
      await connect();
      await container.read(activeRideProvider.future);

      expect(tracked()!.stage, PassengerStage.driverArrived);
      expect(server().subscribedRides(), contains('r1'));
    });

    test('a reservation that starts being served takes over the screen', () async {
      repo.active = [
        aRide(
          id: 'res',
          status: RideStatus.scheduled,
          scheduledAt: DateTime.now().add(const Duration(hours: 2)),
        ),
      ];
      expect(await start(), isNull);

      repo.active = [aRide(id: 'res', status: RideStatus.driverArriving, driver: jan)];
      server().server({'type': 'ride.status', 'ride_id': 'res', 'status': 'driver_arriving'});
      await pumpEventQueue();
      await container.read(activeRideProvider.future);

      expect(tracked()!.ride.id, 'res');
    });

    test('cancel, then the summary stays until dismissed', () async {
      repo.active = [aRide(status: RideStatus.accepted, driver: jan)];
      await start();

      await container.read(activeRideProvider.notifier).cancel(reason: 'Zmiana planów');

      expect(repo.cancels, [('r1', 'Zmiana planów')]);
      expect(tracked()!.stage, PassengerStage.cancelledByPassenger);
      expect(server().sent.last, {'type': 'unsubscribe', 'ride_id': 'r1'});

      container.read(activeRideProvider.notifier).dismiss();
      expect(tracked(), isNull);
    });

    test('rating a finished ride', () async {
      repo.active = [aRide(status: RideStatus.inProgress, driver: jan)];
      await start();
      repo.rides['r1'] = aRide(status: RideStatus.completed, driver: jan);
      server().server({'type': 'ride.status', 'ride_id': 'r1', 'status': 'completed'});
      await pumpEventQueue();
      expect(tracked()!.stage, PassengerStage.completed);

      await container.read(activeRideProvider.notifier).rateDriver(stars: 5, comment: 'Super');

      expect(repo.ratings, [('r1', 5, 'Super')]);
      expect(tracked()!.rated, isTrue);
    });
  });
}
