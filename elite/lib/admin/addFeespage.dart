import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elite/auth_tokens/tokens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AddFeesPage extends StatefulWidget {
  const AddFeesPage({super.key});

  @override
  State<AddFeesPage> createState() => _AddFeesPageState();
}

class _AddFeesPageState extends State<AddFeesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance.collection('feesRecord');

  final _studentNameController = TextEditingController();
  final _enrollmentCodeController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _admissionNumber = TextEditingController();
  final _classOrSectionController = TextEditingController();
  final _installmentNameController = TextEditingController();
  final _feeTypeController = TextEditingController();
  final _feeAmountController1 = TextEditingController();
  final _paidAmmountController2 = TextEditingController();
  final _ballanceController1 = TextEditingController();
  final _lateFeesController2 = TextEditingController();
  final _dueDateController3 = TextEditingController();
  final _dateOfPaymentController = TextEditingController();
  final _paymentRecieptNoController = TextEditingController();

  String _selectedPaymentMode = 'Cash';
  String _selectedPaymentStatus = 'Successful';
  String _selectedAcademicYear = '2024-25';

  @override
  void dispose() {
    _studentNameController.dispose();
    _enrollmentCodeController.dispose();
    _studentIdController.dispose();
    _admissionNumber.dispose();
    _classOrSectionController.dispose();
    _installmentNameController.dispose();
    _feeTypeController.dispose();
    _feeAmountController1.dispose();
    _paidAmmountController2.dispose();
    _ballanceController1.dispose();
    _lateFeesController2.dispose();
    _dueDateController3.dispose();
    _dateOfPaymentController.dispose();
    _paymentRecieptNoController.dispose();
    super.dispose();
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
        _dateOfPaymentController.text = formattedDate;
      });
    }
  }

  Future<void> _selectDateForDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2035),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        _dueDateController3.text = formattedDate;
      });
    }
  }

  Future<void> add() async {
    try {
      final studentData = {
        'student_name': _studentNameController.text,
        'enrollment_code': _enrollmentCodeController.text,
        'student_id': _studentIdController.text,
        'admission_no': _admissionNumber.text,
        'class': _classOrSectionController.text,
        'academic_year': _selectedAcademicYear,
        'installment_name': _installmentNameController.text,
        'fee_type': _feeTypeController.text,
        'total_fee_amount': _feeAmountController1.text,
        'paid_amount': _paidAmmountController2.text,
        'balance_amount': _ballanceController1.text,
        'late_fees': _lateFeesController2.text,
        'due_date': _dueDateController3.text,
        'payment_date': _dateOfPaymentController.text,
        'payment_mode': _selectedPaymentMode,
        'payment_reciept_no': _paymentRecieptNoController.text,
        'payment_status': _selectedPaymentStatus,
      };

      await _firestore.doc(_enrollmentCodeController.text).set(studentData);
      sendFeesNotification();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student information saved successfully!')),
      );
      _formKey.currentState!.reset();
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save student information: $error')),
      );
    }
  }
  Future<void> sendFeesNotification() async {
    final String accessToken = await getAccessToken();
    FirebaseFirestore fire =  FirebaseFirestore.instance;
    final data = await fire.collection('students').where('enrollment_code', isEqualTo: _enrollmentCodeController.text).get();
    final token = data.docs.first.data()['token'];
    final url = "https://fcm.googleapis.com/v1/projects/elitenew-f0b99/messages:send";
    final headers = {
      'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
    };
    final body = jsonEncode({
      'message': {
        'token':'$token',
        'notification':{
          'title': 'Fees Reminder',
          'body': 'Click here to see fees'
        }
      }
    });
   final result = await http.post(Uri.parse(url),headers: headers ,body: body);
   if(result.statusCode==200){
     print("Fees Reminder sent");
   }
   else{
     print("failed to send");
   }
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
                      return 'Please enter father name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _studentIdController,
                  decoration: InputDecoration(labelText: 'Student Id'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter father name';
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
                // DropdownButtonFormField<String>(
                //   value: _selectedStandard,
                //   items: ['Jr.KG', 'UKG', 'Day Care', 'PG', 'Nursery'].map((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Text(value),
                //     );
                //   }).toList(),
                //   onChanged: (newValue) {
                //     setState(() {
                //       _selectedStandard = newValue!;
                //     });
                //   },
                //   decoration: InputDecoration(labelText: 'Standard'),
                // ),
                // DropdownButtonFormField<String>(
                //   value: _selectedGender,
                //   items: ['Male', 'Female'].map((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Text(value),
                //     );
                //   }).toList(),
                //   onChanged: (newValue) {
                //     setState(() {
                //       _selectedGender = newValue!;
                //     });
                //   },
                //   decoration: InputDecoration(labelText: 'Gender'),
                // ),
                // GestureDetector(
                //   onTap: _selectDate,
                //   child: AbsorbPointer(
                //     child: TextFormField(
                //       controller: _dobController,
                //       decoration: InputDecoration(
                //         labelText: 'Date of Birth',
                //         suffixIcon: Icon(Icons.calendar_today),
                //       ),
                //       validator: (value) {
                //         if (value!.isEmpty) {
                //           return 'Please enter date of birth';
                //         }
                //         return null;
                //       },
                //     ),
                //   ),
                // ),
                // DropdownButtonFormField<String>(
                //   value: _selectedNationality,
                //   items: ['Indian', 'Others'].map((String value) {
                //     return DropdownMenuItem<String>(
                //       value: value,
                //       child: Text(value),
                //     );
                //   }).toList(),
                //   onChanged: (newValue) {
                //     setState(() {
                //       _selectedNationality = newValue!;
                //     });
                //   },
                //   decoration: InputDecoration(labelText: 'Nationality'),
                // ),
                // if (_selectedNationality == 'Others')
                //   TextFormField(
                //     controller: _nationalityController,
                //     decoration: InputDecoration(labelText: 'Specify Nationality'),
                //     validator: (value) {
                //       if (value!.isEmpty && _selectedNationality == 'Others') {
                //         return 'Please specify nationality';
                //       }
                //       return null;
                //     },
                //   ),
                TextFormField(
                  controller: _admissionNumber,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Addmision No'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _classOrSectionController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Class/Section'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                // TextFormField(
                //   obscureText: _showPassword,
                //   keyboardType: TextInputType.visiblePassword,
                //   controller: _passwordController,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter Password';
                //     }
                //     return null;
                //   },
                //   decoration: InputDecoration(
                //     suffixIcon: IconButton(
                //       icon: Icon(
                //         _showPassword
                //             ? Icons.visibility_off
                //             : Icons.visibility,
                //       ),
                //       onPressed: () {
                //         setState(() {
                //           _showPassword = !_showPassword;
                //         });
                //       },
                //     ),
                //     label: Text('Password'),
                //   ),
                // ),

                DropdownButtonFormField<String>(
                  value: _selectedAcademicYear,
                  items: ['2024-25','2025-26','2026-27','2027-28','2028-29','2029-30','2030-31','2031-32','2032-33'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedAcademicYear = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Academic Year'),
                ),


                TextFormField(
                  controller: _installmentNameController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Installment Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter father phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _feeTypeController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Fee Type'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _feeAmountController1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Fee Total Amount'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _paidAmmountController2,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Fee Paid Ammount'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ballanceController1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Balance Amount'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lateFeesController2,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Late Fee',hintText: 'Set as 0 if none'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dueDateController3,
                  decoration: InputDecoration(labelText: 'Due Date'),
                  onTap: _selectDateForDueDate,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateOfPaymentController,
                  onTap: _selectDate,
                  decoration: InputDecoration(labelText: 'Date of Payment'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentMode,
                  items: ['Cash','Online','Check'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPaymentMode = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Payment Mode'),
                ),

                TextFormField(
                  controller: _paymentRecieptNoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Payment Reciept No'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter mother phone number';
                    }
                    return null;
                  },
                ),

                DropdownButtonFormField<String>(
                  value: _selectedPaymentStatus,
                  items: ['Pending', 'Successful','Failed'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPaymentStatus = newValue!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Payment Status'),
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
