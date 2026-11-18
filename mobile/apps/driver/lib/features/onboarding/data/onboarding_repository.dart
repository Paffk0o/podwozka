import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:podwozka_api/podwozka_api.dart';
import 'package:podwozka_core/podwozka_core.dart';

/// Driver application API (vehicle, region, documents). Behind an interface for tests.
abstract interface class OnboardingRepository {
  /// My driver profile, or null when no application was started yet (404).
  Future<DriverProfile?> myProfile();
  Future<List<Region>> regions();
  Future<DriverProfile> saveApplication({required String regionId, required Vehicle vehicle});

  /// Asks the API for a one-time SAS link, uploads the file straight to Blob Storage
  /// and confirms the upload. Reports upload progress 0..1.
  Future<DriverDocument> uploadDocument({
    required DocumentType type,
    required Uint8List bytes,
    required String contentType,
    void Function(double progress)? onProgress,
  });
  Future<DriverProfile> submit();
}

class ApiOnboardingRepository implements OnboardingRepository {
  ApiOnboardingRepository(this._api, {Dio? blobDio}) : _blobDio = blobDio ?? Dio();

  final PodwozkaApi _api;

  /// Plain Dio for Blob Storage: the SAS link is the only credential — the API token
  /// must never be sent to the storage account.
  final Dio _blobDio;

  @override
  Future<DriverProfile?> myProfile() async {
    try {
      return (await _api.getDriverApi().getMyDriverProfile()).data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Region>> regions() async =>
      ((await _api.getRegionsApi().listRegions()).data ?? const []).where((r) => r.active).toList();

  @override
  Future<DriverProfile> saveApplication({
    required String regionId,
    required Vehicle vehicle,
  }) async => (await _api.getDriverApi().upsertDriverApplication(
    driverApplicationUpsert: DriverApplicationUpsert(regionId: regionId, vehicle: vehicle),
  )).data!;

  @override
  Future<DriverDocument> uploadDocument({
    required DocumentType type,
    required Uint8List bytes,
    required String contentType,
    void Function(double progress)? onProgress,
  }) async {
    final driver = _api.getDriverApi();
    final slot = (await driver.createDocumentUpload(
      documentUploadRequest: DocumentUploadRequest(
        type: type,
        contentType: contentType,
        sizeBytes: bytes.length,
      ),
    )).data!;
    await _blobDio.put<void>(
      slot.uploadUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        // required_headers already carry x-ms-blob-type and Content-Type.
        headers: {...slot.requiredHeaders, Headers.contentLengthHeader: bytes.length},
      ),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress?.call(sent / total);
      },
    );
    return (await driver.completeDocumentUpload(documentId: slot.documentId)).data!;
  }

  @override
  Future<DriverProfile> submit() async =>
      (await _api.getDriverApi().submitDriverApplication()).data!;
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => ApiOnboardingRepository(ref.watch(podwozkaApiProvider)),
);
