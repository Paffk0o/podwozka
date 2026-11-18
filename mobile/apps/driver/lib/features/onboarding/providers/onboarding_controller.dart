import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

import '../data/document_picker.dart';
import '../data/onboarding_repository.dart';

/// Documents in the order the driver is asked for them.
const requiredDocuments = [
  DocumentType.drivingLicense,
  DocumentType.vehicleRegistration,
  DocumentType.insuranceOc,
  DocumentType.driverPhoto,
];

String documentLabel(DocumentType type) => switch (type) {
  DocumentType.drivingLicense => 'Prawo jazdy',
  DocumentType.vehicleRegistration => 'Dowód rejestracyjny',
  DocumentType.insuranceOc => 'Polisa OC',
  DocumentType.driverPhoto => 'Twoje zdjęcie',
};

String documentHint(DocumentType type) => switch (type) {
  DocumentType.drivingLicense => 'Zdjęcie przedniej strony, wszystkie dane czytelne.',
  DocumentType.vehicleRegistration => 'Strona z numerem rejestracyjnym i danymi właściciela.',
  DocumentType.insuranceOc => 'Aktualna polisa z widoczną datą ważności.',
  DocumentType.driverPhoto => 'Zdjęcie twarzy na jasnym tle — zobaczy je pasażer.',
};

/// The newest document of each type (a re-upload replaces the previous one).
Map<DocumentType, DriverDocument> latestDocuments(DriverProfile? profile) {
  final result = <DocumentType, DriverDocument>{};
  for (final doc in profile?.documents ?? const <DriverDocument>[]) {
    final current = result[doc.type];
    final docAt = doc.uploadedAt;
    final currentAt = current?.uploadedAt;
    if (current == null || (docAt != null && (currentAt == null || docAt.isAfter(currentAt)))) {
      result[doc.type] = doc;
    }
  }
  return result;
}

bool isDocumentDone(DriverDocument? doc) =>
    doc != null && (doc.status == DocumentStatus.uploaded || doc.status == DocumentStatus.accepted);

List<DocumentType> missingDocuments(DriverProfile? profile) {
  final latest = latestDocuments(profile);
  return requiredDocuments.where((t) => !isDocumentDone(latest[t])).toList();
}

bool isEditable(DriverProfile? profile) =>
    profile == null ||
    profile.status == DriverStatus.draft ||
    profile.status == DriverStatus.rejected;

/// Region and vehicle saved, all four documents uploaded, application still editable.
bool canSubmit(DriverProfile? profile) =>
    profile != null && isEditable(profile) && missingDocuments(profile).isEmpty;

/// Polish plates: 2–3 letters (county), then 4–5 letters/digits, e.g. „KWI 12345”.
String? validatePlate(String? value) {
  final plate = normalizePlate(value ?? '');
  if (plate.isEmpty) return 'Podaj numer rejestracyjny.';
  if (!RegExp(r'^[A-Z]{1,3}[A-Z0-9]{3,6}$').hasMatch(plate)) {
    return 'Wpisz numer jak w dowodzie rejestracyjnym, np. KWI 12345.';
  }
  return null;
}

String normalizePlate(String value) => value.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');

String? requiredText(String? value, String what) =>
    (value?.trim().isEmpty ?? true) ? 'Podaj $what.' : null;

/// Status card text for the driver.
({String title, String body}) applicationStatusText(DriverProfile? profile) =>
    switch (profile?.status) {
      null || DriverStatus.draft => (
        title: 'Zostań kierowcą',
        body: 'Uzupełnij dane auta, wybierz gminę i dodaj zdjęcia czterech dokumentów. Sprawdzimy je zwykle w ciągu jednego dnia roboczego.',
      ),
      DriverStatus.pending => (
        title: 'Wniosek w weryfikacji',
        body: 'Sprawdzamy Twoje dokumenty. Damy znać, gdy wniosek zostanie rozpatrzony.',
      ),
      DriverStatus.rejected => (
        title: 'Wniosek wymaga poprawek',
        body: profile?.rejectionReason == null
            ? 'Popraw dane lub dokumenty i wyślij wniosek ponownie.'
            : 'Powód: ${profile!.rejectionReason}. Popraw i wyślij ponownie.',
      ),
      DriverStatus.approved => (
        title: 'Konto kierowcy aktywne',
        body: 'Możesz zacząć przyjmować kursy.',
      ),
      DriverStatus.suspended => (
        title: 'Konto zawieszone',
        body: 'Skontaktuj się z administratorem gminy, aby wyjaśnić sprawę.',
      ),
    };

