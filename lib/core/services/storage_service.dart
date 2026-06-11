import 'dart:io';
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
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$userId/${petId}_$timestamp.$ext';

    await _client.storage.from(_bucket).upload(path, file);

    // Return the public URL of the uploaded file
    return _client.storage.from(_bucket).getPublicUrl(path);
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
