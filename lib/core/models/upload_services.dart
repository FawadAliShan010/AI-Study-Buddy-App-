import 'dart:io';
import 'dart:typed_data';
import 'package:ai_study_buddy/core/models/user_profile_uploadfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/upload_model.dart';
import '../services/firebase_service.dart';
import '../services/supabase_services.dart';

class UploadService {
  final SupabaseService _supabaseService = SupabaseService();
  final FirebaseService _firebaseService = FirebaseService();


  Future<Map<String, dynamic>> uploadFile({
    required File file,
    required String userId,
    String folder = 'uploads',
    String fieldName = 'files',
    bool isProfileImage = false,
  }) async {
    try {
      // ✅ Validate user ID
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      // ✅ Check if bucket exists
      final bucketExists = await _supabaseService.bucketExists();
      if (!bucketExists) {
        throw Exception('Storage bucket "user-uploads" does not exist');
      }

      // Upload to Supabase
      final uploadResult = await _supabaseService.uploadFile(
        file: file,
        userId: userId,
        folder: folder,
      );

      if (!uploadResult['success']) {
        throw Exception(uploadResult['error']);
      }

      // Prepare file data
      final fileData = UploadModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: uploadResult['publicUrl'],
        path: uploadResult['filePath'],
        fileName: uploadResult['fileName'],
        uploadedAt: DateTime.now(),
        fileType: file.path.split('.').last,
        fileSize: await file.length(),
      );

      return await _saveToFirebase(
        fileData: fileData,
        userId: userId,
        fieldName: fieldName,
        isProfileImage: isProfileImage,
      );
    } catch (e) {
      print('❌ Upload error (File): $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ UPLOAD FILE (WEB) ============

  Future<Map<String, dynamic>> uploadFileWithBytes({
    required List<int> bytes,
    required String fileName,
    required String userId,
    String folder = 'uploads',
    String fieldName = 'files',
    bool isProfileImage = false,
  }) async {
    try {
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      // ✅ Check if bucket exists
      final bucketExists = await _supabaseService.bucketExists();
      if (!bucketExists) {
        throw Exception('Storage bucket "user-uploads" does not exist');
      }

      // Create unique file path
      final fileExt = fileName.split('.').last;
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$folder/$uniqueFileName';

      print('📤 Uploading file: $filePath');

      // Upload to Supabase
      final uploadResult = await _supabaseService.uploadFileWithBytes(
        bytes: bytes,
        filePath: filePath,
        fileName: uniqueFileName,
      );

      if (!uploadResult['success']) {
        throw Exception(uploadResult['error']);
      }

      // Prepare file data
      final fileData = UploadModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: uploadResult['publicUrl'],
        path: uploadResult['filePath'],
        fileName: uniqueFileName,
        uploadedAt: DateTime.now(),
        fileType: fileExt,
        fileSize: bytes.length,
      );

      return await _saveToFirebase(
        fileData: fileData,
        userId: userId,
        fieldName: fieldName,
        isProfileImage: isProfileImage,
      );
    } catch (e) {
      print('❌ Upload error (Bytes): $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ SAVE TO FIREBASE ============

  Future<Map<String, dynamic>> _saveToFirebase({
    required UploadModel fileData,
    required String userId,
    required String fieldName,
    required bool isProfileImage,
  }) async {
    try {
      if (isProfileImage) {
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
      print('❌ Firebase save error: $e');
      return {
        'success': false,
        'error': 'Failed to save to Firebase: $e',
      };
    }
  }

  // ============ DELETE FILE ============

  Future<Map<String, dynamic>> deleteFile({
    required String userId,
    required String fileId,
    String fieldName = 'files',
  }) async {
    try {
      final docSnapshot = await _firebaseService.getUserProfile(userId);

      if (!docSnapshot.exists) {
        throw Exception('User document not found');
      }

      final userData = docSnapshot.data() as Map<String, dynamic>;
      final files = List.from(userData[fieldName] ?? []);

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

      final deleteResult = await _supabaseService.deleteFile(fileToDelete['path'] as String);

      if (!deleteResult['success']) {
        throw Exception(deleteResult['error']);
      }

      files.removeAt(fileIndex!);
      await _firebaseService.updateUserProfile(userId, {
        fieldName: files,
      });

      return {
        'success': true,
        'message': 'File deleted successfully',
      };
    } catch (e) {
      print('❌ Delete error: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ============ GET USER FILES ============

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
}