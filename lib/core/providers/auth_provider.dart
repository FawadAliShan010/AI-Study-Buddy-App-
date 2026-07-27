import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  bool _isLoading = false;
  bool _isEmailVerified = false;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get userId => _user?.uid;
  bool get isEmailVerified => _isEmailVerified;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _user?.email;
  String? get userDisplayName => _user?.displayName;
  String? get userPhotoURL => _user?.photoURL;
  Map<String, dynamic>? get userProfile => _userProfile;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _firebaseService.authStateChanges.listen((User? user) async {
      _user = user;
      _isEmailVerified = user?.emailVerified ?? false;
      _errorMessage = null;

      if (user != null) {
        await _loadUserProfile();
      } else {
        _userProfile = null;
      }

      notifyListeners();
    });
  }

  // ============ AUTHENTICATION METHODS ============

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final userCredential = await _firebaseService.signInWithEmail(email, password);
      _user = userCredential.user;
      _isEmailVerified = _user?.emailVerified ?? false;
      await _loadUserProfile();
      notifyListeners();
    } catch (e) {
      _setError('Sign in failed: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final userCredential = await _firebaseService.signUpWithEmail(email, password);
      _user = userCredential.user;
      _isEmailVerified = false;

      // Send email verification
      await sendEmailVerification();

      // Create user profile in Firestore
      await _createUserProfile(
        email: email,
        displayName: 'Student',
      );

      await _loadUserProfile();
      notifyListeners();
    } catch (e) {
      _setError('Sign up failed: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _clearError();
    try {
      final userCredential = await _firebaseService.signInWithGoogle();
      _user = userCredential.user;
      _isEmailVerified = _user?.emailVerified ?? false;

      // Check if this is a new user and create profile if needed
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserProfile(
          email: _user?.email ?? '',
          displayName: _user?.displayName ?? 'Student',
          photoURL: _user?.photoURL,
        );
      }

      await _loadUserProfile();
      notifyListeners();
    } catch (e) {
      _setError('Google sign in failed: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }



  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    try {
      await _firebaseService.signOut();
      _user = null;
      _isEmailVerified = false;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _setError('Sign out failed: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _firebaseService.resetPassword(email);
    } catch (e) {
      _setError('Password reset failed: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ============ PROFILE MANAGEMENT METHODS ============

  Future<void> refreshUser() async {
    try {
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;
      _isEmailVerified = _user?.emailVerified ?? false;
      await _loadUserProfile();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to refresh user: ${_getFirebaseErrorMessage(e)}');
    }
  }

  Future<void> updateProfile(String displayName) async {
    _setLoading(true);
    _clearError();
    try {
      await _user?.updateDisplayName(displayName);
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;

      // Update Firestore profile
      if (_user != null) {
        await _firebaseService.updateUserProfile(_user!.uid, {
          'displayName': displayName,
        });
        await _loadUserProfile();
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfilePicture(String photoURL) async {
    _setLoading(true);
    _clearError();
    try {
      await _user?.updatePhotoURL(photoURL);
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;

      if (_user != null) {
        await _firebaseService.updateUserProfile(_user!.uid, {
          'photoURL': photoURL,
        });
        await _loadUserProfile();
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile picture: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    try {
      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: _user?.email ?? '',
        password: currentPassword,
      );
      await _user?.reauthenticateWithCredential(credential);
      await _user?.updatePassword(newPassword);
    } catch (e) {
      _setError('Failed to change password: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseService.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send verification email: ${_getFirebaseErrorMessage(e)}');
    }
  }

  Future<void> verifyEmail() async {
    _setLoading(true);
    try {
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;
      _isEmailVerified = _user?.emailVerified ?? false;

      if (_user != null) {
        await _firebaseService.updateUserProfile(_user!.uid, {
          'emailVerified': _isEmailVerified,
        });
        await _loadUserProfile();
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to verify email: ${_getFirebaseErrorMessage(e)}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    _setLoading(true);
    _clearError();
    try {
      // First delete user data from Firestore
      await _deleteUserData();

      // Then delete the auth account
      await _user?.delete();
      _user = null;
      _isEmailVerified = false;
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete account: ${_getFirebaseErrorMessage(e)}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reauthenticateUser(String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: _user?.email ?? '',
        password: password,
      );
      await _user?.reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Reauthentication failed: ${_getFirebaseErrorMessage(e)}');
    }
  }

  // ============ USER PROFILE LOADING ============

  Future<void> _loadUserProfile() async {
    if (_user == null) {
      _userProfile = null;
      return;
    }

    try {
      final doc = await _firebaseService.getUserProfile(_user!.uid);
      if (doc.exists) {
        _userProfile = doc.data() as Map<String, dynamic>?;
      } else {
        _userProfile = null;
      }
    } catch (e) {
      // Error loading user profile - silently handle
      _userProfile = null;
    }
  }

  Future<void> _createUserProfile({
    required String email,
    required String displayName,
    String? photoURL,
  }) async {
    if (_user == null) return;

    try {
      await _firebaseService.createUserProfile(_user!.uid, {
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL ?? '',
        'emailVerified': _user?.emailVerified ?? false,
        'settings': {
          'theme': 'dark',
          'notifications': true,
          'language': 'en',
        },
        'stats': {
          'studyTime': 0,
          'quizzesCompleted': 0,
          'notesCreated': 0,
          'streak': 0,
          'lastStudyDate': DateTime.now().toIso8601String(),
        }
      });
      await _loadUserProfile();
    } catch (e) {
      // Error creating user profile - silently handle
    }
  }

  Future<void> _deleteUserData() async {
    if (_user == null) return;

    try {
      final uid = _user!.uid;

      // Delete user document
      await _firebaseService.updateUserProfile(uid, {
        'deleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // Note: Your FirebaseService doesn't have delete methods yet,
      // so we'll handle this in the service layer later

      // For now, just mark as deleted
    } catch (e) {
      // Error deleting user data - silently handle
    }
  }

  // ============ SETTINGS AND STATS METHODS ============

  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    if (_user == null) return;

    try {
      await _firebaseService.updateUserProfile(_user!.uid, {
        'settings': settings,
      });
      await _loadUserProfile();
    } catch (e) {
      throw Exception('Failed to update settings: ${_getFirebaseErrorMessage(e)}');
    }
  }

  Map<String, dynamic>? getUserSettings() {
    return _userProfile?['settings'] as Map<String, dynamic>?;
  }

  Future<void> updateStudyStats(Map<String, dynamic> stats) async {
    if (_user == null) return;

    try {
      await _firebaseService.updateUserProfile(_user!.uid, {
        'stats': stats,
      });
      await _loadUserProfile();
    } catch (e) {
      // Error updating study stats - silently handle
    }
  }

  Map<String, dynamic>? getUserStats() {
    return _userProfile?['stats'] as Map<String, dynamic>?;
  }

  Future<void> updateStudyTime(int minutes) async {
    try {
      final stats = getUserStats() ?? {};
      final currentTime = stats['studyTime'] ?? 0;
      final now = DateTime.now();

      await updateStudyStats({
        ...stats,
        'studyTime': currentTime + minutes,
        'lastStudyDate': now.toIso8601String(),
      });

      // Update streak
      await _updateStreak();
    } catch (e) {
      // Error updating study time - silently handle
    }
  }

  Future<void> incrementQuizzesCompleted() async {
    try {
      final stats = getUserStats() ?? {};
      final current = stats['quizzesCompleted'] ?? 0;
      await updateStudyStats({
        ...stats,
        'quizzesCompleted': current + 1,
      });
    } catch (e) {
      // Error incrementing quizzes - silently handle
    }
  }

  Future<void> incrementNotesCreated() async {
    try {
      final stats = getUserStats() ?? {};
      final current = stats['notesCreated'] ?? 0;
      await updateStudyStats({
        ...stats,
        'notesCreated': current + 1,
      });
    } catch (e) {
      // Error incrementing notes - silently handle
    }
  }

  Future<void> _updateStreak() async {
    try {
      final stats = getUserStats() ?? {};
      final lastDateStr = stats['lastStudyDate'];
      final lastDate = lastDateStr != null
          ? DateTime.parse(lastDateStr)
          : null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int currentStreak = stats['streak'] ?? 0;

      if (lastDate != null) {
        final lastStudyDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final difference = today.difference(lastStudyDay).inDays;

        if (difference == 0) {
          // Already studied today, do nothing
          return;
        } else if (difference == 1) {
          // Studied yesterday, increment streak
          currentStreak++;
        } else if (difference > 1) {
          // Missed a day, reset streak
          currentStreak = 0;
        }
      } else {
        // First time studying
        currentStreak = 1;
      }

      await updateStudyStats({
        ...stats,
        'streak': currentStreak,
        'lastStudyDate': now.toIso8601String(),
      });
    } catch (e) {
      // Error updating streak - silently handle
    }
  }

  // ============ HELPER METHODS ============

  String _getFirebaseErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password should be at least 6 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'This sign-in method is not allowed.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'network-request-failed':
          return 'Network error. Please check your connection.';
        case 'requires-recent-login':
          return 'Please sign in again to perform this action.';
        case 'provider-already-linked':
          return 'This account is already linked to this provider.';
        case 'credential-already-in-use':
          return 'This credential is already associated with another account.';
        case 'invalid-credential':
          return 'Invalid credentials. Please try again.';
        case 'user-mismatch':
          return 'User credentials don\'t match.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return error.toString();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============ DISPOSE ============

  @override
  void dispose() {
    super.dispose();
  }
}