import 'dart:io';
import 'package:flutter/material.dart';
import '../models/upload_model.dart';
import '../models/upload_services.dart';


class UploadProvider extends ChangeNotifier {
  final UploadService _uploadService = UploadService();

  List<UploadModel> _files = [];
  bool _isUploading = false;
  String? _error;
  double _uploadProgress = 0.0;

  List<UploadModel> get files => _files;
  bool get isUploading => _isUploading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  void setFiles(List<UploadModel> files) {
    _files = files;
    notifyListeners();
  }

  // ============ FILE UPLOAD METHODS ============

  // For Mobile - Upload using File
  Future<bool> uploadFile({
    required File file,
    required String userId,
    String folder = 'uploads',
    String fieldName = 'files',
    bool isProfileImage = false,
  }) async {
    _isUploading = true;
    _error = null;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      // Simulate progress
      for (int i = 1; i <= 100; i += 10) {
        _uploadProgress = i / 100;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final result = await _uploadService.uploadFile(
        file: file,
        userId: userId,
        folder: folder,
        fieldName: fieldName,
        isProfileImage: isProfileImage,
      );

      if (result['success']) {
        if (!isProfileImage) {
          _files.add(result['fileData']);
        }
        _uploadProgress = 1.0;
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // For Web - Upload using bytes
  Future<bool> uploadFileWithBytes({
    required List<int> bytes,
    required String fileName,
    required String userId,
    String folder = 'uploads',
    String fieldName = 'files',
    bool isProfileImage = false,
  }) async {
    _isUploading = true;
    _error = null;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      // Simulate progress
      for (int i = 1; i <= 100; i += 10) {
        _uploadProgress = i / 100;
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final result = await _uploadService.uploadFileWithBytes(
        bytes: bytes,
        fileName: fileName,
        userId: userId,
        folder: folder,
        fieldName: fieldName,
        isProfileImage: isProfileImage,
      );

      if (result['success']) {
        if (!isProfileImage) {
          _files.add(result['fileData']);
        }
        _uploadProgress = 1.0;
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ DELETE FILE ============

  Future<bool> deleteFile({
    required String userId,
    required String fileId,
    String fieldName = 'files',
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _uploadService.deleteFile(
        userId: userId,
        fileId: fileId,
        fieldName: fieldName,
      );

      if (result['success']) {
        _files.removeWhere((file) => file.id == fileId);
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'];
        _isUploading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // ============ GET USER FILES ============

  Stream<List<UploadModel>> getUserFilesStream({
    required String userId,
    String fieldName = 'files',
  }) {
    return _uploadService.getUserFiles(
      userId: userId,
      fieldName: fieldName,
    );
  }

  // ============ UTILITY METHODS ============

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetProgress() {
    _uploadProgress = 0.0;
    notifyListeners();
  }
}