import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  String? path;

  @override
  void initState() {
    super.initState();
    fetchTimeTable();
  }

  Future<void> fetchTimeTable() async {
    try {
      String filePath = 'Timetable/Time.pdf';
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
