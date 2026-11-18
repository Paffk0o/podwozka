import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../../../data/passenger_repository.dart';
import 'order_controller.dart';

class PlaceSearchState {
  const PlaceSearchState({
    this.query = '',
    this.results = const [],
    this.loading = false,
    this.error,
  });

  final String query;
  final List<PlaceSuggestion> results;
  final bool loading;
  final String? error;

  /// Too short to ask the API (saves Places requests).
  bool get tooShort => query.trim().length < PlaceSearchController.minChars;
}

/// Address autocomplete: debounced, ignores stale responses, one session token per search
/// (Places bills autocomplete + details of one search as a single session).
class PlaceSearchController extends Notifier<PlaceSearchState> {
  static const minChars = 3;
  static const debounce = Duration(milliseconds: 300);

  Timer? _timer;
  int _request = 0;
  late String _sessionToken;

  PassengerRepository get _repo => ref.read(passengerRepositoryProvider);

  @override
  PlaceSearchState build() {
    _sessionToken = newSessionToken();
    ref.onDispose(() => _timer?.cancel());
    return const PlaceSearchState();
  }

  void onQueryChanged(String query) {
    _timer?.cancel();
    final request = ++_request;
    if (query.trim().length < minChars) {
      state = PlaceSearchState(query: query);
      return;
    }
    state = PlaceSearchState(query: query, results: state.results, loading: true);
    _timer = Timer(debounce, () => _search(query, request));
  }

  Future<void> _search(String query, int request) async {
    try {
      final results = await _repo.autocomplete(
        query.trim(),
        sessionToken: _sessionToken,
        near: ref.read(orderControllerProvider).myLocation,
      );
      if (request != _request) return;
      state = PlaceSearchState(query: query, results: results);
    } on Object catch (e) {
      if (request != _request) return;
      state = PlaceSearchState(query: query, error: apiErrorMessage(e));
    }
  }

  /// Resolves the chosen suggestion to coordinates and ends the session.
  Future<Place> choose(PlaceSuggestion suggestion) async {
    final place = await _repo.placeDetails(suggestion.placeId, sessionToken: _sessionToken);
    _sessionToken = newSessionToken();
    return place;
  }
}

final placeSearchProvider = NotifierProvider.autoDispose<PlaceSearchController, PlaceSearchState>(
  PlaceSearchController.new,
);

final _random = Random.secure();

String newSessionToken() =>
    List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
