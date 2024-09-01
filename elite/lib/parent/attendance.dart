import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../login_page.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _fire = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;
  late final standard;
  double attendance = 0;
  double totalAttendance = 0;

  @override
  void initState() {
    super.initState();
    attendancePresent();
    totalLectures();
  }

  void attendancePresent() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.uid)
          .get();
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('attendance')) {
          setState(() {
            attendance = data['attendance']?.toDouble() ?? 0;
          });
        } else {
          print('Attendance field does not exist');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching attendance: $e');
    }
  }

  void totalLectures() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(user!.uid)
          .get();
      final userData = snapshot.data();
      if (userData != null && userData.containsKey('standard')) {
        setState(() {
          standard = userData['standard'];
        });

        final totalSnapshot = await FirebaseFirestore.instance
            .collection('total_lectures')
            .doc(standard)
            .get();
        final totalData = totalSnapshot.data();
        if (totalData != null && totalData.containsKey('count')) {
          setState(() {
            totalAttendance = totalData['count']?.toDouble() ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error fetching total lectures: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd MMMM yyyy').format(now);

    Map<String, double> dataMap = {
      'Attended': attendance,
      'Absent': totalAttendance - attendance,
    };
    int total = 14;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text(
          'Attendance',
          style: TextStyle(
            color: Colors.purple,
          ),
        ),
      ),
      body: Container(
        color: Color.fromARGB(255, 245, 224, 251),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                      offset: const Offset(0.0, 3.0),
                    ),
                  ],
                  color: Colors.purple,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  '$formattedDate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.white,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                      offset: const Offset(0.0, 5.0),
                    ),
                  ],
                  color: Colors.purple,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(
                  child: PieChart(
                    dataMap: dataMap,
                    colorList: [
                      Color.fromARGB(255, 0, 255, 140),
                      Color.fromARGB(255, 255, 0, 0)
                    ],
                    chartType: ChartType.ring,
                    ringStrokeWidth: 40,
                    chartRadius: MediaQuery.of(context).size.width / 2,
                    centerWidget: Text(
                      textAlign: TextAlign.center,
                      'Total Lectures \n $totalAttendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        wordSpacing: 0.1,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    legendOptions: LegendOptions(
                      legendTextStyle: TextStyle(color: Colors.white),
                      showLegendsInRow: true,
                      legendPosition: LegendPosition.bottom,
                    ),
                    chartValuesOptions: ChartValuesOptions(
                      showChartValuesOutside: true,
                      showChartValues: true,
                      showChartValuesInPercentage: true,
                      showChartValueBackground: true,
                      chartValueBackgroundColor: Colors.white,
                      chartValueStyle: TextStyle(
                        color: Color.fromRGBO(13, 34, 77, 1.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                      offset: const Offset(0.0, 5.0),
                    ),
                  ],
                  color: Colors.purple,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text(
                  'ATTENDANCE:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                      offset: const Offset(0.0, 5.0),
                    ),
                  ],
                  color: Colors.purple,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                    child: ListTile(
                      leading: Icon(Icons.circle, color: Colors.white),
                      title: Text(
                        'ATTENDED',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        attendance.toString(),
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.fromLTRB(10, 20, 20, 20),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2.0,
                      spreadRadius: 3.0,
                      offset: const Offset(0.0, 5.0),
                    ),
                  ],
                  color: Colors.purple,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                    child: ListTile(
                      leading: Icon(Icons.circle, color: Colors.white),
                      title: Text(
                        'ABSENT',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        (totalAttendance - attendance).toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
