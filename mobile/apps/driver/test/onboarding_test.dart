import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_driver/features/onboarding/data/document_picker.dart';
import 'package:podwozka_driver/features/onboarding/data/onboarding_repository.dart';
import 'package:podwozka_driver/features/onboarding/providers/onboarding_controller.dart';
import 'package:podwozka_driver/features/onboarding/ui/onboarding_screen.dart';

final _vehicle = Vehicle(make: 'Opel', model: 'Astra', color: 'czerwony', plate: 'KWI7A8B9');

DriverDocument doc(DocumentType type, DocumentStatus status, {int minute = 0, String? comment}) =>
    DriverDocument(
      id: '${type.value}-$minute',
      type: type,
      status: status,
      contentType: 'image/jpeg',
      expiresOn: null,
      uploadedAt: DateTime.utc(2026, 11, 18, 10, minute),
      reviewComment: comment,
    );

DriverProfile profile({
  DriverStatus status = DriverStatus.draft,
  List<DriverDocument> documents = const [],
  String? reason,
}) => DriverProfile(
  userId: 'u1',
  status: status,
  regionId: 'wieliczka',
  vehicle: _vehicle,
  documents: documents,
  rejectionReason: reason,
  ratingAvg: null,
  online: false,
  approvedAt: null,
);

List<DriverDocument> allUploaded() => [
  for (final t in requiredDocuments) doc(t, DocumentStatus.uploaded),
];

class FakeOnboardingRepository implements OnboardingRepository {
  DriverProfile? current;
  final uploads = <(DocumentType, int, String)>[];
  Object? uploadError;
  int submits = 0;

  @override
  Future<DriverProfile?> myProfile() async => current;

  @override
  Future<List<Region>> regions() async => [
    Region(id: 'wieliczka', name: 'Gmina Wieliczka', teryt: null, active: true),
  ];

  @override
  Future<DriverProfile> saveApplication({
    required String regionId,
    required Vehicle vehicle,
  }) async => current = profile(documents: current?.documents ?? const []);

  @override
  Future<DriverDocument> uploadDocument({
    required DocumentType type,
    required Uint8List bytes,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    final error = uploadError;
    if (error != null) throw error;
    onProgress?.call(0.5);
    uploads.add((type, bytes.length, contentType));
    final uploaded = doc(type, DocumentStatus.uploaded, minute: uploads.length);
    current = profile(status: current!.status, documents: [...current!.documents, uploaded]);
    return uploaded;
  }

  @override
  Future<DriverProfile> submit() async {
    submits++;
    return current = profile(status: DriverStatus.pending, documents: current!.documents);
  }
}

class FakePicker implements DocumentPicker {
  PickedDocument? next = PickedDocument(bytes: Uint8List(1234), contentType: 'image/jpeg');

