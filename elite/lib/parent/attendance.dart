import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../login_page.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd MMMM yyyy').format(now);

    Map<String, double> dataMap = {
      'Attended': 75.0,
      'Absent': 25.0,
    };
    List<String> subjects = ['Subject1', 'Subject2'];
    List<double> subjectAttendance = [75.0, 65.0];
    int total = 14;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title:Text('Attendance',
        style: TextStyle(
          color: Colors.purple,
        ),),
      ),
      body: Padding(
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
                    blurStyle: BlurStyle.inner,
                    color: Colors.purple,
                    blurRadius: 100.0,
                    spreadRadius: 0.0,
                    offset: const Offset(0.0, 3.0),
                  ),
                ],
                color:  Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Text(
                '$formattedDate',
                style: TextStyle(
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
                    blurStyle: BlurStyle.inner,
                    color: Colors.purple,
                    blurRadius: 100.0,
                    spreadRadius: 0.0,
                    offset: const Offset(0.0, 5.0),
                  ),
                ],
                color:  Color.fromRGBO(13, 34, 77, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: PieChart(
                  dataMap: dataMap,
                  colorList: [Colors.greenAccent, Colors.red],
                  chartType: ChartType.ring,
                  chartRadius: MediaQuery.of(context).size.width / 3.5,
                  centerWidget: Text(
                    textAlign: TextAlign.center,
                    "$total out of \n20",
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
                    showLegendsInRow: false,
                    legendPosition: LegendPosition.right,
                  ),
                  chartValuesOptions: ChartValuesOptions(
                    showChartValuesOutside: true,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValueBackground: true,
                    chartValueBackgroundColor:  Colors.white,
                    chartValueStyle: TextStyle(
                      color:  Color.fromRGBO(13, 34, 77, 1.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Subject-wise Attendance:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      tileColor:  Color.fromRGBO(13, 34, 77, 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      title: Text(
                        subjects[index],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurStyle: BlurStyle.normal,
                              color: Colors.lightBlueAccent.withOpacity(0.4),
                              blurRadius: 30.0,
                              spreadRadius: 0.0,
                              offset: const Offset(0.0, 3.0),
                            ),
                          ],
                        ),
                        child: LinearPercentIndicator(
                          animation: true,
                          barRadius: Radius.circular(10),
                          width: MediaQuery.of(context).size.width - 73,
                          lineHeight: 20.0,
                          percent: subjectAttendance[index] / 100,
                          progressColor: Colors.cyanAccent.shade400,
                          backgroundColor: Colors.lightBlueAccent.shade700,
                          center: Text(
                            '${subjectAttendance[index].toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.white,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
