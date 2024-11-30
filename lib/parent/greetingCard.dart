import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class GreetingCard extends StatelessWidget {
  final String name;

  final String imageUrl;
  final Timestamp timestamp; // Added the timestamp field

  const GreetingCard({
    required this.name,

    required this.imageUrl,
    required this.timestamp, // Required timestamp
    Key? key,
  }) : super(key: key);

  // Function to format timestamp to the desired date format
  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(Duration(days: 1));

    // Check if the date is today
    if (DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(today)) {
      return "🎉 Happy Birthday, $name! 🎉"; // Today's birthday message
    }
    // Check if the date is yesterday
    else if (DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(yesterday)) {
      return "🎉 Yesterday was $name's birthday! 🎉"; // Yesterday's birthday message
    }
    // Otherwise, show the specific date of the birthday
    else {
      return "$name's birthday was on ${DateFormat('d MMM yyyy').format(date)}"; // E.g., "27 Sep 2024 was $name's birthday"
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/img.png', // Use asset image on error
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              )
                  : Image.asset(
                'assets/img.png',
                // Use asset image by default
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _formatDate(timestamp), // Show the appropriate message
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            // Text(
            //   message,
            //   style: TextStyle(fontSize: 16),
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('d MMM yyyy').format(timestamp.toDate()), // Display the actual date at the bottom
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
