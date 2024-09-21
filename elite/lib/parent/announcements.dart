import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:intl/intl.dart';
import '../auth_tokens/tokens.dart';
import 'package:http/http.dart' as http;

class parentAnnouncements extends StatefulWidget {
  const parentAnnouncements({super.key});

  @override
  State<parentAnnouncements> createState() => _parentAnnouncementsState();
}

class _parentAnnouncementsState extends State<parentAnnouncements> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('Announcements',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
              stream: FirebaseFirestore.instance.collection('announcements')
            .orderBy('date', descending: true)
          .snapshots(),
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
                    Timestamp timestamp = data['date'];
                    DateTime date = timestamp.toDate();
                    String formattedDate =
                    DateFormat('MMM d, yyyy - h:mm a').format(date);
                    return ListTile(
                      leading: Icon(Icons.announcement,color: Colors.purple,),
                      title: Text(title,
                        style: TextStyle(color: Colors.purple,
                        fontWeight: FontWeight.bold) ,),
                      subtitle:Row(
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
                    ),

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
