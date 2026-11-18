import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// In-memory socket: records what the app sends, lets the test push server frames.
class FakeTransport implements WsTransport {
  FakeTransport({this.failToOpen = false});

  final bool failToOpen;
  final sent = <Map<String, Object?>>[];
  final _incoming = StreamController<Object?>();
  bool closed = false;

  @override
  Future<void> get ready => failToOpen ? Future.error(Exception('refused')) : Future.value();

  @override
  Stream<Object?> get messages => _incoming.stream;

  @override
  void send(String text) => sent.add(jsonDecode(text) as Map<String, Object?>);

  @override
  Future<void> close() async {
    closed = true;
    if (!_incoming.isClosed) unawaited(_incoming.close());
  }

  void serverSends(Map<String, Object?> frame) => _incoming.add(jsonEncode(frame));

  /// Server closes the connection (e.g. 1008 after token_expired).
  void serverCloses() => unawaited(_incoming.close());

  Iterable<String?> get sentTypes => sent.map((m) => m['type'] as String?);
}

class Harness {
  Harness({this.openFailures = 0});

  int openFailures;
  final transports = <FakeTransport>[];
  final tokenCalls = <bool>[];
  Object? tokenError;

  late final socket = PodwozkaSocket(
    url: Uri.parse('ws://localhost:8000/ws'),
    tokenProvider: ({bool forceRefresh = false}) async {
      tokenCalls.add(forceRefresh);
      final error = tokenError;
      if (error != null) throw error;
      return forceRefresh ? 'fresh-token' : 'token';
    },
    connect: (url) {
      final t = FakeTransport(failToOpen: openFailures-- > 0);
      transports.add(t);
      return t;
    },
  );

  FakeTransport get current => transports.last;

  void authenticate() => current.serverSends({'type': 'auth_ok', 'user_id': 'u1', 'roles': []});
}

