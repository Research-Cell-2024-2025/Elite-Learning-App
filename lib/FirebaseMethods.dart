import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Assuming you're using Firebase Auth

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }
}
