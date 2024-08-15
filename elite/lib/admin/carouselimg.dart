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
    if (images.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum image limit reached.')),
      );
      return;
    }

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
        setState(() {
          images.add({'name': filename, 'url': downloadLink});
        });
      }
    } catch (e) {
      print("Error Uploading Images: $e ");
    }
  }

  Future<void> deleteImage(String docId, String imageUrl) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('Images').doc(docId).delete();
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      setState(() {
        images.removeWhere((image) => image['url'] == imageUrl);
      });
    } catch (e) {
      print("Error Deleting Image: $e");
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
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Image'),
                              content: Text('Are you sure you want to delete this image?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            String docId = (await FirebaseFirestore.instance
                                .collection('Images')
                                .where('url', isEqualTo: images[index]['url'])
                                .get())
                                .docs.first.id;
                            deleteImage(docId, images[index]['url']);
                          }
                        },
                      ),
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
