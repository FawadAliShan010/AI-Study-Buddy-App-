import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  // ============ UPLOAD FILE (MOBILE) ============

  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String userId,
    String folder = 'uploads',
    String? fileName,
  }) async {
    try {
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileExt = file.path.split('.').last;
      final uniqueFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // ✅ CORRECT: Build path without leading slash
      // ✅ Use a simple path structure: user_folder/filename
      final filePath = '$userId/$folder/$uniqueFileName';

      print('📤 === UPLOAD DEBUG ===');
      print('📤 Full Path: $filePath');

      // ✅ Try uploading with a simpler path first
      final response = await _client.storage
          .from('user-uploads')
          .upload(
        filePath,
        file,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true, // ✅ Set to true to overwrite if exists
        ),
      );

      final publicUrl = _client.storage
          .from('user-uploads')
          .getPublicUrl(filePath);

      print('✅ Upload successful!');
      print('✅ Public URL: $publicUrl');

      return {
        'success': true,
        'filePath': filePath,
        'publicUrl': publicUrl,
        'fileName': uniqueFileName,
        'data': response,
      };
    } catch (e) {
      print('❌ Error uploading file: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ UPLOAD FILE (WEB) ============

  Future<Map<String, dynamic>> uploadFileWithBytes({
    required List<int> bytes,
    required String filePath,
    required String fileName,
  }) async {
    try {
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      // ✅ Ensure no leading slash and use clean path
      final cleanPath = filePath.replaceAll(RegExp(r'^/+'), '');

      print('📤 === UPLOAD DEBUG (BYTES) ===');
      print('📤 Clean Path: $cleanPath');

      final Uint8List uint8List = Uint8List.fromList(bytes);

      final response = await _client.storage
          .from('user-uploads')
          .uploadBinary(
        cleanPath,
        uint8List,
        fileOptions: FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final publicUrl = _client.storage
          .from('user-uploads')
          .getPublicUrl(cleanPath);

      print('✅ Upload successful (bytes)!');
      print('✅ Public URL: $publicUrl');

      return {
        'success': true,
        'filePath': cleanPath,
        'publicUrl': publicUrl,
        'fileName': fileName,
        'data': response,
      };
    } catch (e) {
      print('❌ Error uploading file with bytes: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ DELETE FILE ============

  Future<Map<String, dynamic>> deleteFile(String filePath) async {
    try {
      final cleanPath = filePath.replaceAll(RegExp(r'^/+'), '');

      print('🗑️ Deleting from Supabase: $cleanPath');

      await _client.storage
          .from('user-uploads')
          .remove([cleanPath]);

      print('✅ Delete successful');
      return {'success': true};
    } catch (e) {
      print('❌ Error deleting file: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ GET FILE URL ============

  String getFileUrl(String filePath) {
    final cleanPath = filePath.replaceAll(RegExp(r'^/+'), '');
    return _client.storage
        .from('user-uploads')
        .getPublicUrl(cleanPath);
  }

  // ============ CHECK IF BUCKET EXISTS ============

  Future<bool> bucketExists() async {
    try {
      final buckets = await _client.storage.listBuckets();
      print('📦 Available buckets: ${buckets.map((b) => b.id).toList()}');
      final exists = buckets.any((bucket) => bucket.id == 'user-uploads');
      print('📦 Bucket "user-uploads" exists: $exists');
      return exists;
    } catch (e) {
      print('❌ Error checking bucket: $e');
      return false;
    }
  }

  // ============ LIST FILES ============

  Future<List<String>> listFiles(String userId, {String folder = 'uploads'}) async {
    try {
      final path = '$userId/$folder/';
      print('📂 Listing files in: $path');

      final response = await _client.storage
          .from('user-uploads')
          .list(path: path);

      final fileNames = response.map((file) => file.name).toList();
      print('📂 Found files: $fileNames');
      return fileNames;
    } catch (e) {
      print('❌ Error listing files: $e');
      return [];
    }
  }
}