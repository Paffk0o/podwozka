import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:podwozka_passenger/data/passenger_repository.dart';
import 'package:podwozka_passenger/features/ordering/providers/order_controller.dart';
import 'package:podwozka_passenger/features/ordering/providers/place_search.dart';

import 'fakes.dart';

void main() {
  late FakePassengerRepository repo;
  late FakeLocationService location;
  late ProviderContainer container;

  OrderController controller() => container.read(orderControllerProvider.notifier);
  OrderState state() => container.read(orderControllerProvider);

  setUp(() {
    repo = FakePassengerRepository();
    location = FakeLocationService();
    container = ProviderContainer(
      overrides: [
        passengerRepositoryProvider.overrideWithValue(repo),
        locationServiceProvider.overrideWithValue(location),
      ],
    );
    // Keep the auto-dispose search provider alive between reads.
    container.listen(placeSearchProvider, (_, _) {});
  });

  tearDown(() => container.dispose());

  group('scheduleError (same limits as the backend)', () {
    final now = DateTime(2026, 11, 18, 10);

    test('at least 30 minutes ahead', () {
      expect(scheduleError(now.add(const Duration(minutes: 29)), now: now), contains('30 minut'));
      expect(scheduleError(now.add(const Duration(minutes: 30)), now: now), isNull);
    });

    test('at most 14 days ahead', () {
      expect(
        scheduleError(now.add(const Duration(days: 14, minutes: 1)), now: now),
        contains('14 dni'),
      );
      expect(scheduleError(now.add(const Duration(days: 14)), now: now), isNull);
    });
  });

  test('my position becomes the pickup with an address', () async {
    await controller().locateMe();

    expect(state().myLocation, const LatLng(49.9837, 20.0553));
    expect(state().pickupSource, PickupSource.myLocation);
    expect(state().pickup!.address, startsWith('Ulica przy'));
  });

  test('denied location permission explains what to do and keeps the form usable', () async {
    location.access = LocationAccess.deniedForever;

    await controller().locateMe();

    expect(state().pickup, isNull);
    expect(state().error, contains('ustawieniach telefonu'));
  });

  test('a dropped pin without an address is still a valid pickup', () async {
    repo.reverseError = Exception('Nominatim down');

    await controller().setPickupFromPin(const LatLng(50, 20));

    expect(state().pickup!.address, 'Punkt na mapie');
    expect(state().pickupSource, PickupSource.pin);
  });

  test('quote is requested once both points are known', () async {
    controller().setPickup(wieliczka);
    expect(repo.quoteCalls, isEmpty);

    controller().setDestination(krakow);
    expect(state().quoting, isTrue);
    await pumpEventQueue();

    expect(repo.quoteCalls, hasLength(1));
    expect(state().quote!.price, 6693);
    expect(state().canOrder, isTrue);
  });

  test('a slow, outdated quote does not overwrite the newer one', () async {
    final slow = Completer<Quote>();
    final responses = [() => slow.future, () => Future.value(aQuote(id: 'fresh', price: 7000))];
    repo.onQuote = () => responses.removeAt(0)();

    controller()
      ..setPickup(wieliczka)
      ..setDestination(krakow); // request 1 (slow)
    controller().setDestination(krakow); // request 2
    await pumpEventQueue();
    slow.complete(aQuote(id: 'stale', price: 1));
    await pumpEventQueue();

    expect(state().quote!.id, 'fresh');
  });

  test('outside the service area the backend message is shown', () async {
    repo.onQuote = () =>
        Future.error(apiError(422, {'detail': 'Punkt odbioru jest poza obsługiwanym obszarem'}));

    controller()
      ..setPickup(wieliczka)
      ..setDestination(krakow);
    await pumpEventQueue();

    expect(state().quote, isNull);
    expect(state().error, 'Punkt odbioru jest poza obsługiwanym obszarem');
  });

  test('a reservation re-quotes with the chosen time; invalid time is rejected', () async {
    controller()
      ..setPickup(wieliczka)
      ..setDestination(krakow);
    await pumpEventQueue();

    expect(controller().setSchedule(DateTime.now().add(const Duration(minutes: 10))), isNotNull);
    expect(repo.quoteCalls, hasLength(1));

    final at = DateTime.now().add(const Duration(hours: 3));
    expect(controller().setSchedule(at), isNull);
    await pumpEventQueue();

    expect(repo.quoteCalls.last.scheduledAt, at);
    expect(state().isReservation, isTrue);
  });

  test('ordering pays cash and clears the form', () async {
    controller()
      ..setPickup(wieliczka)
      ..setDestination(krakow);
    await pumpEventQueue();

    final ordered = await controller().submit();

    expect(ordered, isNotNull);
    expect(repo.orders, ['q1/cash']);
    expect(state().pickup, isNull);
    expect(state().quote, isNull);
  });

  test('an expired quote is refreshed instead of ordering at an old price', () async {
    repo.onQuote = () =>
        Future.value(aQuote(expiresAt: DateTime.now().subtract(const Duration(seconds: 1))));
    controller()
      ..setPickup(wieliczka)
      ..setDestination(krakow);
    await pumpEventQueue();

    final ordered = await controller().submit();

    expect(ordered, isNull);
    expect(repo.orders, isEmpty);
    expect(repo.quoteCalls, hasLength(2));
    expect(state().error, contains('Wycena wygasła'));
  });

  test('order rejected by the backend keeps the form and shows why', () async {
    repo.onOrder = () => Future.error(apiError(409, {'detail': 'Masz już aktywny kurs'}));
    controller()
      ..setPickup(wieliczka)
      ..setDestination(krakow);
    await pumpEventQueue();

    expect(await controller().submit(), isNull);
    expect(state().error, 'Masz już aktywny kurs');
    expect(state().pickup, isNotNull);
    expect(state().submitting, isFalse);
  });

  group('address search', () {
    test('waits for 3 characters and debounces typing', () async {
      final search = container.read(placeSearchProvider.notifier);

      search.onQueryChanged('Ry');
      await Future<void>.delayed(PlaceSearchController.debounce * 2);
      expect(repo.autocompleteCalls, isEmpty);

      search
        ..onQueryChanged('Ryn')
        ..onQueryChanged('Rynek')
        ..onQueryChanged('Rynek G');
      await Future<void>.delayed(PlaceSearchController.debounce * 2);

      expect(repo.autocompleteCalls.map((c) => c.$1), ['Rynek G']);
    });

    test('one session token per search; a new one after choosing', () async {
      repo.suggestions = [
        PlaceSuggestion(placeId: 'p1', primaryText: 'Rynek Główny', secondaryText: 'Kraków'),
      ];
      final search = container.read(placeSearchProvider.notifier);

      search.onQueryChanged('Rynek');
      await Future<void>.delayed(PlaceSearchController.debounce * 2);
      search.onQueryChanged('Rynek Gł');
      await Future<void>.delayed(PlaceSearchController.debounce * 2);
      final firstSession = repo.autocompleteCalls.map((c) => c.$2).toSet();
      expect(firstSession, hasLength(1));
      expect(container.read(placeSearchProvider).results.single.primaryText, 'Rynek Główny');

      await search.choose(repo.suggestions.single);
      search.onQueryChanged('Dworzec');
      await Future<void>.delayed(PlaceSearchController.debounce * 2);

      expect(repo.autocompleteCalls.last.$2, isNot(firstSession.single));
    });
  });
}
