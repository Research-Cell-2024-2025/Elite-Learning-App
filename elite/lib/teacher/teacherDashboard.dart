
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elite/teacher/diary.dart';
import 'package:elite/teacher/markAttendance.dart';
import 'package:elite/teacher/studentattendance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../startpage.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  late var stand = '';
  @override
  void initState() {
    super.initState();
    standard();
  }
  void standard() async{
    final teacher = FirebaseAuth.instance.currentUser?.email;
    final teacherData = await FirebaseFirestore.instance.collection('teacher').doc(teacher).get();
    setState(() {
      stand = teacherData['standard'];
    });

  }

  Future<void> signOut() async {
    // Show confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sign Out"),
          content: Text("Are you sure you want to sign out?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text("Sign Out"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('isTeacher');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logged out successfully"),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => StartPage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text(
          'Teacher',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: signOut,
          ),
        ],
    ),
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children:<Widget> [
              DrawerHeader(
              child: Text(
                'Class $stand',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
            ),
              ListTile(
              leading: Icon(Icons.school),
              title: Text('Add attendance',
                style: TextStyle(
                    fontWeight: FontWeight.bold
                ),),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarkAttendance(),
                  ),
                );
              },
            ),
          ListTile(
            leading: Icon(Icons.school),
            title: Text('Add Classwork',
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => diaryTeacher(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.note_alt_sharp),
            title: Text(' Attendance record',
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OverallAttendance(),
                ),
              );
            },
          ),

      ],)
    ),
      body: Center(
        child: Text('Welcome to the Teacher dashboard of $stand'),
      ),
    );
  }
}

