import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';// Add this import for date formatting

class EditStudentPage extends StatefulWidget {
  final String studentId;

  EditStudentPage({required this.studentId});

  @override
  _EditStudentPageState createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance.collection('students');
  final _studentNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
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

  String _selectedGender = 'Male';
  String _selectedStandard = 'Jr.KG';
  String _selectedNationality = 'Indian';

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final studentDoc = await _firestore.doc(widget.studentId).get();
    final studentData = studentDoc.data() as Map<String, dynamic>;

    setState(() {
      _enrollmentCodeController.text = studentData['enrollment_code'] ?? '';
      _studentNameController.text = studentData['student_name'] ?? '';
      _fatherNameController.text = studentData['father_name'] ?? '';
      _motherNameController.text = studentData['mother_name'] ?? '';
      _dobController.text = studentData['dob'] ?? '';
      _addressController.text = studentData['address'] ?? '';
      _emailController.text = studentData['email'] ?? '';
      _fatherPhoneController.text = studentData['father_phone'] ?? '';
      _motherPhoneController.text = studentData['mother_phone'] ?? '';
      _relativePhoneController1.text = studentData['relative_phone1'] ?? '';
      _relativePhoneController2.text = studentData['relative_phone2'] ?? '';
      _relativePhoneController3.text = studentData['relative_phone3'] ?? '';
      _relativeRelationController1.text = studentData['relative_relation1'] ?? '';
      _relativeRelationController2.text = studentData['relative_relation2'] ?? '';
      _relativeRelationController3.text = studentData['relative_relation3'] ?? '';
      _guardianNameController.text = studentData['guardian_name'] ?? '';
      _guardianPhoneController.text = studentData['guardian_phone'] ?? '';
      _guardianEmailController.text = studentData['guardian_email'] ?? '';
      _relative1nameController.text = studentData['relative1_name'] ?? '';
      _relative2nameController.text = studentData['relative2_name'] ?? '';
      _relative3nameController.text = studentData['relative3_name'] ?? '';
      _guardianRelationController.text = studentData['guardian_relation'] ?? '';
      _selectedGender = studentData['gender'] ?? 'Male';
      _selectedStandard = studentData['standard'] ?? 'Jr.KG';
      _selectedNationality = studentData['nationality'] ?? 'Indian';
      if (_selectedNationality != 'Indian' && _selectedNationality != 'Others') {
        _nationalityController.text = _selectedNationality;
        _selectedNationality = 'Others';
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final updatedStudentData = {
        'student_name': _studentNameController.text,
        'father_name': _fatherNameController.text,
        'mother_name': _motherNameController.text,
        'dob': _dobController.text,
        'nationality': _selectedNationality == 'Others' ? _nationalityController.text : _selectedNationality,
        'address': _addressController.text,
        'email': _emailController.text,
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
        'gender': _selectedGender,
        'standard': _selectedStandard,
      };

      _firestore.doc(widget.studentId).update(updatedStudentData).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student information updated successfully!')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update student information: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('Edit Student Information'),
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
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Enrollment Code'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Enrollment code';
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
                TextFormField(
                  controller: _dobController,
                  readOnly: true, // Make the field read-only
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter date of birth';
                    }
                    return null;
                  },
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
                      if (value!.isEmpty) {
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
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter mother phone number';
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
                        keyboardType: TextInputType.number,
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
                        keyboardType: TextInputType.number,
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
                  child: Text('Guardian details (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: _saveChanges,
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
