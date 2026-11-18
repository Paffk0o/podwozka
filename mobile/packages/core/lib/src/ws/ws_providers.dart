import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'ws_client.dart';
import 'ws_events.dart';

/// How sockets are opened — overridden in tests with a fake transport.
final wsConnectProvider = Provider<WsConnect>((ref) => connectWebSocket);

/// The app's single `/ws` connection. Connected while the user is signed in;
/// rebuilt (old one closed) on login/logout.
final podwozkaSocketProvider = Provider<PodwozkaSocket>((ref) {
  final config = ref.watch(appConfigProvider);
  final auth = ref.watch(authServiceProvider);
  final signedIn = ref.watch(authControllerProvider.select((a) => a.value != null));
  final socket = PodwozkaSocket(
    url: PodwozkaSocket.urlFromApiBase(config.apiBaseUrl),
    tokenProvider: ({bool forceRefresh = false}) =>
        auth.validAccessToken(forceRefresh: forceRefresh),
    connect: ref.watch(wsConnectProvider),
  );
  if (signedIn) socket.start();
  ref.onDispose(socket.dispose);
  return socket;
});

/// All server events (ride status, driver position, offers, notifications).
final wsEventsProvider = StreamProvider<WsEvent>((ref) => ref.watch(podwozkaSocketProvider).events);

/// Connection state — UI can show „Łączenie…” and refresh REST state on `connected`.
final wsConnectionStateProvider = StreamProvider<WsConnectionState>((ref) async* {
  final socket = ref.watch(podwozkaSocketProvider);
  yield socket.state;
  yield* socket.states;
});
