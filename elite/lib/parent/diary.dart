import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
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
    final stand = await FirebaseFirestore.instance.collection('students').doc(user!.email).get();
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
        title: Text('Diary'),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
              stream: FirebaseFirestore.instance.collection('diary').where('standard',isEqualTo: standard).snapshots(),
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
