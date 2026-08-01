import 'dart:io';
import 'dart:typed_data'; // ✅ ADD THIS IMPORT
import 'package:ai_study_buddy/core/models/user_profile_uploadfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/upload_model.dart';
import '../services/firebase_service.dart';
import '../services/supabase_services.dart';

class UploadService {
  final SupabaseService _supabaseService = SupabaseService();
  final FirebaseService _firebaseService = FirebaseService();

  // ============ UPLOAD FILE (MOBILE) ============

  /// Upload file using File (Mobile - Android/iOS)
  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String userId,
    String folder = 'uploads',
    String fieldName = 'files',
    bool isProfileImage = false,
  }) async {
    try {
      // Validate file exists
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      // 1. Upload to Supabase Storage
      final uploadResult = await _supabaseService.uploadFile(
        file: file,
        userId: userId,
        folder: folder,
      );

      if (!uploadResult['success']) {
        throw Exception(uploadResult['error']);
      }

      // 2. Prepare file data
      final fileData = UploadModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: uploadResult['publicUrl'],
        path: uploadResult['filePath'],
        fileName: uploadResult['fileName'],
        uploadedAt: DateTime.now(),
        fileType: file.path.split('.').last,
        fileSize: await file.length(),
      );

      // 3. Save to Firebase
      return await _saveToFirebase(
        fileData: fileData,
        userId: userId,
        fieldName: fieldName,
        isProfileImage: isProfileImage,
      );
    } catch (e) {
      print('Upload error (File): $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ UPLOAD FILE (WEB) ============

  /// Upload file using bytes (Web)
  Future<Map<String, dynamic>> uploadFileWithBytes({
    required List<int> bytes,
    required String fileName,
    required String userId,
    String folder = 'uploads',
    String fieldName = 'files',
    bool isProfileImage = false,
  }) async {
    try {
      // Validate bytes
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      // 1. Create unique file path
      final fileExt = fileName.split('.').last;
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$folder/$uniqueFileName';

      // 2. Upload to Supabase Storage using bytes
      final uploadResult = await _supabaseService.uploadFileWithBytes(
        bytes: bytes, // Will be converted to Uint8List in supabase_services.dart
        filePath: filePath,
        fileName: uniqueFileName,
      );

      if (!uploadResult['success']) {
        throw Exception(uploadResult['error']);
      }

      // 3. Prepare file data
      final fileData = UploadModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: uploadResult['publicUrl'],
        path: uploadResult['filePath'],
        fileName: uniqueFileName,
        uploadedAt: DateTime.now(),
        fileType: fileExt,
        fileSize: bytes.length,
      );

      // 4. Save to Firebase
      return await _saveToFirebase(
        fileData: fileData,
        userId: userId,
        fieldName: fieldName,
        isProfileImage: isProfileImage,
      );
    } catch (e) {
      print('Upload error (Bytes): $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ SAVE TO FIREBASE ============

  /// Save file data to Firebase Firestore
  Future<Map<String, dynamic>> _saveToFirebase({
    required UploadModel fileData,
    required String userId,
    required String fieldName,
    required bool isProfileImage,
  }) async {
    try {
      if (isProfileImage) {
        // For profile image, store directly in user document
        await _firebaseService.updateUserProfile(userId, {
          'photoURL': fileData.url,
          'photoPath': fileData.path,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return {
          'success': true,
          'fileData': fileData,
          'message': 'Profile image updated successfully',
        };
      } else {
        // For regular files, add to files array
        final docSnapshot = await _firebaseService.getUserProfile(userId);

        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final currentFiles = List.from(data[fieldName] ?? []);
          currentFiles.add(fileData.toJson());

          await _firebaseService.updateUserProfile(userId, {
            fieldName: currentFiles,
          });
        } else {
          await _firebaseService.createUserProfile(userId, {
            fieldName: [fileData.toJson()],
          });
        }

        return {
          'success': true,
          'fileData': fileData,
          'message': 'File uploaded successfully',
        };
      }
    } catch (e) {
      print('Firebase save error: $e');
      return {
        'success': false,
        'error': 'Failed to save to Firebase: $e',
      };
    }
  }

  // ============ DELETE FILE ============

  /// Delete file from both Supabase and Firebase
  Future<Map<String, dynamic>> deleteFile({
    required String userId,
    required String fileId,
    String fieldName = 'files',
  }) async {
    try {
      // 1. Get user document
      final docSnapshot = await _firebaseService.getUserProfile(userId);

      if (!docSnapshot.exists) {
        throw Exception('User document not found');
      }

      final userData = docSnapshot.data() as Map<String, dynamic>;
      final files = List.from(userData[fieldName] ?? []);

      // 2. Find file to delete
      Map<String, dynamic>? fileToDelete;
      int? fileIndex;

      for (int i = 0; i < files.length; i++) {
        if (files[i]['id'] == fileId) {
          fileToDelete = files[i];
          fileIndex = i;
          break;
        }
      }

      if (fileToDelete == null) {
        throw Exception('File not found in Firebase');
      }

      // 3. Delete from Supabase Storage
      final deleteResult = await _supabaseService.deleteFile(
          fileToDelete['path'] as String
      );

      if (!deleteResult['success']) {
        throw Exception(deleteResult['error']);
      }

      // 4. Remove from Firebase
      files.removeAt(fileIndex!);
      await _firebaseService.updateUserProfile(userId, {
        fieldName: files,
      });

      return {
        'success': true,
        'message': 'File deleted successfully',
      };
    } catch (e) {
      print('Delete error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ GET USER FILES ============

  /// Get user profile with files stream
  Stream<UserProfile?> getUserProfile(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return UserProfile.fromJson(userId, data);
    });
  }

  /// Get user files stream
  Stream<List<UploadModel>> getUserFiles({
    required String userId,
    String fieldName = 'files',
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>;
      final files = List.from(data[fieldName] ?? []);
      return files
          .map((file) => UploadModel.fromJson(file as Map<String, dynamic>))
          .toList();
    });
  }

  // ============ GET SINGLE FILE ============

  /// Get a single file by ID
  Future<UploadModel?> getFileById({
    required String userId,
    required String fileId,
    String fieldName = 'files',
  }) async {
    try {
      final docSnapshot = await _firebaseService.getUserProfile(userId);
      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data() as Map<String, dynamic>;
      final files = List.from(data[fieldName] ?? []);

      for (var file in files) {
        if (file['id'] == fileId) {
          return UploadModel.fromJson(file as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('Get file error: $e');
      return null;
    }
  }

  // ============ CLEAN UP ============

  /// Delete all files for a user (use with caution)
  Future<Map<String, dynamic>> deleteAllUserFiles({
    required String userId,
    String fieldName = 'files',
  }) async {
    try {
      final docSnapshot = await _firebaseService.getUserProfile(userId);
      if (!docSnapshot.exists) {
        return {'success': true, 'message': 'No files to delete'};
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      final files = List.from(data[fieldName] ?? []);

      // Delete all files from Supabase
      for (var file in files) {
        await _supabaseService.deleteFile(file['path'] as String);
      }

      // Clear files array in Firebase
      await _firebaseService.updateUserProfile(userId, {
        fieldName: [],
      });

      return {
        'success': true,
        'message': 'All files deleted successfully',
      };
    } catch (e) {
      print('Delete all files error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}