/// Upload state of one document on this device (before the API confirms it).
class DocumentUpload {
  const DocumentUpload({this.progress = 0, this.error});

  final double progress;
  final String? error;
  bool get inProgress => error == null;
}

class OnboardingState {
  const OnboardingState({required this.profile, this.uploads = const {}, this.saving = false});

  final DriverProfile? profile;
  final Map<DocumentType, DocumentUpload> uploads;
  final bool saving;

  OnboardingState copyWith({
    DriverProfile? profile,
    Map<DocumentType, DocumentUpload>? uploads,
    bool? saving,
  }) => OnboardingState(
    profile: profile ?? this.profile,
    uploads: uploads ?? this.uploads,
    saving: saving ?? this.saving,
  );
}

class OnboardingController extends AsyncNotifier<OnboardingState> {
  OnboardingRepository get _repo => ref.read(onboardingRepositoryProvider);

  @override
  Future<OnboardingState> build() async =>
      OnboardingState(profile: await ref.watch(onboardingRepositoryProvider).myProfile());

  OnboardingState get _current => state.requireValue;

  /// Saves region + vehicle (creates the draft application). Throws on API errors.
  Future<void> saveApplication({required String regionId, required Vehicle vehicle}) async {
    state = AsyncData(_current.copyWith(saving: true));
    try {
      final profile = await _repo.saveApplication(regionId: regionId, vehicle: vehicle);
      state = AsyncData(_current.copyWith(profile: profile, saving: false));
    } on Object {
      state = AsyncData(_current.copyWith(saving: false));
      rethrow;
    }
  }

  /// Picks a photo and uploads it. Returns false when the user cancelled the picker.
  Future<bool> addDocument(DocumentType type, PickSource source) async {
    final picked = await ref.read(documentPickerProvider).pick(source);
    if (picked == null) return false;
    _setUpload(type, const DocumentUpload());
    try {
      await _repo.uploadDocument(
        type: type,
        bytes: picked.bytes,
        contentType: picked.contentType,
        onProgress: (p) => _setUpload(type, DocumentUpload(progress: p)),
      );
      final profile = await _repo.myProfile();
      final uploads = {..._current.uploads}..remove(type);
      state = AsyncData(_current.copyWith(profile: profile, uploads: uploads));
    } on Object catch (e) {
      _setUpload(type, DocumentUpload(error: apiErrorMessage(e)));
    }
    return true;
  }

  Future<void> submit() async {
    state = AsyncData(_current.copyWith(saving: true));
    try {
      final profile = await _repo.submit();
      state = AsyncData(_current.copyWith(profile: profile, saving: false));
    } on Object {
      state = AsyncData(_current.copyWith(saving: false));
      rethrow;
    }
  }

  /// „Sprawdź status”. After approval the `driver` role is only in a NEW token, so it
  /// is refreshed — the app then switches to work mode.
  Future<void> refreshStatus() async {
    final profile = await _repo.myProfile();
    state = AsyncData(_current.copyWith(profile: profile));
    if (profile?.status == DriverStatus.approved) {
      await ref.read(authServiceProvider).validAccessToken(forceRefresh: true);
    }
  }

  void _setUpload(DocumentType type, DocumentUpload upload) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(uploads: {...current.uploads, type: upload}));
  }
}

final onboardingProvider = AsyncNotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);

final regionsProvider = FutureProvider<List<Region>>(
  (ref) => ref.watch(onboardingRepositoryProvider).regions(),
);
