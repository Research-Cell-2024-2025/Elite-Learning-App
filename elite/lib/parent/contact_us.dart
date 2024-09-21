import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBEEFF),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'About Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('aboutUs').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No data available.'));
            }

            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Container
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      margin: EdgeInsets.fromLTRB(15, 15, 15, 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        doc['title'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Body Container
                    Container(
                      width: MediaQuery.sizeOf(context).width,
                      margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        doc['about'],
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
