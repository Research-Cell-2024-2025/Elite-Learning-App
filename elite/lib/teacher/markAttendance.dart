import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({super.key});

  @override
  State<MarkAttendance> createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  late List<bool> isSelectedList;
  late AsyncSnapshot<QuerySnapshot> _snapshot;
  final _id = FirebaseAuth.instance.currentUser!.email;
  String standard = "";

  @override
  void initState() {
    super.initState();
    isSelectedList = [];
    teacherRole();
    checkAttendanceStatus();
  }

  void teacherRole() async {
    try {
      DocumentSnapshot user = await FirebaseFirestore.instance.collection('teacher').doc(_id).get();
      setState(() {
        standard = user.get("standard");
      });
      print(standard);
    } catch (e) {
      print('Error fetching teacher role: $e');
    }
  }
  bool isAttendanceMarkedToday = false; // Variable to track today's attendance status

  void checkAttendanceStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toLocal().toIso8601String().split('T')[0]; // YYYY-MM-DD format
    final lastMarkedDate = prefs.getString('lastMarkedDate') ?? '';

    if (today == lastMarkedDate) {
      setState(() {
        isAttendanceMarkedToday = true;
      });
    } else {
      setState(() {
        isAttendanceMarkedToday = false;
      });
    }
  }
  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Submission'),
          content: const Text('Are you sure you want to submit the attendance?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss dialog
                await _submitAttendance();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAttendance() async {
    for (int i = 0; i < isSelectedList.length; i++) {
      if (isSelectedList[i]) {
        String userEmail = (_snapshot.data!.docs[i].data() as Map<String, dynamic>)?['email'] ?? '';
        await updateFirestore(userEmail, true);
      } else {
        String userEmail = (_snapshot.data!.docs[i].data() as Map<String, dynamic>)?['email'] ?? '';
        await updateFirestore(userEmail, false);
      }
    }

    // Update last marked date
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toLocal().toIso8601String().split('T')[0];
    await prefs.setString('lastMarkedDate', today);

    setState(() {
      isAttendanceMarkedToday = true;
    });

    Navigator.pop(context);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        title: Text(
          'Mark Attendance',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('students').where('standard', isEqualTo: standard).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                _snapshot = snapshot; 
                List<DocumentSnapshot> students = snapshot.data!.docs;
                if (isSelectedList.length != students.length) {
                  isSelectedList = List.generate(students.length, (index) => false);
                }
                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (BuildContext context, int index) {
                    String userName = 'No name';
                    try {
                      var name = (students[index].data() as Map<String, dynamic>?)?['student_name'] ?? '';
                      if (name != null) {
                        userName = name.toString();
                      }
                    } catch (e) {
                      print('Error: $e');
                    }
                    return Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurStyle: BlurStyle.normal,
                            blurRadius: 10.0,
                            color: Colors.grey,
                            spreadRadius: 0.0,
                            offset: const Offset(0.0, 3.0),
                          ),
                        ],
                        color: Colors.purple,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                      child: ListTile(
                        tileColor: Colors.purple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        title: Row(
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Switch(
                              value: isSelectedList[index],
                              onChanged: (bool value) {
                                setState(() {
                                  isSelectedList[index] = value;
                                });
                              },
                              activeColor: Colors.greenAccent,
                              inactiveTrackColor: Colors.red,
                              inactiveThumbColor: Colors.white,
                            ),
                            Text(
                              isSelectedList[index] ? 'Present' : 'Absent',
                              style: TextStyle(
                                color: isSelectedList[index] ? Colors.greenAccent : Colors.red,
                                fontWeight: FontWeight.bold,


                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.purple),
              ),
              onPressed: () {
                if (isAttendanceMarkedToday) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Attendance has already been marked today.')),
                  );
                } else {
                  _showConfirmationDialog();
                }
              },
              child: Text(
                'SUBMIT',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> updateFirestore(String email, bool isPresent) async {
    try {
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('email', isEqualTo: email)
          .get();

      final now = DateTime.now();
      final dateString = "${now.day}-${now.month}-${now.year}";

      if (studentSnapshot.docs.isNotEmpty) {
        DocumentSnapshot studentDoc = studentSnapshot.docs.first;
        final data = studentDoc.data() as Map<String, dynamic>;
        int currentAttendance = data.containsKey('attendance') ? data['attendance'] : 0;
        List<dynamic> presentDates = data.containsKey('presentDates') ? List.from(data['presentDates']) : [];
        List<dynamic> absentDates = data.containsKey('absentDates') ? List.from(data['absentDates']) : [];
        await studentDoc.reference.set({
          'attendance': isPresent ? currentAttendance + 1 : currentAttendance,
          'presentDates': isPresent ? (presentDates..add(dateString)) : presentDates,
          'absentDates': !isPresent ? (absentDates..add(dateString)) : absentDates,
        }, SetOptions(merge: true));
      } else {
        await FirebaseFirestore.instance.collection('students').doc(email).set({
          'attendance': isPresent ? 1 : 0,
          'presentDates': isPresent ? [dateString] : [],
          'absentDates': !isPresent ? [dateString] : [],
        });
      }
      await updateTotalLectures(standard);
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  Future<void> updateTotalLectures(String standard) async {
    try {
      DocumentReference totalLecturesRef = FirebaseFirestore.instance
          .collection('total_lectures')
          .doc(standard);

      DocumentSnapshot totalLecturesDoc = await totalLecturesRef.get();

      if (!totalLecturesDoc.exists) {
        await totalLecturesRef.set({
          'count': 1,
        });
      } else {
        int totalLectures = (totalLecturesDoc.data() as Map<String, dynamic>).containsKey('count')
            ? totalLecturesDoc.get('count')
            : 0;
        await totalLecturesRef.set({
          'count': totalLectures + 1,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating total lectures: $e');
    }
  }
}
