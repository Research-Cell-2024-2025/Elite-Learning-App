import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class TimeTable extends StatefulWidget {
   // Assume we have the student ID to fetch the standard

  const TimeTable({super.key});

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  String? path;
  String? studentStandard;

  @override
  void initState() {
    super.initState();
    fetchStudentStandardAndTimeTable();
  }

  Future<void> fetchStudentStandardAndTimeTable() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final studentDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.email)
          .get();
      final data = studentDoc.data();

      if (studentDoc.exists) {
        setState(() {
          studentStandard = data?['standard'];
        });
        if (studentStandard != null) {
          await fetchTimeTable(studentStandard!);
        }
      } else {
        print('Student document does not exist.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchTimeTable(String standard) async {
    try {
      String filePath = 'Timetable/$studentStandard/Time.pdf';
      final storageRef = FirebaseStorage.instance.ref(filePath);
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String localPath = '${appDocDir.path}/single_file.pdf';
      await storageRef.writeToFile(File(localPath));
      setState(() {
        path = localPath;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          'TimeTable',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: path == null
          ? Center(child: CircularProgressIndicator())
          : PDFView(
        filePath: path,
      ),
    );
  }
}
