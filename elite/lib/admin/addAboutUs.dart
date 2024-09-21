import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final _titleController = TextEditingController();
  final _aboutController = TextEditingController();

  Future<void> _submit() async {
    String title = _titleController.text.trim();
    String about = _aboutController.text.trim();

    if (title.isNotEmpty && about.isNotEmpty) {
      await FirebaseFirestore.instance.collection('aboutUs').doc('default').set({
        'title': title,
        'about': about,
      });

      // Clear the text fields
      _titleController.clear();
      _aboutController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('About Us',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      color: Colors.purple,
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
            SizedBox(height: 20),

            TextField(
              style: TextStyle(
                color: Colors.black,
              ),
              keyboardType: TextInputType.text,
              controller: _aboutController,
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Submit'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('aboutUs')
                    .snapshots(),
                builder: (context, snapshots) {
                  if (!snapshots.hasData) {
                    return CircularProgressIndicator();
                  }
                  List<DocumentSnapshot> announcements = snapshots.data!.docs;
                  return ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                      announcements[index].data() as Map<String, dynamic>;
                      String title = data['title'];
                      String description = data['about'];
                      return ListTile(
                        leading: Icon(Icons.announcement,color: Colors.purple,),
                        title: Text(title,
                          style: TextStyle(color: Colors.purple,
                              fontWeight: FontWeight.bold),),
                        subtitle: Text(description
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
