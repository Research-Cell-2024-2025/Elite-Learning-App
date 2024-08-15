import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class StudentFormScreen extends StatefulWidget {
  @override
  _StudentFormScreenState createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance.collection('students');

  final _studentNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fatherPhoneController = TextEditingController();
  final _motherPhoneController = TextEditingController();
  final _relativePhoneController1 = TextEditingController();
  final _relativePhoneController2 = TextEditingController();
  final _relativePhoneController3 = TextEditingController();
  final _relativeRelationController1 = TextEditingController();
  final _relativeRelationController2 = TextEditingController();
  final _relativeRelationController3 = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _guardianRelationController = TextEditingController();
  final _relative1nameController = TextEditingController();
  final _relative2nameController = TextEditingController();
  final _relative3nameController = TextEditingController();
  final _enrollmentCodeController = TextEditingController();

  static const String _enrollmentCodeKey = "enrollmentCode";
  String _selectedGender = 'Male';
  String _selectedStandard = 'Jr.KG';
  String _selectedNationality = 'Indian';
  bool _showPassword = false;

  @override
  void dispose() {
    _studentNameController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fatherPhoneController.dispose();
    _motherPhoneController.dispose();
    _relativePhoneController1.dispose();
    _relativePhoneController2.dispose();
    _relativePhoneController3.dispose();
    _relativeRelationController1.dispose();
    _relativeRelationController2.dispose();
    _relativeRelationController3.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianEmailController.dispose();
    _guardianRelationController.dispose();
    _relative1nameController.dispose();
    _relative2nameController.dispose();
    _relative3nameController.dispose();
    _enrollmentCodeController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _loadEnrollmentCode();
  }

  Future<void> _loadEnrollmentCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString(_enrollmentCodeKey);

    if (savedCode != null) {
      _enrollmentCodeController.text = savedCode;
    } else {
      _enrollmentCodeController.text = "EL2425001";
    }
  }

  Future<void> _incrementEnrollmentCode() async {
    setState(() {
      String currentCode = _enrollmentCodeController.text;
      String prefix = currentCode.substring(0, 7);
      int numericPart = int.parse(currentCode.substring(7));

      numericPart++;

      String newCode = '$prefix${numericPart.toString().padLeft(3, '0')}';
      _enrollmentCodeController.text = newCode;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_enrollmentCodeKey, _enrollmentCodeController.text);
  }
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        _dobController.text = formattedDate;
      });
    }
  }
  Future<void> add() async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = userCredential.user;

      if (user != null) {
        final studentData = {
          'enrollment_code': _enrollmentCodeController.text,
          'student_name': _studentNameController.text,
          'father_name': _fatherNameController.text,
          'mother_name': _motherNameController.text,
          'dob': _dobController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'father_phone': _fatherPhoneController.text,
          'mother_phone': _motherPhoneController.text,
          'relative_phone1': _relativePhoneController1.text,
          'relative_phone2': _relativePhoneController2.text,
          'relative_phone3': _relativePhoneController3.text,
          'relative_relation1': _relativeRelationController1.text,
          'relative_relation2': _relativeRelationController2.text,
          'relative_relation3': _relativeRelationController3.text,
          'guardian_name': _guardianNameController.text,
          'guardian_phone': _guardianPhoneController.text,
          'guardian_email': _guardianEmailController.text,
          'guardian_relation': _guardianRelationController.text,
          'relative1_name': _relative1nameController.text,
          'relative2_name': _relative2nameController.text,
          'relative3_name': _relative3nameController.text,
          'gender': _selectedGender,
          'standard': _selectedStandard,
          'nationality': _selectedNationality == 'Others'
              ? _nationalityController.text
              : _selectedNationality,
          'role': 'parent',
          'uid': user.uid,
        };

        await _firestore.doc(user.uid).set(studentData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student information saved successfully!')),
        );
        _formKey.currentState!.reset();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save student information: $error')),
      );
    }
    _incrementEnrollmentCode();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      add();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('Personal Information Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(

                  controller: _enrollmentCodeController,
                  decoration: InputDecoration(labelText: 'Enrollment Code'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter unique enrollment code';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _studentNameController,
                  decoration: InputDecoration(labelText: 'Student Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter student name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _fatherNameController,
                  decoration: InputDecoration(labelText: 'Father Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter father name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _motherNameController,
                  decoration: InputDecoration(labelText: 'Mother Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother name';
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
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _dobController,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter date of birth';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedNationality,
                  items: ['Indian', 'Others'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedNationality = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Nationality'),
                ),
                if (_selectedNationality == 'Others')
                  TextFormField(
                    controller: _nationalityController,
                    decoration: InputDecoration(labelText: 'Specify Nationality'),
                    validator: (value) {
                      if (value!.isEmpty && _selectedNationality == 'Others') {
                        return 'Please specify nationality';
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  controller: _addressController,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  obscureText: _showPassword,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
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
                TextFormField(
                  controller: _fatherPhoneController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Father Phone'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter father phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _motherPhoneController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Mother Phone'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Emergency contact', style: TextStyle(fontWeight: FontWeight.bold)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Relative 1', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TextFormField(
                        controller: _relative1nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _relativePhoneController1,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Phone'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _relativeRelationController1,
                        decoration: InputDecoration(labelText: 'Relation'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter relation';
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Relative 2 (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TextFormField(
                        controller: _relative2nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        controller: _relativePhoneController2,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Phone'),

                      ),
                      TextFormField(
                        controller: _relativeRelationController2,
                        decoration: InputDecoration(labelText: 'Relation'),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Relative 3 (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TextFormField(
                        controller: _relative3nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),
                      TextFormField(
                        controller: _relativePhoneController3,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Phone'),
                      ),
                      TextFormField(
                        controller: _relativeRelationController3,
                        decoration: InputDecoration(labelText: 'Relation'),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Guardian details', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                TextFormField(
                  controller: _guardianNameController,
                  decoration: InputDecoration(labelText: 'Guardian Name'),
                ),
                TextFormField(
                  controller: _guardianPhoneController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Guardian Phone'),
                ),
                TextFormField(
                  controller: _guardianEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Guardian Email'),
                ),
                TextFormField(
                  controller: _guardianRelationController,
                  decoration: InputDecoration(labelText: 'Relation with Student'),
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
