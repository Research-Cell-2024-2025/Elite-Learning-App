import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AddEvents extends StatefulWidget {
  const AddEvents({super.key});

  @override
  State<AddEvents> createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {
  String? uploadStatus;
  Future<void> pickAndUploadPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      await uploadPdfFile(file);
    } else {
      setState(() {
        uploadStatus = 'No file selected';
      });
    }
  }

  Future<void> uploadPdfFile(File file) async {
    try {
      String filePath = 'events/one.pdf';
      final storageRef = FirebaseStorage.instance.ref(filePath);
      await storageRef.putFile(file);
      final String downloadURL = await storageRef.getDownloadURL();
      print('File uploaded successfully! Download URL: $downloadURL');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text(
          'Add Events',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: pickAndUploadPdf,
              child: Text('Pick and Upload PDF'),
            ),
            if (uploadStatus != null) ...[
              SizedBox(height: 20),
              Text(uploadStatus!),
            ],
          ],
        ),
      ),
    );
  }
}
