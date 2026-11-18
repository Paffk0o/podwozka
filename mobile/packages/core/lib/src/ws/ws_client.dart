import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../auth/auth_service.dart';
import 'ws_events.dart';

/// Minimal socket abstraction so the client can be tested without a network.
abstract interface class WsTransport {
  /// Completes when the connection is open (throws if it cannot be opened).
  Future<void> get ready;
  Stream<Object?> get messages;
  void send(String text);
  Future<void> close();
}

typedef WsConnect = WsTransport Function(Uri url);

/// Real transport on top of `web_socket_channel`.
WsTransport connectWebSocket(Uri url) => _ChannelTransport(WebSocketChannel.connect(url));

class _ChannelTransport implements WsTransport {
  _ChannelTransport(this._channel);
  final WebSocketChannel _channel;

  @override
  Future<void> get ready => _channel.ready;
  @override
  Stream<Object?> get messages => _channel.stream;
  @override
  void send(String text) => _channel.sink.add(text);
  @override
  Future<void> close() => _channel.sink.close();
}

enum WsConnectionState {
  /// Not started, stopped, or the session expired (no automatic reconnect).
  disconnected,
  connecting,

  /// Authenticated (`auth_ok` received) — events flow, `send` works.
  connected,

  /// Connection lost; next attempt scheduled with backoff.
  waitingToReconnect,
}

/// Provides a valid access token; `forceRefresh` after `token_expired` / `unauthorized`.
/// Throws [SessionExpiredException] when the user must log in again.
typedef TokenProvider = Future<String> Function({bool forceRefresh});

