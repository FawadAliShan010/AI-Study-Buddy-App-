import 'dart:io';
import 'dart:typed_data'; // ✅ ADD THIS IMPORT
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  // ============ UPLOAD FILE (MOBILE) ============

  // Upload file to Supabase Storage using File
  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String userId,
    String folder = 'uploads',
    String? fileName,
  }) async {
    try {
      final fileExt = file.path.split('.').last;
      final uniqueFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$folder/$uniqueFileName';

      await _client.storage
          .from('user-uploads')
          .upload(
        filePath,
        file,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final publicUrl = _client.storage
          .from('user-uploads')
          .getPublicUrl(filePath);

      return {
        'success': true,
        'filePath': filePath,
        'publicUrl': publicUrl,
        'fileName': uniqueFileName,
      };
    } catch (e) {
      print('Error uploading file: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ UPLOAD FILE (WEB) ============

  // Upload file to Supabase Storage using bytes (for web)
  Future<Map<String, dynamic>> uploadFileWithBytes({
    required List<int> bytes,
    required String filePath,
    required String fileName,
  }) async {
    try {
      // ✅ Convert List<int> to Uint8List
      final Uint8List uint8List = Uint8List.fromList(bytes);

      // Upload bytes directly to Supabase Storage
      await _client.storage
          .from('user-uploads')
          .uploadBinary(
        filePath,
        uint8List, // ✅ Now using Uint8List
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final publicUrl = _client.storage
          .from('user-uploads')
          .getPublicUrl(filePath);

      return {
        'success': true,
        'filePath': filePath,
        'publicUrl': publicUrl,
        'fileName': fileName,
      };
    } catch (e) {
      print('Error uploading file with bytes: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ DELETE FILE ============

  // Delete file from Supabase Storage
  Future<Map<String, dynamic>> deleteFile(String filePath) async {
    try {
      await _client.storage
          .from('user-uploads')
          .remove([filePath]);
      return {'success': true};
    } catch (e) {
      print('Error deleting file: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ GET FILE URL ============

  // Get public URL
  String getFileUrl(String filePath) {
    return _client.storage
        .from('user-uploads')
        .getPublicUrl(filePath);
  }
}