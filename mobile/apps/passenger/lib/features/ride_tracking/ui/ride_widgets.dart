import 'package:flutter/material.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';
import 'package:url_launcher/url_launcher.dart';

/// Driver, car and a call button.
class DriverCard extends StatelessWidget {
  const DriverCard({required this.driver, super.key});

  final RideDriverInfo driver;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vehicle = driver.vehicle;
    final rating = driver.ratingAvg;
    final phone = driver.phone;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(driver.fullName),
      subtitle: Text(
        '${vehicle.color} ${vehicle.make} ${vehicle.model}\n'
        '${rating == null ? 'Nowy kierowca' : '★ ${rating.toStringAsFixed(1).replaceAll('.', ',')}'}',
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(vehicle.plate, style: theme.textTheme.titleSmall),
          ),
          if (phone != null)
            IconButton(
              tooltip: 'Zadzwoń do kierowcy',
              icon: const Icon(Icons.phone),
              onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone)),
            ),
        ],
      ),
    );
  }
}

/// From → to, price and payment.
class RideRouteSummary extends StatelessWidget {
  const RideRouteSummary({required this.ride, super.key});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Line(icon: Icons.trip_origin, color: theme.colorScheme.primary, text: ride.pickup.address),
        _Line(icon: Icons.place, color: theme.colorScheme.error, text: ride.destination.address),
        const SizedBox(height: 8),
        Text(
          '${formatMoney(ride.price)} · ${paymentLabel(ride.paymentMethod)} · '
          '${formatDistance(ride.distanceM)}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}

String paymentLabel(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => 'gotówka',
  PaymentMethod.card => 'karta',
  PaymentMethod.blik => 'BLIK',
};

String rideStatusLabel(RideStatus status) => switch (status) {
  RideStatus.requested || RideStatus.dispatching => 'Szukamy kierowcy',
  RideStatus.scheduled => 'Rezerwacja',
  RideStatus.accepted => 'Kierowca przypisany',
  RideStatus.driverArriving => 'Kierowca w drodze',
  RideStatus.arrived => 'Kierowca na miejscu',
  RideStatus.inProgress => 'W trakcie',
  RideStatus.completed => 'Zakończony',
  RideStatus.cancelledByPassenger => 'Anulowany przez Ciebie',
  RideStatus.cancelledByDriver => 'Anulowany przez kierowcę',
  RideStatus.noDriver => 'Brak kierowcy',
};

/// Asks for confirmation and an optional reason. Returns null when the user keeps the ride.
Future<String?> confirmCancel(BuildContext context) => showDialog<String>(
  context: context,
  builder: (context) {
    const reasons = [
      'Zmiana planów',
      'Za długi czas oczekiwania',
      'Pomyłka przy zamawianiu',
      'Inny powód',
    ];
    return SimpleDialog(
      title: const Text('Anulować przejazd?'),
      children: [
        for (final reason in reasons)
          SimpleDialogOption(onPressed: () => Navigator.pop(context, reason), child: Text(reason)),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context),
          child: Text('Nie anuluj', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  },
);

/// 1–5 stars, tappable.
class StarRating extends StatelessWidget {
  const StarRating({required this.value, required this.onChanged, super.key});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var star = 1; star <= 5; star++)
        IconButton(
          tooltip: '$star/5',
          iconSize: 40,
          icon: Icon(star <= value ? Icons.star_rounded : Icons.star_outline_rounded),
          color: Colors.amber.shade700,
          onPressed: () => onChanged(star),
        ),
    ],
  );
}
