import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupabaseStorageService {
  static final _supabase = Supabase.instance.client;
  static const String _bucketName = 'chat-images';

  /// Upload image to Supabase Storage and return public URL
  static Future<String> uploadImage(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique filename using timestamp and user ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${user.uid}_$timestamp.jpg';
      final filePath = 'chat_images/$fileName';

      // Upload file to Supabase Storage
      await _supabase.storage.from(_bucketName).upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete image from Supabase Storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the path after the bucket name
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1) {
        throw Exception('Invalid image URL');
      }
      
      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // Delete file from storage
      await _supabase.storage.from(_bucketName).remove([filePath]);
    } catch (e) {
      // Silently fail - image might already be deleted
      print('Failed to delete image: $e');
    }
  }

  /// Check if storage bucket exists and is accessible
  static Future<bool> checkBucketExists() async {
    try {
      final buckets = await _supabase.storage.listBuckets();
      return buckets.any((bucket) => bucket.name == _bucketName);
    } catch (e) {
      print('Failed to check bucket: $e');
      return false;
    }
  }
}
