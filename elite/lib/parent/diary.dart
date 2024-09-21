import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:intl/intl.dart';
import '../auth_tokens/tokens.dart';
import 'package:http/http.dart' as http;

class diary extends StatefulWidget {
  const diary({super.key});

  @override
  State<diary> createState() => _diaryState();
}

class _diaryState extends State<diary> {
  String standard = "";
  @override
  void initState() {
    super.initState();
    fetchstandard();
  }

  Future<void> fetchstandard() async {
    final user = FirebaseAuth.instance.currentUser;
    final stand = await FirebaseFirestore.instance
        .collection('students')
        .doc(user!.email)
        .get();
    setState(() {
      standard = stand.data()!['standard'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text(
          'Diary',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('diary')
                  // .orderBy('date', descending: true)
                  .where('standard', isEqualTo: standard)

                  .snapshots(),
              builder: (context, snapshots) {
                if (!snapshots.hasData) {
                  return Center(child: const CircularProgressIndicator());
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
                      title: Text(
                        title,
                        style: TextStyle(
                            color: Colors.purple, fontWeight: FontWeight.bold),
                      ),
                      subtitle:  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(description),
                          SizedBox(height: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
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
