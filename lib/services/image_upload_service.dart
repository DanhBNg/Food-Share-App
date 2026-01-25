import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ImageUploadService {
  final _supabase = Supabase.instance.client;

  Future<String?> uploadPostImage({
    required Uint8List bytes,
    required String extension,
  }) async {
    try {
      final fileName = '${const Uuid().v4()}.$extension';

      await _supabase.storage
          .from('post-images')
          .uploadBinary(
        'public/$fileName',
        bytes,
        fileOptions: const FileOptions(
          upsert: false,
        ),
      );

      return _supabase.storage
          .from('post-images')
          .getPublicUrl('public/$fileName');
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }
}
