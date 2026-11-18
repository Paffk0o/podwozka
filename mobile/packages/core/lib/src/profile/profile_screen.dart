import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_error.dart';
import '../api/me.dart';
import '../providers.dart';
import 'profile_validation.dart';

/// Shows [child] once the profile has a name and phone; otherwise the completion form.
/// Wrap the app's home screen with it.
class ProfileGate extends ConsumerWidget {
  const ProfileGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);
    return switch (me) {
      AsyncData(:final value) when isProfileComplete(value) => child,
      AsyncData(:final value) => ProfileFormScreen(
        initialName: value.fullName,
        initialPhone: value.phone,
      ),
      AsyncError(:final error) => _ProfileError(message: apiErrorMessage(error)),
      _ => const Scaffold(body: Center(child: CircularProgressIndicator())),
    };
  }
}

class _ProfileError extends ConsumerWidget {
  const _ProfileError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(meProvider),
              child: const Text('Spróbuj ponownie'),
            ),
            TextButton(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              child: const Text('Wyloguj'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// First-login form: full name and phone (normalised to +48…).
class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({this.initialName, this.initialPhone, super.key});

  final String? initialName;
  final String? initialPhone;

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  // The field shows a +48 prefix, so a stored Polish number is edited without it.
  late final _phone = TextEditingController(text: widget.initialPhone?.replaceFirst('+48', ''));
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(meProvider.notifier)
          .save(fullName: _name.text.trim(), phone: normalizePhone(_phone.text)!);
    } on Object catch (e) {
      if (mounted) setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uzupełnij profil'),
        actions: [
          IconButton(
            tooltip: 'Wyloguj',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Kierowca i pasażer widzą swoje imię i mogą do siebie zadzwonić. '
                'Podaj dane, których używasz na co dzień.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Imię i nazwisko'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: validateFullName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon',
                  hintText: '600 100 200',
                  prefixText: '+48 ',
                ),
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: validatePhone,
                onFieldSubmitted: (_) => _save(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Zapisz i przejdź dalej'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
