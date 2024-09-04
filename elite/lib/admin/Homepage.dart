import 'package:elite/admin/addEvent.dart';
import 'package:elite/admin/addTimetable.dart';
import 'package:elite/admin/announcements.dart';
import 'package:elite/admin/carouselimg.dart';
import 'package:elite/admin/createTeacher.dart';
import 'package:elite/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_page.dart';
import 'Studentform.dart';
import 'display.dart';
import 'package:elite/admin/Studentform.dart';
import 'package:elite/admin/addFeespage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  late final bool isAdmin;


  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    // Optionally, you can also clear the isTeacher preference if you want
    await prefs.remove('isTeacher');

    // Navigate back to StartPage after signing out
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StartPage()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('Home'),
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
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(
                color: Colors.purple,
              ),
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Go to Student Form'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentFormScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('Go to Student List'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentListPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add announcements'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => announcements()));
              }
            ),
             ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Event'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEvents()));
              }
            ),
            ListTile(
                leading: Icon(Icons.add),
                title: Text('Add Images'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Images()));
                }
            ),
            ListTile(
                leading: Icon(Icons.add),
                title: Text('Add a Student Fee'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddFeesPage()));
                }
            ),
            ListTile(
                leading: Icon(Icons.add),
                title: Text('Add TimeTable'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddTimeTable()));
                }
            ),
                        ListTile(
                leading: Icon(Icons.add),
                title: Text('Add Teacher'),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Createteacher()));
                }
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to the Home Page'),
      ),
    );
  }
}
