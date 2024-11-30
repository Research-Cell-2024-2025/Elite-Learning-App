import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class presentDates extends StatefulWidget {
  final String email;

  const presentDates({super.key, required this.email});

  @override
  State<presentDates> createState() => _presentDatesState();
}

class _presentDatesState extends State<presentDates> {
  late Future<List<String>> _presentDatesFuture;

  @override
  void initState() {
    super.initState();
    _presentDatesFuture = _fetchPresentDates();
  }

  Future<List<String>> _fetchPresentDates() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.email)
          .get();

      if (!userDoc.exists) {
        return [];
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      List<String> presentDates = List<String>.from(data['presentDates'] ?? []);

      // Parse and format the dates from '2-9-2024' to 'day month' (e.g., '2 September')
      List<String> formattedDates = presentDates.map((dateString) {
        List<String> parts = dateString.split('-');  // Split the string by '-'
        int day = int.parse(parts[0]);               // Parse day
        int month = int.parse(parts[1]);             // Parse month
        int year = int.parse(parts[2]);              // Parse year

        // Create a DateTime object from the parsed values
        DateTime date = DateTime(year, month, day);

        // Format the date as 'd MMMM' (e.g., '2 September')
        return DateFormat('d MMMM yyyy').format(date);
      }).toList();

      return formattedDates;
    } catch (e) {
      print('Error fetching present dates: $e');
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
          'Present Dates',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _presentDatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No present dates available.'));
          }

          final presentDates = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: ListView.builder(
                    itemCount: presentDates.length,
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
                          title: Text(presentDates[index],style: TextStyle(color: Colors.white,
                          fontSize: 18),),
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
