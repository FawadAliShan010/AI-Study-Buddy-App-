import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ UPDATED: new API uses instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ============ AUTHENTICATION METHODS ============

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }



  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // ✅ WEB FIX (THIS IS REQUIRED)
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        return await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // ✅ MOBILE (Android/iOS)
        final GoogleSignInAccount? googleUser =
        await _googleSignIn.authenticate();

        if (googleUser == null) {
          throw Exception('Sign-in cancelled');
        }

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      throw Exception("Google sign-in failed");
    }
  }

  // Apple Sign-In
  Future<UserCredential> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      return await _auth.signInWithCredential(oAuthCredential);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // ============ USER PROFILE METHODS ============

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          ...data,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserProfile(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> userProfileExists(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  // ============ USER SETTINGS METHODS ============

  Future<void> updateUserSettings(String uid, Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserSettings(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['settings'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ============ STUDY STATS METHODS ============

  Future<void> updateStudyStats(String uid, Map<String, dynamic> stats) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'stats': stats,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getStudyStats(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['stats'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementStudyTime(String uid, int minutes) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'stats.studyTime': FieldValue.increment(minutes),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementQuizzesCompleted(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'stats.quizzesCompleted': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementNotesCreated(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'stats.notesCreated': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStreak(String uid, int streak, String lastStudyDate) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'stats.streak': streak,
        'stats.lastStudyDate': lastStudyDate,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // ============ NOTES METHODS ============

  Future<String> createNote(String uid, Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getNotes(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot> getNotesOnce(String uid) async {
    try {
      return await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateNote(
      String uid, String noteId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(noteId)
          .update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String uid, String noteId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(noteId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllNotes(String uid) async {
    try {
      final notes = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();

      final batch = _firestore.batch();
      for (var doc in notes.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // ============ CHAT HISTORY METHODS ============

  Future<String> saveChatMessage(
      String uid, Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(uid)
          .collection('chat_history')
          .add({
        ...data,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getChatHistory(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('chat_history')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllChatHistory(String uid) async {
    try {
      final history = await _firestore
          .collection('users')
          .doc(uid)
          .collection('chat_history')
          .get();

      final batch = _firestore.batch();
      for (var doc in history.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // ============ QUIZ RESULTS METHODS ============

  Future<void> saveQuizResult(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('quiz_results')
          .add({
        ...data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> getQuizResults(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('quiz_results')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllQuizResults(String uid) async {
    try {
      final results = await _firestore
          .collection('users')
          .doc(uid)
          .collection('quiz_results')
          .get();

      final batch = _firestore.batch();
      for (var doc in results.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // ============ USER DATA MANAGEMENT ============

  Future<void> deleteAllUserData(String uid) async {
    try {
      // Delete all user data in parallel for performance
      await Future.wait([
        deleteAllNotes(uid),
        deleteAllChatHistory(uid),
        deleteAllQuizResults(uid),
        deleteUserProfile(uid),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  // ============ BATCH OPERATIONS ============

  Future<void> batchUpdate(Map<String, Map<String, dynamic>> updates) async {
    try {
      final batch = _firestore.batch();

      updates.forEach((docPath, data) {
        final docRef = _firestore.doc(docPath);
        batch.update(docRef, {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // ============ STREAK CALCULATION ============

  Future<int> calculateStreak(String uid) async {
    try {
      final stats = await getStudyStats(uid);
      if (stats == null) return 0;

      final lastDateStr = stats['lastStudyDate'] as String?;
      if (lastDateStr == null) return 0;

      final lastDate = DateTime.parse(lastDateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastStudyDay = DateTime(lastDate.year, lastDate.month, lastDate.day);

      final difference = today.difference(lastStudyDay).inDays;

      if (difference == 0) {
        // Studied today, return current streak
        return stats['streak'] ?? 0;
      } else if (difference == 1) {
        // Studied yesterday, increment streak
        final newStreak = (stats['streak'] ?? 0) + 1;
        await updateStreak(uid, newStreak, now.toIso8601String());
        return newStreak;
      } else if (difference > 1) {
        // Missed a day, reset streak
        await updateStreak(uid, 0, now.toIso8601String());
        return 0;
      }

      return stats['streak'] ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  // ============ LISTENERS ============

  Stream<DocumentSnapshot> listenToUserProfile(String uid) {
    try {
      return _firestore.collection('users').doc(uid).snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> listenToNotes(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .orderBy('createdAt', descending: true)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> listenToQuizResults(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('quiz_results')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot> listenToChatHistory(String uid) {
    try {
      return _firestore
          .collection('users')
          .doc(uid)
          .collection('chat_history')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }

  // ============ SEARCH METHODS ============

  Future<QuerySnapshot> searchNotes(String uid, String query) async {
    try {
      // Note: For full-text search, consider using Firebase Extensions
      // or a third-party service like Algolia
      return await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: '$query\uf8ff')
          .orderBy('title')
          .get();
    } catch (e) {
      rethrow;
    }
  }

  // ============ EXPORT DATA ============

  Future<Map<String, dynamic>> exportUserData(String uid) async {
    try {
      final profile = await getUserProfile(uid);
      final notes = await getNotesOnce(uid);
      final quizResults = await _firestore
          .collection('users')
          .doc(uid)
          .collection('quiz_results')
          .get();
      final chatHistory = await _firestore
          .collection('users')
          .doc(uid)
          .collection('chat_history')
          .get();

      return {
        'profile': profile.exists ? profile.data() : null,
        'notes': notes.docs.map((doc) => doc.data()).toList(),
        'quizResults': quizResults.docs.map((doc) => doc.data()).toList(),
        'chatHistory': chatHistory.docs.map((doc) => doc.data()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      rethrow;
    }
  }
}