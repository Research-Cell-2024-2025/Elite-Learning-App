import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import '../auth_tokens/tokens.dart';
import 'package:http/http.dart' as http;

class announcements extends StatefulWidget {
  const announcements({super.key});

  @override
  State<announcements> createState() => _announcementsState();
}

class _announcementsState extends State<announcements> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

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
        'topic': 'birthdays',
        'notification': {
          'title': '${title}',
          'body': '${description}',
        }
      }
    });
    final res = await http.post(Uri.parse(url), headers: headers, body: body);
    if (res.statusCode == 200) {
      print('announcements success');
      await fire.collection('announcements').doc().set({
        'title': title,
        'description': description,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text('Add Announcements'),
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
            Expanded(child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
              stream: FirebaseFirestore.instance.collection('announcements').snapshots(),
              builder: (context, snapshots) {
                if(!snapshots.hasData){
                  return CircularProgressIndicator();
                }
                List<DocumentSnapshot> announcements = snapshots.data!.docs;
                return ListView.builder(
                  itemCount: announcements.length,
                  itemBuilder: (context , index){
                    Map<String,dynamic> data = announcements[index].data() as Map<String, dynamic>;
                    String title = data['title'];
                    String description = data['description'];
                    return ListTile(
                      leading: Icon(Icons.announcement),
                      title: Text(title),
                      subtitle: Text(description),
                    );
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
