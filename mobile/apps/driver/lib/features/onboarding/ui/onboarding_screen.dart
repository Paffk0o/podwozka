import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../data/document_picker.dart';
import '../providers/onboarding_controller.dart';

/// Driver application: vehicle + region → four document photos → submit → status.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wniosek kierowcy'),
        actions: [
          IconButton(
            tooltip: 'Wyloguj',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: switch (onboarding) {
        AsyncData(:final value) => _Body(state: value),
        AsyncError(:final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(apiErrorMessage(error), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(onboardingProvider),
                  child: const Text('Spróbuj ponownie'),
                ),
              ],
            ),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final OnboardingState state;

  Future<void> _run(BuildContext context, Future<void> Function() action, {String? done}) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      if (done != null) messenger.showSnackBar(SnackBar(content: Text(done)));
    } on Object catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = state.profile;
    final status = applicationStatusText(profile);
    final editable = isEditable(profile);
    final controller = ref.read(onboardingProvider.notifier);
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: controller.refreshStatus,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card.filled(
            child: ListTile(
              leading: Icon(switch (profile?.status) {
                DriverStatus.pending => Icons.hourglass_top,
                DriverStatus.rejected => Icons.error_outline,
                DriverStatus.suspended => Icons.block,
                DriverStatus.approved => Icons.verified,
                _ => Icons.badge_outlined,
              }),
              title: Text(status.title, style: theme.textTheme.titleMedium),
              subtitle: Text(status.body),
            ),
          ),
          const SizedBox(height: 16),
          _VehicleForm(
            profile: profile,
            enabled: editable && !state.saving,
            onSave: (regionId, vehicle) => _run(
              context,
              () => controller.saveApplication(regionId: regionId, vehicle: vehicle),
              done: 'Zapisano dane auta i gminę.',
            ),
          ),
          const SizedBox(height: 24),
          Text('Dokumenty', style: theme.textTheme.titleMedium),
          if (profile == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Najpierw zapisz dane auta — potem dodasz zdjęcia dokumentów.'),
            ),
          for (final type in requiredDocuments)
            _DocumentTile(
              type: type,
              document: latestDocuments(profile)[type],
              upload: state.uploads[type],
              enabled: profile != null && editable,
              onPick: (source) => _run(context, () => controller.addDocument(type, source)),
            ),
          const SizedBox(height: 24),
          if (editable)
            FilledButton(
              onPressed: canSubmit(profile) && !state.saving
                  ? () => _run(context, controller.submit, done: 'Wniosek wysłany do weryfikacji.')
                  : null,
              child: const Text('Wyślij wniosek'),
            )
          else
            OutlinedButton.icon(
              onPressed: () => _run(context, controller.refreshStatus),
              icon: const Icon(Icons.refresh),
              label: const Text('Sprawdź status'),
            ),
          if (editable && profile != null && missingDocuments(profile).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Brakuje: ${missingDocuments(profile).map(documentLabel).join(', ')}.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _VehicleForm extends ConsumerStatefulWidget {
  const _VehicleForm({required this.profile, required this.enabled, required this.onSave});

  final DriverProfile? profile;
  final bool enabled;
  final Future<void> Function(String regionId, Vehicle vehicle) onSave;

  @override
  ConsumerState<_VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends ConsumerState<_VehicleForm> {
  final _formKey = GlobalKey<FormState>();
  late final _make = TextEditingController(text: widget.profile?.vehicle.make);
  late final _model = TextEditingController(text: widget.profile?.vehicle.model);
  late final _color = TextEditingController(text: widget.profile?.vehicle.color);
  late final _plate = TextEditingController(text: widget.profile?.vehicle.plate);
  late int _seats = widget.profile?.vehicle.seats ?? 4;
  late String? _regionId = widget.profile?.regionId;

  @override
  void dispose() {
    for (final c in [_make, _model, _color, _plate]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.onSave(
      _regionId!,
      Vehicle(
        make: _make.text.trim(),
        model: _model.text.trim(),
        color: _color.text.trim(),
        plate: normalizePlate(_plate.text),
        seats: _seats,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regions = ref.watch(regionsProvider);
    final enabled = widget.enabled;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _regionId,
            decoration: const InputDecoration(labelText: 'Gmina, w której jeździsz'),
            items: [
              for (final region in regions.value ?? const <Region>[])
                DropdownMenuItem(value: region.id, child: Text(region.name)),
            ],
            onChanged: enabled ? (value) => setState(() => _regionId = value) : null,
            validator: (value) => value == null ? 'Wybierz gminę.' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _make,
                  enabled: enabled,
                  decoration: const InputDecoration(labelText: 'Marka', hintText: 'Skoda'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => requiredText(v, 'markę'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _model,
                  enabled: enabled,
                  decoration: const InputDecoration(labelText: 'Model', hintText: 'Octavia'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => requiredText(v, 'model'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _color,
                  enabled: enabled,
                  decoration: const InputDecoration(labelText: 'Kolor', hintText: 'szary'),
                  validator: (v) => requiredText(v, 'kolor'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _plate,
                  enabled: enabled,
                  decoration: const InputDecoration(
                    labelText: 'Nr rejestracyjny',
                    hintText: 'KWI 12345',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: validatePlate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _seats,
            decoration: const InputDecoration(labelText: 'Miejsca dla pasażerów'),
            items: [for (var n = 1; n <= 8; n++) DropdownMenuItem(value: n, child: Text('$n'))],
            onChanged: enabled ? (value) => setState(() => _seats = value ?? 4) : null,
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: _save,
              child: Text(
                widget.profile == null ? 'Zapisz i przejdź do dokumentów' : 'Zapisz zmiany',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.type,
    required this.document,
    required this.upload,
    required this.enabled,
    required this.onPick,
  });

  final DocumentType type;
  final DriverDocument? document;
  final DocumentUpload? upload;
  final bool enabled;
  final void Function(PickSource source) onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upload = this.upload;
    final doc = document;
    final (icon, color, status) = switch (doc?.status) {
      _ when upload != null && upload.inProgress => (
        Icons.cloud_upload,
        theme.colorScheme.primary,
        'Wysyłanie…',
      ),
      _ when upload?.error != null => (Icons.error, theme.colorScheme.error, upload!.error!),
      DocumentStatus.accepted => (Icons.verified, Colors.green.shade700, 'Zaakceptowany'),
      DocumentStatus.uploaded => (Icons.check_circle, Colors.green.shade700, 'Dodany'),
      DocumentStatus.rejected => (
        Icons.error,
        theme.colorScheme.error,
        'Odrzucony${doc?.reviewComment == null ? '' : ': ${doc!.reviewComment}'} — dodaj ponownie',
      ),
      _ => (Icons.radio_button_unchecked, theme.colorScheme.outline, documentHint(type)),
    };
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color),
          title: Text(documentLabel(type)),
          subtitle: Text(status),
          trailing: enabled && !(upload?.inProgress ?? false)
              ? PopupMenuButton<PickSource>(
                  tooltip: 'Dodaj zdjęcie: ${documentLabel(type)}',
                  icon: Icon(isDocumentDone(doc) ? Icons.replay : Icons.add_a_photo),
                  onSelected: onPick,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: PickSource.camera, child: Text('Zrób zdjęcie')),
                    PopupMenuItem(value: PickSource.gallery, child: Text('Wybierz z galerii')),
                  ],
                )
              : null,
        ),
        if (upload != null && upload.inProgress) LinearProgressIndicator(value: upload.progress),
      ],
    );
  }
}
