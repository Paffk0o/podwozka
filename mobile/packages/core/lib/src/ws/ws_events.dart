/// Server → app events from `/ws` (docs/ws-protocol.md). Internal frames
/// (`auth_ok`, `pong`, `subscribed`, `token_expired`) are handled by `PodwozkaSocket`.
sealed class WsEvent {
  const WsEvent();

  /// Parses one decoded JSON frame. Unknown types become [WsUnknown] (forward compatibility).
  static WsEvent fromJson(Map<String, Object?> json) {
    final type = json['type'];
    return switch (type) {
      'ride.status' => RideStatusChanged(
        rideId: json['ride_id']! as String,
        status: json['status']! as String,
        at: _date(json['at']),
      ),
      'ride.driver_location' => DriverLocationChanged(
        rideId: json['ride_id']! as String,
        lat: _double((json['location']! as Map)['lat']),
        lng: _double((json['location']! as Map)['lng']),
        heading: _doubleOrNull(json['heading']),
        etaSeconds: (json['eta_s'] as num?)?.toInt(),
        at: _date(json['at']),
      ),
      'ride.driver_assigned' => DriverAssigned(rideId: json['ride_id']! as String),
      'ride.payment' => RidePaymentChanged(
        rideId: json['ride_id']! as String,
        paymentStatus: json['payment_status']! as String,
      ),
      'offer.new' => OfferReceived(
        offerId: json['offer_id']! as String,
        rideId: json['ride_id']! as String,
        expiresAt: _date(json['expires_at']),
      ),
      'offer.expired' => OfferExpired(offerId: json['offer_id']! as String),
      'board.updated' => BoardUpdated(regionId: json['region_id'] as String?),
      'notification' => NotificationReceived(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: (json['data'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
      'error' => WsError(
        code: json['code'] as String? ?? 'unknown',
        message: json['message'] as String?,
      ),
      _ => WsUnknown(type is String ? type : '?', json),
    };
  }
}

class RideStatusChanged extends WsEvent {
  const RideStatusChanged({required this.rideId, required this.status, this.at});
  final String rideId;

  /// Value of the API `RideStatus` enum, e.g. `driver_arriving`.
  final String status;
  final DateTime? at;
}

class DriverLocationChanged extends WsEvent {
  const DriverLocationChanged({
    required this.rideId,
    required this.lat,
    required this.lng,
    this.heading,
    this.etaSeconds,
    this.at,
  });
  final String rideId;
  final double lat;
  final double lng;
  final double? heading;
  final int? etaSeconds;
  final DateTime? at;
}

class DriverAssigned extends WsEvent {
  const DriverAssigned({required this.rideId});
  final String rideId;
}

class RidePaymentChanged extends WsEvent {
  const RidePaymentChanged({required this.rideId, required this.paymentStatus});
  final String rideId;
  final String paymentStatus;
}

class OfferReceived extends WsEvent {
  const OfferReceived({required this.offerId, required this.rideId, this.expiresAt});
  final String offerId;
  final String rideId;
  final DateTime? expiresAt;
}

class OfferExpired extends WsEvent {
  const OfferExpired({required this.offerId});
  final String offerId;
}

class BoardUpdated extends WsEvent {
  const BoardUpdated({this.regionId});
  final String? regionId;
}

class NotificationReceived extends WsEvent {
  const NotificationReceived({required this.title, required this.body, this.data = const {}});
  final String title;
  final String body;
  final Map<String, Object?> data;
}

class WsError extends WsEvent {
  const WsError({required this.code, this.message});
  final String code;
  final String? message;
}

class WsUnknown extends WsEvent {
  const WsUnknown(this.type, this.json);
  final String type;
  final Map<String, Object?> json;
}

DateTime? _date(Object? value) => value is String ? DateTime.tryParse(value) : null;
double _double(Object? value) => (value! as num).toDouble();
double? _doubleOrNull(Object? value) => value is num ? value.toDouble() : null;
