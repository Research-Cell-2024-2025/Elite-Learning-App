import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverallAttendance extends StatefulWidget {
  const OverallAttendance({Key? key}) : super(key: key);

  @override
  _OverallAttendanceState createState() => _OverallAttendanceState();
}

class _OverallAttendanceState extends State<OverallAttendance> {
  String standard = "";
  final _id = FirebaseAuth.instance.currentUser!.email;
  late Future<List<Map<String, dynamic>>> _studentsAttendanceFuture;
  late int OverallLectures;

  @override
  void initState() {
    super.initState();
    teacherRole();
    _studentsAttendanceFuture = fetchStudentsAttendance();
  }

  void teacherRole() async {
    try {
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection('teacher')
          .doc(_id)
          .get();
      setState(() {
        standard = user.get("standard");
      });
      _studentsAttendanceFuture = fetchStudentsAttendance();
      DocumentSnapshot totalLecturesDoc = await FirebaseFirestore.instance
          .collection('total_lectures')
          .doc(standard)
          .get();

      int totalLectures = totalLecturesDoc.exists
          ? totalLecturesDoc.get('count') as int
          : 0;
      setState(() {
        OverallLectures = totalLectures;
      });
    } catch (e) {
      print('Error fetching teacher role: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchStudentsAttendance() async {
    List<Map<String, dynamic>> studentsAttendance = [];
    try {
      QuerySnapshot studentsSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('standard', isEqualTo: standard)
          .get();

      DocumentSnapshot totalLecturesDoc = await FirebaseFirestore.instance
          .collection('total_lectures')
          .doc(standard)
          .get();

      int totalLectures = totalLecturesDoc.exists
          ? totalLecturesDoc.get('count') as int
          : 0;
      setState(() {
        OverallLectures = totalLectures;
      });

      for (var studentDoc in studentsSnapshot.docs) {
        Map<String, dynamic> studentData = studentDoc.data() as Map<String, dynamic>;
        int attendance = studentData['attendance'] ?? 0;
        double percentage = totalLectures > 0
            ? (attendance / totalLectures) * 100
            : 0.0;
        studentsAttendance.add({
          'name': studentData['student_name'] ?? 'No Name',
          'attendance': attendance,
          'percentage': percentage,
        });
      }
    } catch (e) {
      print('Error fetching students attendance: $e');
    }
    return studentsAttendance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Overall Attendance',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),),
        backgroundColor: Colors.purple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _studentsAttendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No attendance data available'));
          }

          List<Map<String, dynamic>> studentsAttendance = snapshot.data!;
          return ListView.builder(
            itemCount: studentsAttendance.length,
            itemBuilder: (context, index) {
              final student = studentsAttendance[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(student['name']),
                  subtitle: Text('Attendance: ${student['attendance']} lectures out of ${OverallLectures}'),
                  trailing: Text(
                    '${student['percentage'].toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: student['percentage'] >= 75
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
