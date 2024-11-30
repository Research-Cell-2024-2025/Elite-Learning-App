import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AbsentDates extends StatefulWidget {
  final String email;

  const AbsentDates({super.key, required this.email});

  @override
  State<AbsentDates> createState() => _AbsentDatesState();
}

class _AbsentDatesState extends State<AbsentDates> {
  late Future<List<String>> _absentDatesFuture;

  @override
  void initState() {
    super.initState();
    _absentDatesFuture = _fetchAbsentDates();
  }

  Future<List<String>> _fetchAbsentDates() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.email)
          .get();

      if (!userDoc.exists) {
        return [];
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      List<String> absentDates = List<String>.from(data['absentDates'] ?? []);
      List<String> formattedDates = absentDates.map((dateString) {
        List<String> parts = dateString.split('-');
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        DateTime date = DateTime(year, month, day);
        return DateFormat('d MMMM yyyy').format(date);
      }).toList();

      return formattedDates;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching absent dates: $e')));
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text(
          'Absent Dates',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _absentDatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No absent dates available.'));
          }

          final absentDates = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: absentDates.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 10),
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
                          title: Text(
                            absentDates[index],
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
