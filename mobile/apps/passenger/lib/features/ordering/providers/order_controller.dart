import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../../../data/passenger_repository.dart';

/// Same limits as the backend (`SCHEDULE_MIN_AHEAD`, `SCHEDULE_MAX_AHEAD`).
const scheduleMinAhead = Duration(minutes: 30);
const scheduleMaxAhead = Duration(days: 14);

/// Polish error for a reservation time, or null when it is allowed.
String? scheduleError(DateTime at, {DateTime? now}) {
  final current = now ?? DateTime.now();
  if (at.isBefore(current.add(scheduleMinAhead))) {
    return 'Rezerwacja musi być co najmniej 30 minut od teraz.';
  }
  if (at.isAfter(current.add(scheduleMaxAhead))) {
    return 'Rezerwację można złożyć najwyżej 14 dni naprzód.';
  }
  return null;
}

enum PickupSource { myLocation, pin, search }

class OrderState {
  const OrderState({
    this.pickup,
    this.pickupSource,
    this.destination,
    this.scheduledAt,
    this.myLocation,
    this.quote,
    this.quoting = false,
    this.locating = false,
    this.submitting = false,
    this.error,
  });

  final Place? pickup;
  final PickupSource? pickupSource;
  final Place? destination;

  /// null = „teraz”.
  final DateTime? scheduledAt;
  final LatLng? myLocation;
  final Quote? quote;
  final bool quoting;
  final bool locating;
  final bool submitting;
  final String? error;

  bool get isReservation => scheduledAt != null;
  bool get canOrder => quote != null && !quoting && !submitting;

  OrderState copyWith({
    Place? pickup,
    PickupSource? pickupSource,
    Place? destination,
    DateTime? Function()? scheduledAt,
    LatLng? myLocation,
    Quote? Function()? quote,
    bool? quoting,
    bool? locating,
    bool? submitting,
    String? Function()? error,
  }) => OrderState(
    pickup: pickup ?? this.pickup,
    pickupSource: pickupSource ?? this.pickupSource,
    destination: destination ?? this.destination,
    scheduledAt: scheduledAt != null ? scheduledAt() : this.scheduledAt,
    myLocation: myLocation ?? this.myLocation,
    quote: quote != null ? quote() : this.quote,
    quoting: quoting ?? this.quoting,
    locating: locating ?? this.locating,
    submitting: submitting ?? this.submitting,
    error: error != null ? error() : this.error,
  );
}

/// Ordering flow: from where → to where → when → quote → order (cash).
class OrderController extends Notifier<OrderState> {
  int _quoteRequest = 0;

  PassengerRepository get _repo => ref.read(passengerRepositoryProvider);

  @override
  OrderState build() => const OrderState();

  /// Centres on the user and, if no pickup was chosen yet, uses their position as pickup.
  Future<void> locateMe() async {
    state = state.copyWith(locating: true, error: () => null);
    final location = ref.read(locationServiceProvider);
    try {
      final access = await location.ensureAccess();
      if (access != LocationAccess.granted) {
        state = state.copyWith(locating: false, error: () => locationAccessMessage(access));
        return;
      }
      final fix = await location.currentPosition();
      if (fix == null) {
        state = state.copyWith(
          locating: false,
          error: () => 'Nie udało się ustalić Twojej pozycji. Wybierz adres ręcznie.',
        );
        return;
      }
      final me = fix.toLatLng();
      state = state.copyWith(myLocation: me, locating: false);
      if (state.pickup == null || state.pickupSource == PickupSource.myLocation) {
        await _pickupAt(me, PickupSource.myLocation);
      }
    } on Object catch (e) {
      state = state.copyWith(locating: false, error: () => apiErrorMessage(e));
    }
  }

  /// Long press on the map.
  Future<void> setPickupFromPin(LatLng point) => _pickupAt(point, PickupSource.pin);

  Future<void> _pickupAt(LatLng point, PickupSource source) async {
    Place place;
    try {
      place = await _repo.reverseGeocode(point);
    } on Object {
      // Address lookup is a nicety — the point itself is enough to order.
      place = Place(location: point.toGeoPoint(), address: 'Punkt na mapie');
    }
    setPickup(place, source: source);
  }

  void setPickup(Place place, {PickupSource source = PickupSource.search}) {
    state = state.copyWith(pickup: place, pickupSource: source, error: () => null);
    _requote();
  }

  void setDestination(Place place) {
    state = state.copyWith(destination: place, error: () => null);
    _requote();
  }

  /// null = „teraz”. Returns the validation error (also kept in state) or null.
  String? setSchedule(DateTime? at) {
    if (at != null) {
      final error = scheduleError(at);
      if (error != null) {
        state = state.copyWith(error: () => error);
        return error;
      }
    }
    state = state.copyWith(scheduledAt: () => at, error: () => null);
    _requote();
    return null;
  }

  void _requote() {
    final pickup = state.pickup;
    final destination = state.destination;
    if (pickup == null || destination == null) return;
    final request = ++_quoteRequest;
    state = state.copyWith(quoting: true, quote: () => null, error: () => null);
    _repo
        .quote(pickup: pickup, destination: destination, scheduledAt: state.scheduledAt)
        .then((quote) {
          if (request != _quoteRequest) return; // a newer request is on its way
          state = state.copyWith(quoting: false, quote: () => quote);
        })
        .catchError((Object e) {
          if (request != _quoteRequest) return;
          state = state.copyWith(quoting: false, error: () => apiErrorMessage(e));
        });
  }

  /// Orders the quoted ride (cash). Returns the ride, or null when the user must look again
  /// (expired quote → new price shown, or an error).
  Future<Ride?> submit({String? note, DateTime? now}) async {
    final quote = state.quote;
    if (quote == null || state.submitting) return null;
    final current = now ?? DateTime.now();
    if (!quote.expiresAt.isAfter(current.add(const Duration(seconds: 10)))) {
      _requote();
      state = state.copyWith(error: () => 'Wycena wygasła — sprawdź nową cenę i zamów ponownie.');
      return null;
    }
    state = state.copyWith(submitting: true, error: () => null);
    try {
      final ride = await _repo.orderRide(
        quoteId: quote.id,
        method: PaymentMethod.cash,
        note: (note?.trim().isEmpty ?? true) ? null : note!.trim(),
      );
      state = OrderState(myLocation: state.myLocation);
      return ride;
    } on Object catch (e) {
      state = state.copyWith(submitting: false, error: () => apiErrorMessage(e));
      return null;
    }
  }

  void reset() => state = OrderState(myLocation: state.myLocation);
}

final orderControllerProvider = NotifierProvider<OrderController, OrderState>(OrderController.new);
