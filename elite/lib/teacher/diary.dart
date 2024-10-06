import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:intl/intl.dart';
import '../auth_tokens/tokens.dart';
import 'package:http/http.dart' as http;

class diaryTeacher extends StatefulWidget {
  @override
  State<diaryTeacher> createState() => _diaryTeacherState();
}

class _diaryTeacherState extends State<diaryTeacher> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();
  String standard = ' ';
  @override
  void initState() {
    super.initState();
    getStandard();
  }

  Future<void> getStandard() async {
    final _fire = FirebaseFirestore.instance.collection('teacher');
    final user = FirebaseAuth.instance.currentUser;
    try {
      DocumentSnapshot stand = await _fire.doc(user!.email).get();
      Map<String, dynamic>? data = stand.data() as Map<String, dynamic>?;
      String? newStandard = data?['standard'];
      if (newStandard != null) {
        setState(() {
          standard = newStandard;
        });
      } else {
        print("standard is empty for teacher");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
  }

  Future<void> pushNotification(String title, String description) async {
    final String token = await getAccessToken();
    FirebaseFirestore fire = FirebaseFirestore.instance;
    final url =
        "https://fcm.googleapis.com/v1/projects/elitenew-f0b99/messages:send";
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'message': {
        'topic': '${standard}',
        'notification': {
          'title': '${title}',
          'body': '${description}',
        }
      }
    });
    final res = await http.post(Uri.parse(url), headers: headers, body: body);
    if (res.statusCode == 200) {
      print('announcements success');
      await fire.collection('diary').doc().set({
        'title': title,
        'description': description,
        'standard': standard,
        'date': Timestamp.now(),
      });
    }

  }

  Future<void> deleteAnnouncement(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('diary').doc(docId).delete();
      print("Announcement deleted successfully.");
    } catch (e) {
      print("Error deleting announcement: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text(
          'Add Diary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.2),
                      label: Text('Title',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.purple.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    keyboardType: TextInputType.text,
                    controller: _bodyController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.2),
                      label: Text('Body',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.purple.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () => pushNotification(
                          _titleController.text, _bodyController.text),
                      child: Text('Push'))
                ],
              ),
            ),
            Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('diary')
                  .where('standard', isEqualTo: standard)
                  .snapshots(),
              builder: (context, snapshots) {
                if (!snapshots.hasData) {
                  return Container();
                }
                List<DocumentSnapshot> announcements = snapshots.data!.docs;
                return ListView.builder(
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        announcements[index].data() as Map<String, dynamic>;
                    String title = data['title'];
                    String description = data['description'];
                    Timestamp timestamp = data['date'];
                    DateTime date = timestamp.toDate();
                    String formattedDate =
                        DateFormat('MMM d, yyyy - h:mm a').format(date);
                    return ListTile(
                        leading: Icon(
                          Icons.note_alt_sharp,
                          color: Colors.purple,
                        ),
                        trailing:  IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Confirm before deleting
                            bool confirm = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Delete Announcement'),
                                  content: Text(
                                      'Are you sure you want to delete this announcement?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm) {
                              await deleteAnnouncement(
                                  announcements[index].id);
                            }
                          },
                        ),
                        title: Text(
                          title,
                          style: TextStyle(color: Colors.purple),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(description),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ));
                  },
                );
              },
            ))
          ],
        ),
      ),
    ));
  }
}