/// Client for `/ws` implementing docs/ws-protocol.md:
/// auth as the first message, `ping` every 25 s with a 10 s `pong` deadline,
/// reconnect with backoff 1, 2, 5, 10, 30 s, re-subscribing rides after every reconnect.
///
/// REST stays the source of truth: listen to [states] and refresh screens via REST
/// each time the state becomes [WsConnectionState.connected].
class PodwozkaSocket {
  PodwozkaSocket({
    required this.url,
    required TokenProvider tokenProvider,
    WsConnect connect = connectWebSocket,
    this.pingInterval = const Duration(seconds: 25),
    this.pongTimeout = const Duration(seconds: 10),
    this.authTimeout = const Duration(seconds: 10),
    this.backoff = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 30),
    ],
  }) : _tokenProvider = tokenProvider,
       _connect = connect;

  final Uri url;
  final Duration pingInterval;
  final Duration pongTimeout;
  final Duration authTimeout;
  final List<Duration> backoff;
  final TokenProvider _tokenProvider;
  final WsConnect _connect;

  final _events = StreamController<WsEvent>.broadcast();
  final _states = StreamController<WsConnectionState>.broadcast();
  final _rideSubscriptions = <String>{};

  WsTransport? _transport;
  // Cancelled in _teardown() on every close/stop.
  // ignore: cancel_subscriptions
  StreamSubscription<Object?>? _transportSub;
  Timer? _pingTimer;
  Timer? _pongTimer;
  Timer? _authTimer;
  Timer? _reconnectTimer;
  bool _running = false;
  bool _forceRefresh = false;
  int _failedAttempts = 0;
  int _generation = 0;
  WsConnectionState _state = WsConnectionState.disconnected;

  Stream<WsEvent> get events => _events.stream;
  Stream<WsConnectionState> get states => _states.stream;
  WsConnectionState get state => _state;
  bool get isConnected => _state == WsConnectionState.connected;

  /// Builds `ws(s)://host/ws` from the REST base URL.
  static Uri urlFromApiBase(String apiBaseUrl) {
    final base = Uri.parse(apiBaseUrl);
    final path = base.path.endsWith('/') ? '${base.path}ws' : '${base.path}/ws';
    return base.replace(scheme: base.scheme == 'https' ? 'wss' : 'ws', path: path);
  }

  /// Starts connecting (idempotent).
  void start() {
    if (_running) return;
    _running = true;
    _failedAttempts = 0;
    unawaited(_open());
  }

  /// Closes the connection and stops reconnecting.
  Future<void> stop() async {
    _running = false;
    _reconnectTimer?.cancel();
    _generation++; // late callbacks from the old connection are ignored
    _teardown();
    _setState(WsConnectionState.disconnected);
  }

  Future<void> dispose() async {
    await stop();
    await _events.close();
    await _states.close();
  }

  /// Follows a ride (passenger or its driver). Kept across reconnects.
  void subscribeRide(String rideId) {
    if (_rideSubscriptions.add(rideId) && isConnected) {
      _sendJson({'type': 'subscribe', 'ride_id': rideId});
    }
  }

  void unsubscribeRide(String rideId) {
    if (_rideSubscriptions.remove(rideId) && isConnected) {
      _sendJson({'type': 'unsubscribe', 'ride_id': rideId});
    }
  }

  Set<String> get subscribedRides => Set.unmodifiable(_rideSubscriptions);

  /// Sends an app message (e.g. `driver.location`). Returns false when not connected —
  /// such messages are not queued (a stale position is worse than none).
  bool send(Map<String, Object?> message) {
    if (!isConnected) return false;
    _sendJson(message);
    return true;
  }

  Future<void> _open() async {
    final generation = ++_generation;
    _setState(WsConnectionState.connecting);
    final String token;
    try {
      token = await _tokenProvider(forceRefresh: _forceRefresh);
      _forceRefresh = false;
    } on SessionExpiredException {
      _running = false;
      _setState(WsConnectionState.disconnected);
      return;
    } on Object {
      _scheduleReconnect(generation);
      return;
    }
    if (!_running || generation != _generation) return;

    final transport = _connect(url);
    _transport = transport;
    _transportSub = transport.messages.listen(
      (message) => _onMessage(generation, message),
      onError: (Object _) => _onClosed(generation),
      onDone: () => _onClosed(generation),
    );
    try {
      await transport.ready;
    } on Object {
      _onClosed(generation);
      return;
    }
    if (generation != _generation) return;
    _sendJson({'type': 'auth', 'token': token});
    _authTimer = Timer(authTimeout, () => _onClosed(generation));
  }

  void _onMessage(int generation, Object? raw) {
    if (generation != _generation || raw is! String) return;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return;
    }
    if (decoded is! Map<String, Object?>) return;
    switch (decoded['type']) {
      case 'auth_ok':
        _authTimer?.cancel();
        _failedAttempts = 0;
        _setState(WsConnectionState.connected);
        for (final rideId in _rideSubscriptions) {
          _sendJson({'type': 'subscribe', 'ride_id': rideId});
        }
        _pingTimer = Timer.periodic(pingInterval, (_) => _ping(generation));
      case 'pong':
        _pongTimer?.cancel();
      case 'subscribed':
        break;
      case 'token_expired':
        // The server closes the socket right after; reconnect with a fresh token, no delay.
        _forceRefresh = true;
        _failedAttempts = 0;
      default:
        final event = WsEvent.fromJson(decoded);
        if (event is WsError && event.code == 'unauthorized') _forceRefresh = true;
        _events.add(event);
    }
  }

  void _ping(int generation) {
    if (generation != _generation) return;
    _sendJson({'type': 'ping'});
    _pongTimer?.cancel();
    _pongTimer = Timer(pongTimeout, () => _onClosed(generation));
  }

  void _onClosed(int generation) {
    if (generation != _generation) return;
    _generation++; // ignore late frames/callbacks from this connection
    _teardown();
    if (_running) _scheduleReconnect(_generation);
  }

  void _scheduleReconnect(int generation) {
    if (!_running) return;
    final delay = _forceRefresh && _failedAttempts == 0
        ? Duration.zero
        : backoff[_failedAttempts.clamp(0, backoff.length - 1)];
    _failedAttempts++;
    _setState(WsConnectionState.waitingToReconnect);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_running) unawaited(_open());
    });
  }

  /// Detaches and closes the current connection without waiting for the network.
  void _teardown() {
    _pingTimer?.cancel();
    _pongTimer?.cancel();
    _authTimer?.cancel();
    final sub = _transportSub;
    final transport = _transport;
    _transportSub = null;
    _transport = null;
    unawaited(sub?.cancel());
    if (transport != null) {
      unawaited(transport.close().catchError((Object _) {}));
    }
  }

  void _sendJson(Map<String, Object?> message) => _transport?.send(jsonEncode(message));

  void _setState(WsConnectionState next) {
    if (_state == next) return;
    _state = next;
    if (!_states.isClosed) _states.add(next);
  }
}
