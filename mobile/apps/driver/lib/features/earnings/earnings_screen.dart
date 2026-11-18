import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../board/board_repository.dart';

enum EarningsPeriod { today, week, month }

String periodLabel(EarningsPeriod p) => switch (p) {
  EarningsPeriod.today => 'Dziś',
  EarningsPeriod.week => '7 dni',
  EarningsPeriod.month => 'Ten miesiąc',
};

/// Inclusive calendar days for the API (`date_from`, `date_to`).
({DateTime from, DateTime to}) periodRange(EarningsPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  return switch (period) {
    EarningsPeriod.today => (from: today, to: today),
    EarningsPeriod.week => (from: today.subtract(const Duration(days: 6)), to: today),
    EarningsPeriod.month => (from: DateTime(now.year, now.month), to: today),
  };
}

final earningsPeriodProvider = NotifierProvider<EarningsPeriodController, EarningsPeriod>(
  EarningsPeriodController.new,
);

class EarningsPeriodController extends Notifier<EarningsPeriod> {
  @override
  EarningsPeriod build() => EarningsPeriod.today;

  // ignore: use_setters_to_change_properties
  void select(EarningsPeriod period) => state = period;
}

final earningsProvider = FutureProvider.autoDispose<EarningsSummary>((ref) {
  final range = periodRange(ref.watch(earningsPeriodProvider), DateTime.now());
  return ref.watch(driverRecordsRepositoryProvider).earnings(from: range.from, to: range.to);
});

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(earningsPeriodProvider);
    final earnings = ref.watch(earningsProvider);
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(earningsProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<EarningsPeriod>(
            segments: [
              for (final p in EarningsPeriod.values)
                ButtonSegment(value: p, label: Text(periodLabel(p))),
            ],
            selected: {period},
            onSelectionChanged: (s) => ref.read(earningsPeriodProvider.notifier).select(s.first),
          ),
          const SizedBox(height: 16),
          switch (earnings) {
            AsyncData(:final value) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card.filled(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Na rękę', style: theme.textTheme.labelLarge),
                        Text(formatMoney(value.net), style: theme.textTheme.displaySmall),
                        Text('${value.ridesCount} ${ridesWord(value.ridesCount)}'),
                      ],
                    ),
                  ),
                ),
                _Row('Wartość kursów (brutto)', formatMoney(value.gross)),
                _Row('Prowizja Podwózki', '− ${formatMoney(value.commission)}'),
                _Row('Pobrana gotówka', formatMoney(value.cashCollected)),
                if (value.commissionDueFromCash > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Prowizja do rozliczenia z gotówki: ${formatMoney(value.commissionDueFromCash)} — '
                      'gminny operator rozliczy ją z Tobą osobno.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                const Divider(height: 32),
                for (final entry in value.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(formatDateTime(entry.completedAt)),
                    subtitle: Text(
                      entry.paymentMethod == PaymentMethod.cash ? 'gotówka' : 'online',
                    ),
                    trailing: Text(formatMoney(entry.net)),
                  ),
                if (value.items.isEmpty)
                  const Text(
                    'Brak zakończonych kursów w tym okresie.',
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
            AsyncError(:final error) => Text(apiErrorMessage(error), textAlign: TextAlign.center),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ],
      ),
    );
  }
}

/// 1 kurs, 2–4 kursy, 5 kursów (and 12–14 kursów, 22 kursy).
String ridesWord(int n) {
  if (n == 1) return 'kurs';
  final lastTwo = n % 100;
  final last = n % 10;
  if (last >= 2 && last <= 4 && (lastTwo < 12 || lastTwo > 14)) return 'kursy';
  return 'kursów';
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(value),
      ],
    ),
  );
}
