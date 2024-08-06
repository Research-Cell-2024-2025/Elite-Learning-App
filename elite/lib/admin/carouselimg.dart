import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';

class Images extends StatefulWidget {
  const Images({super.key});

  @override
  State<Images> createState() => _ImagesState();
}

class _ImagesState extends State<Images> {
  List<Map<String, dynamic>> images = [];

  @override
  void initState() {
    super.initState();
    getImages();
  }

  Future<void> getImages() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await firestore.collection('Images').get();
    setState(() {
      images = snapshot.docs
          .map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  Future<void> filepicker() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles();
    try {
      if (pickedFile != null) {
        File file = File(pickedFile.files.single.path!);
        String filename = pickedFile.files.first.name;
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        TaskSnapshot task = await FirebaseStorage.instance
            .ref("images/$filename")
            .putFile(file);
        String downloadLink = await task.ref.getDownloadURL();
        await firestore.collection('Images').add({
          'name': filename,
          'url': downloadLink, // Store the download URL, not the file
        });
        // Update the images list
        setState(() {
          images.add({'name': filename, 'url': downloadLink});
        });
      }
    } catch (e) {
      print("Error Uploading Images: $e ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carousel Images',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: filepicker,
            child: Text('Add images'),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    children: [
                      Expanded(
                      child: Image.network(images[index]['url']),
                      ),
                      SizedBox(height: 10),
                      Text(images[index]['name']),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
