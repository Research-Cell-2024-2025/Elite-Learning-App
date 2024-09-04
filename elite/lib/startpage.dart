import 'package:elite/parent/parent_module.dart';
import 'package:elite/teacher/teacherDashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:elite/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin/Homepage.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status when the page is initialized

  }
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (email != null && password != null) {
      // Simulate login and navigate to the appropriate HomePage
      bool success = await _loginUser(email, password);
      if (success) {
        routeUser();
      }
    }
  }
  Future<bool> _loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null && user.emailVerified) {
        return true;
      } else {

        return false;
      }
    } catch (e) {

      return false;
    }
  }
  void routeUser() {
    if (isTeacher) {
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
  }




  bool isTeacher = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/eliteimg.jpg'),
                fit: BoxFit.cover, // Changed to cover for better fill
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: GlassmorphicContainer(
                margin: EdgeInsets.symmetric(horizontal: 25),
                padding: EdgeInsets.symmetric(vertical: 70, horizontal: 20),
                width: double.infinity,
                height: 500, // Increased height for better spacing
                borderRadius: 20, // Rounded corners
                border: 0,
                blur: 10, // Increased blur for more pronounced glass effect
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.purple.withOpacity(0.1),
                  ],
                  stops: [0.1, 1],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.withOpacity(0.8),
                    Colors.deepPurple.withOpacity(0.6),
                    Colors.purple.withOpacity(0.4),
                    Colors.purple.withOpacity(0.3),
                  ],
                  stops: [0.0, 0.1, 0.9, 1.0],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('LOGIN',
                          style: TextStyle(
                           color: Colors.purple,
                            fontFamily: 'Archives',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,// Increased font size
                          )),
                      SizedBox(height: 10,),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15), // Increased radius
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 8, // Added shadow
                          shadowColor:
                              Colors.black.withOpacity(0.4), // Shadow color
                        ),
                        onPressed: () {
                          setState(() {
                            isTeacher = false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(isTeacher: false),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/student.png',
                                width: 60, height: 60),
                            SizedBox(height: 10),
                            Text(
                              'STUDENT LOGIN',
                              style: TextStyle(
                                fontFamily: 'Archives',
                                color: Colors.white,
                                fontSize: 22, // Increased font size
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(15), // Increased radius
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          elevation: 10, // Added shadow
                          shadowColor:
                              Colors.black.withOpacity(0.4), // Shadow color
                        ),
                        onPressed: () {
                          setState(() {
                            isTeacher = true;
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(isTeacher: true),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/teacher.png',
                                width: 60, height: 60),
                            SizedBox(height: 10),
                            Text(
                              'TEACHER LOGIN',
                              style: TextStyle(
                                fontFamily: 'Archives',
                                color: Colors.white,
                                fontSize: 22, // Increased font size
                                fontWeight: FontWeight.bold, // Bold text
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
