import 'package:elite/teacher/markAttendance.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
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
          ),
        ),
    ),
    drawer: Drawer(
      child: ListView(
        children:<Widget> [
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
              title: Text('Add attendance'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarkAttendance(),
                  ),
                );
              },
            ),

      ],)
    ),
    );
  }
}

