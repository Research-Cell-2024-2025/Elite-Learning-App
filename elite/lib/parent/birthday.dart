import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth_tokens/tokens.dart';
import '../login_page.dart';

class Birthday extends StatefulWidget {
  const Birthday({super.key});

  @override
  State<Birthday> createState() => _BirthdayState();
}

class _BirthdayState extends State<Birthday> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    checkBirthdaysAndSendNotifications();
  }

  Future<void> checkBirthdaysAndSendNotifications() async {
    final String today = "${now.day}-${now.month}";
    try {
      QuerySnapshot snapshot = await firestore.collection('students').get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('dob')) {
          DateTime dob = (data['dob'] as Timestamp).toDate();
          String dobString = "${dob.day}-${dob.month}";
          if (dobString == today) {
            String name = data['name'];
            await sendTopicMessage(name);
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendTopicMessage(String name) async {
    final String accessToken = await getAccessToken();
    const url = 'https://fcm.googleapis.com/v1/projects/elitenew-f0b99/messages:send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    final body = jsonEncode({
      'message': {
        'topic': 'birthdays',
        'notification': {
          'body': "Today is ${name}'s birthday",
          'title': 'Happy Birthday'
        }
      }
    });

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Failed to send message: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    await FirebaseFirestore.instance.collection('birthday').doc().set({
      'name': name,
      'message': "Today is $name's birthday",
      'title': 'Happy Birthday',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('Birthday Reminder'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firestore.collection('birthday').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> birthdays = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: birthdays.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map<String, dynamic> birthdayData =
                        birthdays[index].data() as Map<String, dynamic>;
                    String name = birthdayData['name'];
                    String message = birthdayData['message'];

                    return ListTile(
                      leading: Icon(Icons.cake),
                      title: Text(name),
                      subtitle: Text(message),
                    );
                  },
                );
              },
            ),
          ),
          // ElevatedButton(
          //   onPressed: () => sendTopicMessage('hi'),
          //   child: Icon(Icons.send),
          // ),
        ],
      ),
    );
  }
}
