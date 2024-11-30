import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Createteacher extends StatefulWidget {
  const Createteacher({super.key});

  @override
  State<Createteacher> createState() => _CreateteacherState();
}

class _CreateteacherState extends State<Createteacher> {
    final FirebaseAuth _auth = FirebaseAuth.instance;
      final _key = GlobalKey<FormState>();

      final _firestore = FirebaseFirestore.instance.collection('teacher');
  TextEditingController _teacherName = TextEditingController();
  TextEditingController _teacherEmail = TextEditingController();
  TextEditingController _teacherPassword = TextEditingController();
  TextEditingController _teacherPhoneNumber = TextEditingController();
    String _selectedGender = 'Male';
  String _selectedStandard = 'Nursery';
  bool _showPassword = false;

  Future<void> add() async {
    try{
      final userData = await _auth.createUserWithEmailAndPassword(
        email: _teacherEmail.text,
        password: _teacherPassword.text,
      );
      final user = userData.user;
      if(user != null){
        final teacherData = {
          'name': _teacherName.text,
          'email': _teacherEmail.text,
          'password': _teacherPassword.text,
          'phoneNumber': _teacherPhoneNumber.text,
          'gender': _selectedGender,
         'standard': _selectedStandard,
         'role': "teacher",
         'uid': user.uid,
        };
          await _firestore.doc(user.email).set(teacherData);
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher created successfully!')),
        );
        _key.currentState!.reset();    
        }


    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error occurred while creating Teacher")));
         }
  }
      void _submitForm() {
    if (_key.currentState!.validate()) {
      add();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('Personal Information Form',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),),
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
           TextFormField(
                  obscureText: _showPassword,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _teacherPassword,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    label: Text('Password'),
                  ),
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
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
