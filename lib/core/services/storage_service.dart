import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for uploading pet profile photos to Supabase Storage.
class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;

  final _client = Supabase.instance.client;
  static const _bucket = 'pet-photos';

  /// Upload a pet photo and return the public URL.
  ///
  /// The file is stored at `{userId}/{petId}_{timestamp}.{ext}`.
  Future<String> uploadPetPhoto({
    required String petId,
    required File file,
  }) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    return _uploadBytes(petId: petId, bytes: bytes, ext: ext);
  }

  /// Upload a pet photo from raw bytes and return the public URL.
  Future<String> uploadPetPhotoBytes({
    required String petId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';
    return _uploadBytes(petId: petId, bytes: bytes, ext: ext);
  }

  Future<String> _uploadBytes({
    required String petId,
    required Uint8List bytes,
    required String ext,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/${petId}_$timestamp.$ext';

    final tempFile = File(
      '${Directory.systemTemp.path}/pet_upload_$timestamp.$ext',
    );
    try {
      await tempFile.writeAsBytes(bytes);
      await _client.storage.from(_bucket).upload(path, tempFile);
      return _client.storage.from(_bucket).getPublicUrl(path);
    } finally {
      try {
        if (tempFile.existsSync()) tempFile.deleteSync();
      } catch (_) {}
    }
  }

  /// Upload a vaccine certificate photo and return the public URL.
  ///
  /// The file is stored at `{userId}/vaccines/{vaccineId}_{timestamp}.{ext}`.
  Future<String> uploadVaccineCertificate({
    required String vaccineId,
    required File file,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/vaccines/${vaccineId}_$timestamp.$ext';

    await _client.storage.from(_bucket).upload(path, file);
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  /// Delete a file from storage given its public URL.
  Future<void> deletePhoto(String photoUrl) async {
    final path = _extractPath(photoUrl);
    if (path == null) return;

    try {
      await _client.storage.from(_bucket).remove([path]);
    } catch (e) {
      // Silently ignore errors when deleting non-existent files
    }
  }

  /// Extract the storage path from a public URL.
  String? _extractPath(String url) {
    try {
      // The URL format is: .../storage/v1/object/public/pet-photos/{path}
      final prefix = 'pet-photos/';
      final index = url.indexOf(prefix);
      if (index == -1) return null;
      return url.substring(index + prefix.length);
    } catch (_) {
      return null;
    }
  }
}
