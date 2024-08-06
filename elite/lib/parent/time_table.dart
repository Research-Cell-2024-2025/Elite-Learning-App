import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeTable extends StatelessWidget {
  Future<QuerySnapshot> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final std = await prefs.getString('standard');
    print(std);

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('timetable')
        .where('standard' ,isEqualTo:  std.toString() )
        .get();

    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,

        title: Text('Time Table'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<QuerySnapshot>(
          future: fetchData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasData) {
              QuerySnapshot data = snapshot.data!;

              return SingleChildScrollView(
                child: Column(
                  children: data.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    String branch = data['branch'];
                    String standard = data['standard'];
                    String batch = data['batch'];
                    String filename = data['filename'];

                    // Only show the image for the desired standard
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.memory(base64Decode(data["filename"])),
                    );
                    // Return an empty container if the standard doesn't match your criteria
                  }).toList(),
                ),
              );
            }
            return Text('No data available');
          },
        ),
      ),
    );
  }
}