void main() {
  test('builds ws/wss URL from the REST base URL', () {
    expect(
      PodwozkaSocket.urlFromApiBase('http://localhost:8000').toString(),
      'ws://localhost:8000/ws',
    );
    expect(
      PodwozkaSocket.urlFromApiBase('https://api.podwozka.pl/').toString(),
      'wss://api.podwozka.pl/ws',
    );
  });

  test('sends auth as the first message and becomes connected after auth_ok', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      async.flushMicrotasks();

      expect(h.current.sent.first, {'type': 'auth', 'token': 'token'});
      expect(h.socket.state, WsConnectionState.connecting);

      h.authenticate();
      async.flushMicrotasks();
      expect(h.socket.state, WsConnectionState.connected);
    });
  });

  test('re-subscribes rides after a reconnect', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      async.flushMicrotasks();
      h.authenticate();
      async.flushMicrotasks();

      h.socket.subscribeRide('ride-1');
      expect(h.current.sent.last, {'type': 'subscribe', 'ride_id': 'ride-1'});

      h.current.serverCloses();
      async.flushMicrotasks();
      expect(h.socket.state, WsConnectionState.waitingToReconnect);

      async.elapse(const Duration(seconds: 1));
      h.authenticate();
      async.flushMicrotasks();

      expect(h.transports, hasLength(2));
      expect(h.current.sent, [
        {'type': 'auth', 'token': 'token'},
        {'type': 'subscribe', 'ride_id': 'ride-1'},
      ]);
    });
  });

  test('subscriptions made while offline are sent once connected', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      h.socket.subscribeRide('ride-7');
      async.flushMicrotasks();
      expect(h.current.sentTypes, ['auth']);

      h.authenticate();
      async.flushMicrotasks();
      expect(h.current.sent.last, {'type': 'subscribe', 'ride_id': 'ride-7'});
    });
  });

  test('reconnects with backoff 1, 2, 5, 10, 30, 30 s while the server is down', () {
    fakeAsync((async) {
      final h = Harness(openFailures: 100)..socket.start();
      async.flushMicrotasks();
      expect(h.transports, hasLength(1));

      for (final (seconds, attempts) in [(1, 2), (2, 3), (5, 4), (10, 5), (30, 6), (30, 7)]) {
        async.elapse(Duration(seconds: seconds) - const Duration(milliseconds: 1));
        expect(h.transports, hasLength(attempts - 1), reason: 'not before $seconds s');
        async.elapse(const Duration(milliseconds: 1));
        expect(h.transports, hasLength(attempts), reason: 'after $seconds s');
      }
    });
  });

  test('backoff starts again from 1 s after a successful connection', () {
    fakeAsync((async) {
      final h = Harness(openFailures: 2)..socket.start();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 3)); // 1 s + 2 s → third attempt succeeds
      h.authenticate();
      async.flushMicrotasks();
      expect(h.transports, hasLength(3));

      h.current.serverCloses();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 1));
      expect(h.transports, hasLength(4));
    });
  });

  test('pings every 25 s and reconnects when pong does not arrive within 10 s', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      async.flushMicrotasks();
      h.authenticate();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 25));
      expect(h.current.sentTypes.last, 'ping');
      h.current.serverSends({'type': 'pong'});
      async.elapse(const Duration(seconds: 10));
      expect(h.transports, hasLength(1), reason: 'pong arrived in time');

      async.elapse(const Duration(seconds: 15)); // second ping at 50 s, no pong
      expect(h.current.sentTypes.last, 'ping');
      async.elapse(const Duration(seconds: 10));
      expect(h.transports.first.closed, isTrue);
      expect(h.socket.state, WsConnectionState.waitingToReconnect);

      async.elapse(const Duration(seconds: 1));
      expect(h.transports, hasLength(2));
    });
  });

  test('gives up waiting for auth_ok after 10 s and retries', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 10));
      expect(h.socket.state, WsConnectionState.waitingToReconnect);
      async.elapse(const Duration(seconds: 1));
      expect(h.transports, hasLength(2));
    });
  });

  test('token_expired → reconnects immediately with a refreshed token', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      async.flushMicrotasks();
      h.authenticate();
      async.flushMicrotasks();

      h.current.serverSends({'type': 'token_expired'});
      h.current.serverCloses();
      async.flushMicrotasks();
      async.elapse(Duration.zero);

      expect(h.transports, hasLength(2));
      expect(h.tokenCalls, [false, true]);
      expect(h.current.sent.first, {'type': 'auth', 'token': 'fresh-token'});
    });
  });

  test('expired session stops the socket without reconnect loops', () {
    fakeAsync((async) {
      final h = Harness()..tokenError = const SessionExpiredException();
      h.socket.start();
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 5));

      expect(h.transports, isEmpty);
      expect(h.socket.state, WsConnectionState.disconnected);
    });
  });

  test('stop() closes the connection and cancels reconnects', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      async.flushMicrotasks();
      h.authenticate();
      async.flushMicrotasks();

      unawaited(h.socket.stop());
      async.flushMicrotasks();
      async.elapse(const Duration(minutes: 1));

      expect(h.current.closed, isTrue);
      expect(h.transports, hasLength(1));
      expect(h.socket.state, WsConnectionState.disconnected);
    });
  });

  test('send() works only while connected (positions are not queued)', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      async.flushMicrotasks();
      expect(h.socket.send({'type': 'driver.location'}), isFalse);

      h.authenticate();
      async.flushMicrotasks();
      expect(h.socket.send({'type': 'driver.location'}), isTrue);
      expect(h.current.sentTypes, ['auth', 'driver.location']);
    });
  });

  test('parses server events and ignores internal frames', () {
    fakeAsync((async) {
      final h = Harness()..socket.start();
      final events = <WsEvent>[];
      h.socket.events.listen(events.add);
      async.flushMicrotasks();
      h.authenticate();
      h.current
        ..serverSends({'type': 'subscribed', 'ride_id': 'r1'})
        ..serverSends({
          'type': 'ride.status',
          'ride_id': 'r1',
          'status': 'driver_arriving',
          'at': '2026-11-18T10:00:00Z',
        })
        ..serverSends({
          'type': 'ride.driver_location',
          'ride_id': 'r1',
          'location': {'lat': 50.1, 'lng': 19.9},
          'heading': 90,
          'eta_s': 240,
        })
        ..serverSends({
          'type': 'offer.new',
          'offer_id': 'o1',
          'ride_id': 'r2',
          'expires_at': '2026-11-18T10:00:20Z',
        })
        ..serverSends({'type': 'board.updated', 'region_id': 'reg'})
        ..serverSends({'type': 'something.new'});
      async.flushMicrotasks();

      expect(events, hasLength(5));
      final status = events[0] as RideStatusChanged;
      expect(status.status, 'driver_arriving');
      expect(status.at, DateTime.utc(2026, 11, 18, 10));
      final location = events[1] as DriverLocationChanged;
      expect((location.lat, location.lng, location.etaSeconds), (50.1, 19.9, 240));
      expect((events[2] as OfferReceived).expiresAt, DateTime.utc(2026, 11, 18, 10, 0, 20));
      expect(events[3], isA<BoardUpdated>());
      expect((events[4] as WsUnknown).type, 'something.new');
    });
  });

  test('driver.location message follows the protocol', () {
    final fix = LocationFix(
      lat: 50.1,
      lng: 19.9,
      heading: 90,
      speedMps: 12.5,
      accuracyM: 8,
      at: DateTime.utc(2026, 11, 18, 10),
    );
    expect(fix.toDriverLocationMessage(), {
      'type': 'driver.location',
      'location': {'lat': 50.1, 'lng': 19.9},
      'heading': 90.0,
      'speed_mps': 12.5,
      'accuracy_m': 8.0,
      'at': '2026-11-18T10:00:00.000Z',
    });
    // Android reports -1 when heading/speed are unknown — not sent.
    final unknown = const LocationFix(
      lat: 1,
      lng: 2,
      heading: -1,
      speedMps: -1,
    ).toDriverLocationMessage();
    expect(unknown.containsKey('heading'), isFalse);
    expect(unknown.containsKey('speed_mps'), isFalse);
  });
}
