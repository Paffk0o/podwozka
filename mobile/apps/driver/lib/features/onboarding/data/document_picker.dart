import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class PickedDocument {
  const PickedDocument({required this.bytes, required this.contentType});

  final Uint8List bytes;

  /// One of the types the API accepts (image/jpeg, image/png, image/heic).
  final String contentType;
}

enum PickSource { camera, gallery }

/// Photo of a document — behind an interface so tests need no plugin.
abstract interface class DocumentPicker {
  /// Null when the user backed out.
  Future<PickedDocument?> pick(PickSource source);
}

class ImagePickerDocumentPicker implements DocumentPicker {
  ImagePickerDocumentPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedDocument?> pick(PickSource source) async {
    final file = await _picker.pickImage(
      source: source == PickSource.camera ? ImageSource.camera : ImageSource.gallery,
      // Readable for the reviewer, well under the 10 MB limit, fast to upload on 3G.
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (file == null) return null;
    return PickedDocument(
      bytes: await file.readAsBytes(),
      contentType: contentTypeFor(file.mimeType, file.name),
    );
  }
}

/// Resized picks are re-encoded as JPEG on Android/iOS; fall back on the file name.
String contentTypeFor(String? mimeType, String name) {
  const allowed = {'image/jpeg', 'image/png', 'image/heic'};
  if (mimeType != null && allowed.contains(mimeType)) return mimeType;
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.heic')) return 'image/heic';
  return 'image/jpeg';
}

final documentPickerProvider = Provider<DocumentPicker>((ref) => ImagePickerDocumentPicker());
