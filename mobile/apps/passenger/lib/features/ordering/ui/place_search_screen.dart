import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../providers/place_search.dart';

/// Full-screen address search. Pops with the chosen [Place] (or null).
class PlaceSearchScreen extends ConsumerStatefulWidget {
  const PlaceSearchScreen({required this.title, this.onUseMyLocation, super.key});

  final String title;

  /// Shown as the first option when choosing the pickup.
  final VoidCallback? onUseMyLocation;

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen> {
  final _query = TextEditingController();
  bool _resolving = false;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _choose(PlaceSuggestion suggestion) async {
    setState(() {
      _resolving = true;
      _error = null;
    });
    try {
      final place = await ref.read(placeSearchProvider.notifier).choose(suggestion);
      if (mounted) Navigator.of(context).pop(place);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _resolving = false;
          _error = apiErrorMessage(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final search = ref.watch(placeSearchProvider);
    final error = _error ?? search.error;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          decoration: InputDecoration(
            hintText: widget.title,
            border: InputBorder.none,
            filled: false,
          ),
          textInputAction: TextInputAction.search,
          onChanged: ref.read(placeSearchProvider.notifier).onQueryChanged,
        ),
        // Always present (only hidden): changing the AppBar structure would rebuild the field.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Visibility.maintain(
            visible: search.loading || _resolving,
            child: const LinearProgressIndicator(),
          ),
        ),
      ),
      body: ListView(
        children: [
          if (widget.onUseMyLocation != null)
            ListTile(
              leading: const Icon(Icons.my_location),
              title: const Text('Moja obecna lokalizacja'),
              onTap: () {
                widget.onUseMyLocation!();
                Navigator.of(context).pop();
              },
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          if (search.tooShort && search.query.isNotEmpty)
            const Padding(padding: EdgeInsets.all(16), child: Text('Wpisz co najmniej 3 znaki.')),
          if (!search.tooShort && !search.loading && search.results.isEmpty && error == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nic nie znaleźliśmy. Spróbuj wpisać miejscowość i ulicę.'),
            ),
          for (final suggestion in search.results)
            ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(suggestion.primaryText),
              subtitle: suggestion.secondaryText == null ? null : Text(suggestion.secondaryText!),
              enabled: !_resolving,
              onTap: () => _choose(suggestion),
            ),
        ],
      ),
    );
  }
}
