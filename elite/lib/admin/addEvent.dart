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
  List<Map<String, String>> eventFiles = [];

  @override
  void initState() {
    super.initState();
    fetchEventFiles();
  }

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
      String fileName = 'events/${DateTime.now().millisecondsSinceEpoch}.pdf';
      final storageRef = FirebaseStorage.instance.ref(fileName);
      await storageRef.putFile(file);
      final String downloadURL = await storageRef.getDownloadURL();
      print('File uploaded successfully! Download URL: $downloadURL');
      fetchEventFiles();  // Refresh the event list
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchEventFiles() async {
    final storageRef = FirebaseStorage.instance.ref('events/');
    final ListResult result = await storageRef.listAll();
    final List<Map<String, String>> files = [];

    for (var ref in result.items) {
      final String url = await ref.getDownloadURL();
      files.add({'name': ref.name, 'url': url});
    }

    setState(() {
      eventFiles = files;
    });
  }

  Future<void> deleteEventFile(String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref('events/$fileName');
      await storageRef.delete();
      print('File deleted successfully!');
      fetchEventFiles();  // Refresh the event list
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
      body: Column(
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
          Expanded(
            child: ListView.builder(
              itemCount: eventFiles.length,
              itemBuilder: (context, index) {
                final file = eventFiles[index];
                return ListTile(
                  title: Text(file['name']!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteEventFile(file['name']!),
                  ),
                  onTap: () {
                    // Handle file tap, e.g., open the file URL
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
