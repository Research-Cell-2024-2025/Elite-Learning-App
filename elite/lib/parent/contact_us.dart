import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget _buildContainer(BuildContext context, {required Widget child}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildImageContainer(BuildContext context, {required String? imageUrl, required String title}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl != null
                ? Image.network(
              imageUrl,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 150,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) =>
                  Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: Icon(Icons.error, color: Colors.red),
                  ),
            )
                : Container(
              height: 150,
              color: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600], size: 50),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      body: StreamBuilder<QuerySnapshot>(
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
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((doc) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title Container
                  _buildContainer(
                    context,
                    child: Text(
                      doc['title'],
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageContainer(
                          context,
                          imageUrl: doc['ownerImageUrl'],
                          title: 'Founder',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildImageContainer(
                          context,
                          imageUrl: doc['directorImageUrl'],
                          title: 'Director',
                        ),
                      ),
                    ],
                  ),
                  // Body Container
                  SizedBox(height: 16),
                  _buildContainer(
                    context,
                    child: Text(
                      doc['about'],
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Images Section

                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

}