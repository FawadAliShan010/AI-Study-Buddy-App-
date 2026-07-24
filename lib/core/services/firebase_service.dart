import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // FIX: Updated GoogleSignIn initialization (v7)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Authentication Methods
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // FIXED Google Sign-In (v7 API)
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication auth = account.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: auth.idToken, // FIX: accessToken removed in v7
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

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
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Firestore Methods
  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        ...data,
      },
      SetOptions(merge: true),
    );
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Notes
  Future<String> createNote(String uid, Map<String, dynamic> data) async {
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
  }

  Stream<QuerySnapshot> getNotes(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateNote(String uid, String noteId, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String uid, String noteId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  // Chat History
  Future<String> saveChatMessage(String uid, Map<String, dynamic> data) async {
    final docRef = await _firestore
        .collection('users')
        .doc(uid)
        .collection('chat_history')
        .add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Stream<QuerySnapshot> getChatHistory(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('chat_history')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  // Quiz Results
  Future<void> saveQuizResult(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('quiz_results')
        .add({
      ...data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getQuizResults(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('quiz_results')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }

  // Progress Tracking
  Future<void> updateStudyStats(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .update({
      'studyStats': FieldValue.arrayUnion([data]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}