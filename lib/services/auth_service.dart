import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with Email and Password
  Future<UserCredential?> registerWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      
      if (user != null) {
        // Create initial user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'totalScore': 0,
          'bestScores': {},
          'gamesPlayed': 0,
        });
      }
      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential result;
      
      if (kIsWeb) {
        // Use Firebase Auth's native web popup which handles client IDs automatically
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        result = await _auth.signInWithPopup(authProvider);
      } else {
        // Android/iOS implementation
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) throw Exception("Google Sign-In was cancelled by the user.");

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        result = await _auth.signInWithCredential(credential);
      }
      
      User? user = result.user;

      if (user != null) {
        // Check if user exists, if not create
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName ?? '',
            'photoUrl': user.photoURL ?? '',
            'totalScore': 0,
            'bestScores': {},
            'gamesPlayed': 0,
          });
        }
      }
      return result;
    } catch (e) {
      print(e.toString());
      throw Exception(e.toString());
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }
}
