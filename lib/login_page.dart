import 'dart:ui';

import 'package:elite/admin/Homepage.dart';
import 'package:elite/main.dart';
import 'package:elite/teacher/markAttendance.dart';
import 'package:elite/teacher/teacherDashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elite/parent/parent_module.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  final String Role;

  const LoginPage({super.key, required this.Role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
    routeUser();
  }

  void _checkUserLoggedIn() async {
    User? user = auth.currentUser;
    if (user != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void routeUser() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    User? user = auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot? documentSnapshot;
        QuerySnapshot? querySnapshot;
        String? userId = user.email;

        if (widget.Role == "teacher") {
          documentSnapshot = await FirebaseFirestore.instance
              .collection('teacher')
              .doc(userId)
              .get();
        } else {
          documentSnapshot = await FirebaseFirestore.instance
              .collection('students')
              .doc(userId)
              .get();
        }



        if (documentSnapshot != null && documentSnapshot.exists) {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          String role = data['role'];
          if (role != widget.Role) {
            _showErrorSnackBar(
                'Invalid role. Please log in with the correct credentials.');
            auth.signOut();
            return;
          }

          if (data['token'] != token) {
            await FirebaseFirestore.instance
                .collection(widget.Role == "teacher" ? 'teacher' : 'students')
                .doc(userId)
                .set({'token': token}, SetOptions(merge: true));
          }

          if (data.containsKey('standard')) {
            final standard = data['standard'];
            await messaging.subscribeToTopic(standard);
          }
          else {
            _showErrorSnackBar('Standard field is missing.');
          }


          if (role == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (role == "teacher") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => dashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ParentModule()),
            );
          }
        } else {
          _showErrorSnackBar('Document does not exist in the database.');
        }
      } catch (e) {
        _showErrorSnackBar('Error fetching document: ${e.toString()}');
      }
    } else {
      _showErrorSnackBar('No user is currently signed in.');
    }
  }

  Future<void> _resetPassword(String email) async {
    if (email.isEmpty) {
      _showErrorSnackBar('Email cannot be empty.');
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorSnackBar('Invalid email format.');
    }
    try {
      final _auth = FirebaseAuth.instance;
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset link has been sent to your email.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else {
        message = 'Enter email';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  Future<void> loginUser(String email, String password) async {
    if (_validateInputs(email, password)) {
      setState(() {
        _isLoading = true;
      });

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.subscribeToTopic('birthdays');

      try {

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;

        if (user != null) {
          if (user.emailVerified) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('email', email);
            await prefs.setString('password', password);

            routeUser();
          } else {
            await user.sendEmailVerification();
            _showErrorSnackBar(
                'Please verify your email. A verification link has been sent.');
          }
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          try {
            UserCredential userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: email, password: password);

            User? user = userCredential.user;

            if (user != null) {
              await user.sendEmailVerification();
              _showErrorSnackBar(
                  'Account created! Please verify your email. A verification link has been sent.');
            }
          } on FirebaseAuthException catch (e) {
            _showErrorSnackBar(
                'An error occurred during registration: ${e.message}');
          }
        } else if (e.code == 'wrong-password') {
          _showErrorSnackBar('Wrong password provided for that user.');
        } else {
          _showErrorSnackBar('An error occurred: ${e.message}');
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateInputs(String email, String password) {
    if (email.isEmpty) {
      _showErrorSnackBar('Email cannot be empty.');
      return false;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorSnackBar('Invalid email format.');
      return false;
    }

    if (password.isEmpty) {
      _showErrorSnackBar('Password cannot be empty.');
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/clouds.jpg'),
              fit: BoxFit.fill,
              // colorFilter: ColorFilter.mode(Colors.purple,BlendMode.softLight),
              opacity: 0.7,
              //filterQuality: FilterQuality.low
            )),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/eliteimg.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: GlassmorphicContainer(
                          height: 400, // 60% of available height
                          width: double.infinity,
                          borderRadius: 10,
                          border: 0,
                          blur: 4,
                          linearGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.withOpacity(0.1),
                              Colors.purple.withOpacity(0.05),
                            ],
                            stops: [0.1, 1],
                          ),
                          borderGradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.deepPurple.withOpacity(0.8),
                              Colors.deepPurple.withOpacity(0.8),
                              Colors.purple.withOpacity(0.3),
                              Colors.purple.withOpacity(0.3),
                            ],
                            stops: [0.0, 0.1, 0.9, 1.0],
                          ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 30, 20, 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'LOGIN...',
                                    style: TextStyle(
                                      fontFamily: 'Impact',
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  const Text(
                                    'Welcome to Elite Learning Centre!',
                                    style: TextStyle(
                                      fontFamily: 'Impact',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextField(
                                    style: TextStyle(color: Colors.purple),
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.mail,
                                          color: Colors.purple),
                                      filled: true,
                                      fillColor: Colors.purple.withOpacity(0.2),
                                      label: Text('Email',
                                          style:
                                              TextStyle(color: Colors.purple)),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.purple),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.purple.withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  TextField(
                                    style: TextStyle(color: Colors.purple),
                                    obscureText: _showPassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      prefixIcon:
                                          Icon(Icons.key, color: Colors.purple),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.purple,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showPassword = !_showPassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: Colors.purple.withOpacity(0.2),
                                      label: Text('Password',
                                          style:
                                              TextStyle(color: Colors.purple)),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.purple),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.purple.withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple.shade400,
                                    ),
                                    onPressed: () => loginUser(
                                        _emailController.text,
                                        _passwordController.text),
                                    child: Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontFamily: 'Archives',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () =>
                                        _resetPassword(_emailController.text),
                                    child: Text(
                                      "forgot password?",
                                      style:
                                          TextStyle(color: Colors.indigoAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}