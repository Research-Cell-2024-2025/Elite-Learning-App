import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeRecordsPage extends StatefulWidget {
  const FeeRecordsPage({super.key});

  @override
  State<FeeRecordsPage> createState() => _FeeRecordsPageState();
}

class _FeeRecordsPageState extends State<FeeRecordsPage> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _feeRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchFeeRecords();
  }

  void _fetchFeeRecords() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final data = await _firestore.collection('students').doc(currentUser!.email).get();
    final ecode = currentUser!.email;

    final snapshot = await _firestore
        .collection('feesRecord')
        .doc(currentUser.email)
        .collection('feeRecords')
        .orderBy('timestamp',descending: false)
        .get();

    setState(() {
      _feeRecords = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text('Fee Records'),
      ),
      body: _feeRecords.isEmpty
          ? Center(child: Text("No fee records yet"))
          : ListView.builder(
        itemCount: _feeRecords.length,
        itemBuilder: (context, index) {

          final record = _feeRecords[index];
          Timestamp timestamp = record['timestamp'];
          DateTime date = timestamp.toDate();
          String formattedDate =
          DateFormat('MMM d, yyyy - h:mm a').format(date);
          return Card(
            shadowColor: Colors.grey,

            margin: EdgeInsets.symmetric(vertical: 20,horizontal: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Name: ${record['student_name']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Admission No: ${record['admission_no']}'),
                  Text('Class: ${record['class']}'),
                  Text('Academic Year: ${record['academic_year']}'),
                  Text('Fee Type: ${record['fee_type']}'),
                  Text('Installment: ${record['installment_name']}'),
                  Text('Total Fee Amount: ₹${record['total_fee_amount']}'),
                  Text('Balance Amount: ₹${record['balance_amount']}'),
                  Text('Late Fees: ₹${record['late_fees']}'),
                  Text('Paid Amount: ₹${record['paid_amount']}'),
                  Text('Payment Mode: ${record['payment_mode']}'),
                  Text('Payment Date: ${record['payment_date']}'),
                  Text('Payment Receipt No: ${record['payment_reciept_no']}'),
                  Text('Due Date: ${record['due_date']}'),
                  Text(
                    'Payment Status: ${record['payment_status']}',
                    style: TextStyle(
                      color: record['payment_status'] == 'Successful'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(),
                      Text('${formattedDate}'),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
