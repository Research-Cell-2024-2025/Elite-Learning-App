import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditTeacher extends StatefulWidget {
  final String email; // Pass the email of the teacher to edit

  const EditTeacher({super.key, required this.email});

  @override
  State<EditTeacher> createState() => _EditTeacherState();
}

class _EditTeacherState extends State<EditTeacher> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _key = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance.collection('teacher');

  TextEditingController _teacherName = TextEditingController();
  TextEditingController _teacherEmail = TextEditingController();
  TextEditingController _teacherPhoneNumber = TextEditingController();
  TextEditingController _teacherPassword = TextEditingController();
  String _selectedGender = 'Male';
  String _selectedStandard = 'Nursery';
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    DocumentSnapshot documentSnapshot = await _firestore.doc(widget.email).get();
    if (documentSnapshot.exists) {
      var data = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _teacherName.text = data['name'];
        _teacherEmail.text = data['email'];
        _teacherPhoneNumber.text = data['phoneNumber'];
        _selectedGender = data['gender'];
        _selectedStandard = data['standard'];
      });
    }
  }


  Future<void> update() async {
    try {
      final teacherData = {
        'name': _teacherName.text,
        'email': _teacherEmail.text,
        'phoneNumber': _teacherPhoneNumber.text,
        'gender': _selectedGender,
        'standard': _selectedStandard,
      };
      await _firestore.doc(widget.email).update(teacherData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Teacher updated successfully!')),
      );
      _key.currentState!.reset();
    } catch (e) {
      throw Exception(e);
    }
  }

  void _submitForm() {
    if (_key.currentState!.validate()) {
      update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text(
          'Edit Teacher Information',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _key,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _teacherName,
                  decoration: InputDecoration(labelText: "Teacher's Name"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Teacher name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _teacherEmail,
                  decoration: InputDecoration(labelText: "Teacher's Email"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter Teacher's Email";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _teacherPhoneNumber,
                  decoration: InputDecoration(labelText: "Teacher's phone number"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter Teacher's phone number";
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedStandard,
                  items: ['Jr.KG', 'UKG', 'Day Care', 'PG', 'Nursery'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStandard = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Standard'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: ['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
