import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Import the PDF viewer package
import 'package:path_provider/path_provider.dart';

class AddTimeTable extends StatefulWidget {
  const AddTimeTable({super.key});

  @override
  State<AddTimeTable> createState() => _AddTimeTableState();
}

class _AddTimeTableState extends State<AddTimeTable> {
  String? uploadStatus;
  bool isUploading = false;
  String _standard = 'Jr.KG';
  String? timetableUrl;
  File? pdfFile;

  @override
  void initState() {
    super.initState();
    _fetchTimetableUrl(_standard);
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
      String filePath = 'Timetable/$_standard/Time.pdf';
      final storageRef = FirebaseStorage.instance.ref(filePath);
      await storageRef.putFile(file);
      final String downloadURL = await storageRef.getDownloadURL();

      setState(() {
        uploadStatus = 'File uploaded successfully! Download URL: $downloadURL';
        timetableUrl = downloadURL;
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

  Future<void> _fetchTimetableUrl(String standard) async {
    try {
      String filePath = 'Timetable/$standard/Time.pdf';
      final storageRef = FirebaseStorage.instance.ref(filePath);

      try {
        String downloadURL = await storageRef.getDownloadURL();
        setState(() {
          timetableUrl = downloadURL;
          pdfFile = null; // Reset PDF file
        });

        // Optionally, you can download the file to view it directly
        await _downloadPdf(downloadURL);
      } catch (e) {
        setState(() {
          timetableUrl = null;
        });
      }
    } catch (e) {
      setState(() {
        timetableUrl = null;
        uploadStatus = 'Error fetching timetable: $e';
      });
    }
  }

  Future<void> _downloadPdf(String url) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp.pdf';
      final response = await HttpClient().getUrl(Uri.parse(url));
      final file = await response.close();
      final bytes = await consolidateHttpClientResponseBytes(file);
      final tempFile = File(filePath);
      await tempFile.writeAsBytes(bytes);
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
          'Add Timetable',
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
            Container(
              margin: EdgeInsets.all(10),
              child: DropdownButtonFormField<String>(
                value: _standard,
                items: ['Jr.KG', 'UKG', 'Day Care', 'PG', 'Nursery'].map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (newval) {
                  setState(() {
                    _standard = newval!;
                    timetableUrl = null;
                    pdfFile = null;
                    _fetchTimetableUrl(newval);
                  });
                },
                decoration: InputDecoration(labelText: 'Standard'),
              ),
            ),
            SizedBox(height: 20),
            if (pdfFile != null) ...[
              Text(
                'Timetable for $_standard:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Expanded(
                child: PDFView(
                  filePath: pdfFile!.path,
                ),
              ),
            ] else if (timetableUrl != null && !isUploading) ...[
              Text(
                'Timetable available. Please download it to view.',
                style: TextStyle(color: Colors.blue),
              ),
            ] else if (timetableUrl == null && !isUploading) ...[
              Text(
                'No timetable found for $_standard.',
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
