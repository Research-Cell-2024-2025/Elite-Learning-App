import 'package:elite/admin/addEvent.dart';
import 'package:elite/admin/announcements.dart';
import 'package:elite/admin/carouselimg.dart';
import 'package:flutter/material.dart';
import '../login_page.dart';
import 'Studentform.dart';
import 'display.dart';
import 'package:elite/admin/Studentform.dart';

class HomePage extends StatelessWidget {
  final bool isAdmin;

  HomePage({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
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
                    builder: (context) => StudentListPage(isAdmin: isAdmin),
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
          ],
        ),
      ),
      body: Center(
        child: Text('Welcome to the Home Page'),
      ),
    );
  }
}
