import 'package:flutter/material.dart';

import '../models/upload_services.dart';
import '../models/user_profile_uploadfile.dart';


class UserProfileProvider extends ChangeNotifier {
  final UploadService _uploadService = UploadService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user profile
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final doc = await _uploadService.getUserProfile(userId).first;
      _profile = doc;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stream profile updates
  Stream<UserProfile?> streamProfile(String userId) {
    return _uploadService.getUserProfile(userId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}