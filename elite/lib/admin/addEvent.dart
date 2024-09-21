import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Import the PDF viewer package
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AddEvents extends StatefulWidget {
  const AddEvents({super.key});

  @override
  State<AddEvents> createState() => _AddEventsState();
}

class _AddEventsState extends State<AddEvents> {
  String? uploadStatus;
  bool isUploading = false;
  String? eventUrl;
  File? pdfFile;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Ensure Firebase is initialized
    _fetchEventUrl(); // Fetch event URL on initialization
  }

  Future<void> pickAndUploadPdf() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        uploadStatus = null; // Reset status before uploading
        isUploading = true;
      });
      await uploadPdfFile(file);
    } else {
      setState(() {
        uploadStatus = 'No file selected';
      });
    }
  }

  Future<void> uploadPdfFile(File file) async {
    try {
      String filePath = 'events/Time.pdf'; // Use a static path for events
      final storageRef = FirebaseStorage.instance.ref(filePath);
      await storageRef.putFile(file);
      final String downloadURL = await storageRef.getDownloadURL();

      setState(() {
        uploadStatus = 'File uploaded successfully! Download URL: $downloadURL';
        eventUrl = downloadURL;
        pdfFile = null; // Reset PDF file
      });

      // Optionally, you can download the file to view it directly
      await _downloadPdf(downloadURL);
    } catch (e) {
      setState(() {
        uploadStatus = 'Error uploading file: $e';
      });
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> _fetchEventUrl() async {
    try {
      String filePath = 'events/one.pdf'; // Use a static path for events
      final storageRef = FirebaseStorage.instance.ref(filePath);

      try {
        String downloadURL = await storageRef.getDownloadURL();
        setState(() {
          eventUrl = downloadURL;
          pdfFile = null; // Reset PDF file
        });

        // Optionally, you can download the file to view it directly
        await _downloadPdf(downloadURL);
      } catch (e) {
        setState(() {
          eventUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        eventUrl = null;
        uploadStatus = 'Error fetching event: $e';
      });
    }
  }

  Future<void> _downloadPdf(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp.pdf';
      final tempFile = File(filePath);
      await tempFile.writeAsBytes(response.bodyBytes);

      setState(() {
        pdfFile = tempFile;
      });
    } catch (e) {
      setState(() {
        uploadStatus = 'Error downloading PDF: $e';
      });
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            if (pdfFile != null) ...[
              Text(
                'Event PDF:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: PDFView(
                  filePath: pdfFile!.path,
                ),
              ),
            ] else if (eventUrl != null && !isUploading) ...[
              Text(
                'PDF available. Please download it to view.',
                style: TextStyle(color: Colors.blue),
              ),
            ] else if (eventUrl == null && !isUploading) ...[
              Text(
                'No PDF found.',
                style: TextStyle(color: Colors.red),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isUploading ? null : pickAndUploadPdf,
              child: isUploading ? CircularProgressIndicator() : Text('Pick and Upload PDF'),
            ),
            if (uploadStatus != null) ...[
              SizedBox(height: 20),
              Text(
                uploadStatus!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: uploadStatus!.contains('Error') ? Colors.red : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
