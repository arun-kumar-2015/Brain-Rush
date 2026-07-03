import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.user.listen((User? user) {
      if (user != null) {
        _fetchUserData(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    UserCredential? res = await _authService.signInWithEmail(email, password);
    _isLoading = false;
    notifyListeners();
    return res != null;
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    UserCredential? res = await _authService.registerWithEmail(email, password, name);
    _isLoading = false;
    notifyListeners();
    return res != null;
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    UserCredential? res = await _authService.signInWithGoogle();
    _isLoading = false;
    notifyListeners();
    return res != null;
  }

  Future<void> logout() async {
    await _authService.signOut();
  }
}
