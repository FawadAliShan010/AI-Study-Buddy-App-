import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get userId => _user?.uid;

  AuthProvider() {
    _initAuth();
  }

  void _initAuth() {
    _firebaseService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _firebaseService.signInWithEmail(email, password);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _firebaseService.signUpWithEmail(email, password);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _firebaseService.signInWithGoogle();
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithApple() async {
    _setLoading(true);
    try {
      await _firebaseService.signInWithApple();
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _firebaseService.signOut();
      _user = null;
    } catch (e) {
      throw Exception('Sign out failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}