  @override
  Future<PickedDocument?> pick(PickSource source) async => next;
}

/// Records requests and answers like the API / Blob Storage.
class RecordingAdapter implements HttpClientAdapter {
  RecordingAdapter(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    await requestStream?.drain<void>();
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(Object body, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

void main() {
  group('application rules', () {
    test('a re-upload replaces the older document of the same type', () {
      final p = profile(
        documents: [
          doc(DocumentType.insuranceOc, DocumentStatus.rejected, minute: 1, comment: 'nieczytelne'),
          doc(DocumentType.insuranceOc, DocumentStatus.uploaded, minute: 5),
        ],
      );
      expect(latestDocuments(p)[DocumentType.insuranceOc]!.status, DocumentStatus.uploaded);
    });

    test('submit only with all four documents and an editable application', () {
      expect(canSubmit(null), isFalse);
      expect(canSubmit(profile(documents: allUploaded().take(3).toList())), isFalse);
      expect(missingDocuments(profile(documents: allUploaded().take(3).toList())), [
        DocumentType.driverPhoto,
      ]);
      expect(canSubmit(profile(documents: allUploaded())), isTrue);
      expect(canSubmit(profile(status: DriverStatus.pending, documents: allUploaded())), isFalse);
      // A rejected document has to be sent again.
      final rejected = [
        ...allUploaded().skip(1),
        doc(DocumentType.drivingLicense, DocumentStatus.rejected),
      ];
      expect(missingDocuments(profile(documents: rejected)), [DocumentType.drivingLicense]);
    });

    test('a rejected application can be corrected', () {
      expect(isEditable(profile(status: DriverStatus.rejected)), isTrue);
      expect(isEditable(profile(status: DriverStatus.approved)), isFalse);
      expect(
        applicationStatusText(profile(status: DriverStatus.rejected, reason: 'Nieważne OC')).body,
        contains('Nieważne OC'),
      );
    });

    test('plates are normalised and validated', () {
      expect(normalizePlate('kwi 7a8b9'), 'KWI7A8B9');
      expect(validatePlate('KR 12345'), isNull);
      expect(validatePlate('KWI-12345'), isNull);
      expect(validatePlate(''), 'Podaj numer rejestracyjny.');
      expect(validatePlate('12345'), isNotNull);
    });

    test('content type falls back to the file extension', () {
      expect(contentTypeFor('image/png', 'x'), 'image/png');
      expect(contentTypeFor(null, 'scan.PNG'), 'image/png');
      expect(contentTypeFor('application/octet-stream', 'photo'), 'image/jpeg');
    });
  });

  test(
    'upload goes straight to Blob Storage with the SAS headers and WITHOUT the API token',
    () async {
      final apiAdapter = RecordingAdapter((o) {
        if (o.path.endsWith('/drivers/me/documents')) {
          return json({
            'document_id': 'd1',
            'upload_url': 'http://localhost:10000/devstoreaccount1/driver-documents/d1?sig=abc',
            'required_headers': {'x-ms-blob-type': 'BlockBlob', 'Content-Type': 'image/jpeg'},
            'expires_at': '2026-11-18T10:15:00Z',
          }, status: 201);
        }
        return json({
          'id': 'd1',
          'type': 'driving_license',
          'status': 'uploaded',
          'content_type': 'image/jpeg',
          'expires_on': null,
          'uploaded_at': '2026-11-18T10:01:00Z',
          'review_comment': null,
        });
      });
      final apiDio = Dio(
        BaseOptions(baseUrl: 'http://api.test', headers: {'Authorization': 'Bearer secret'}),
      )..httpClientAdapter = apiAdapter;
      final blobAdapter = RecordingAdapter((_) => ResponseBody.fromString('', 201));
      final blobDio = Dio()..httpClientAdapter = blobAdapter;
      final repo = ApiOnboardingRepository(
        PodwozkaApi(dio: apiDio, interceptors: const []),
        blobDio: blobDio,
      );

      final result = await repo.uploadDocument(
        type: DocumentType.drivingLicense,
        bytes: Uint8List(2048),
        contentType: 'image/jpeg',
      );

      expect(result.status, DocumentStatus.uploaded);
      final requestBody = apiAdapter.requests.first.data;
      expect('$requestBody', contains('"size_bytes":2048'));
      final blob = blobAdapter.requests.single;
      expect(blob.method, 'PUT');
      expect(blob.uri.toString(), contains('sig=abc'));
      expect(blob.headers['x-ms-blob-type'], 'BlockBlob');
      expect(blob.headers.keys.map((k) => k.toLowerCase()), isNot(contains('authorization')));
      expect(apiAdapter.requests.last.path, endsWith('/drivers/me/documents/d1/complete'));
    },
  );

  group('OnboardingController', () {
    late FakeOnboardingRepository repo;
    late FakePicker picker;
    late ProviderContainer container;

    OnboardingState state() => container.read(onboardingProvider).requireValue;

    setUp(() async {
      repo = FakeOnboardingRepository();
      picker = FakePicker();
      container = ProviderContainer(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repo),
          documentPickerProvider.overrideWithValue(picker),
        ],
      );
      container.listen(onboardingProvider, (_, _) {});
      await container.read(onboardingProvider.future);
    });

    tearDown(() => container.dispose());

    test('full application: vehicle → four documents → submit', () async {
      expect(state().profile, isNull);
      await container
          .read(onboardingProvider.notifier)
          .saveApplication(regionId: 'wieliczka', vehicle: _vehicle);
      expect(state().profile!.status, DriverStatus.draft);

      for (final type in requiredDocuments) {
        expect(
          await container.read(onboardingProvider.notifier).addDocument(type, PickSource.gallery),
          isTrue,
        );
      }
      expect(repo.uploads.map((u) => u.$1), requiredDocuments);
      expect(canSubmit(state().profile), isTrue);

      await container.read(onboardingProvider.notifier).submit();
      expect(state().profile!.status, DriverStatus.pending);
    });

    test('cancelling the picker uploads nothing', () async {
      await container
          .read(onboardingProvider.notifier)
          .saveApplication(regionId: 'wieliczka', vehicle: _vehicle);
      picker.next = null;

      expect(
        await container
            .read(onboardingProvider.notifier)
            .addDocument(DocumentType.insuranceOc, PickSource.camera),
        isFalse,
      );
      expect(repo.uploads, isEmpty);
    });

    test('a failed upload is shown on that document only, in Polish', () async {
      await container
          .read(onboardingProvider.notifier)
          .saveApplication(regionId: 'wieliczka', vehicle: _vehicle);
      repo.uploadError = DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      );

      await container
          .read(onboardingProvider.notifier)
          .addDocument(DocumentType.insuranceOc, PickSource.camera);

      expect(state().uploads[DocumentType.insuranceOc]!.error, 'Brak połączenia z internetem.');
      expect(state().uploads.containsKey(DocumentType.drivingLicense), isFalse);
    });
  });

  testWidgets('screen: submit enabled only when complete; pending application is read-only', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final repo = FakeOnboardingRepository()
      ..current = profile(documents: allUploaded().take(3).toList());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(repo),
          documentPickerProvider.overrideWithValue(FakePicker()),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final submit = find.widgetWithText(FilledButton, 'Wyślij wniosek');
    await tester.scrollUntilVisible(submit, 200, scrollable: find.byType(Scrollable).first);
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);
    expect(find.text('Brakuje: Twoje zdjęcie.'), findsOneWidget);

    await tester.tap(find.byTooltip('Dodaj zdjęcie: Twoje zdjęcie'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zrób zdjęcie'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);

    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(repo.submits, 1);
    expect(find.text('Wniosek w weryfikacji'), findsOneWidget);
    expect(find.text('Sprawdź status'), findsOneWidget);
    expect(find.byTooltip('Dodaj zdjęcie: Prawo jazdy'), findsNothing);
  });
}
