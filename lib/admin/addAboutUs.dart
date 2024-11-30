import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final _titleController = TextEditingController();
  final _aboutController = TextEditingController();
  PlatformFile? _ownerImage;
  PlatformFile? _directorImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isOwner) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          if (isOwner) {
            _ownerImage = result.files.first;
          } else {
            _directorImage = result.files.first;
          }
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error picking file: $e');
    }
  }

  Future<String?> _uploadFile(PlatformFile? file, String fileName) async {
    if (file == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child('aboutUs/$fileName');
      final uploadTask = ref.putFile(File(file.path!));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _showErrorSnackBar('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      String title = _titleController.text.trim();
      String about = _aboutController.text.trim();

      if (title.isEmpty || about.isEmpty) {
        throw 'Please fill in all text fields.';
      }

      String? ownerImageUrl = await _uploadFile(
          _ownerImage, 'owner_image.${_ownerImage?.extension ?? 'jpg'}');
      String? directorImageUrl = await _uploadFile(_directorImage,
          'director_image.${_directorImage?.extension ?? 'jpg'}');

      await FirebaseFirestore.instance
          .collection('aboutUs')
          .doc('default')
          .set({
        'title': title,
        'about': about,
        'ownerImageUrl': ownerImageUrl,
        'directorImageUrl': directorImageUrl,
      });

      _titleController.clear();
      _aboutController.clear();
      setState(() {
        _ownerImage = null;
        _directorImage = null;
      });

      _showSuccessSnackBar('Data submitted successfully!');
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('About Us', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: Colors.black),
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.purple),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              style: TextStyle(color: Colors.black),
              controller: _aboutController,
              maxLines: 5,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                labelText: 'Body',
                labelStyle: TextStyle(color: Colors.purple),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickFile(true),
              child: Text('Select Owner Image'),
            ),
            if (_ownerImage != null)
              Text('Owner image selected: ${_ownerImage!.name}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickFile(false),
              child: Text('Select Director Image'),
            ),
            if (_directorImage != null)
              Text('Director image selected: ${_directorImage!.name}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading ? CircularProgressIndicator() : Text('Submit'),
            ),
            SizedBox(height: 20),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('aboutUs')
                  .doc('default')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('No data available');
                }
                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? '',
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(data['about'] ?? ''),
                    SizedBox(height: 20),
                    if (data['ownerImageUrl'] != null)
                      Image.network(
                        data['ownerImageUrl'],
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            Text('Failed to load owner image'),
                      ),
                    SizedBox(height: 10),
                    if (data['directorImageUrl'] != null)
                      Image.network(
                        data['directorImageUrl'],
                        height: 100,
                        errorBuilder: (context, error, stackTrace) =>
                            Text('Failed to load director image'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
