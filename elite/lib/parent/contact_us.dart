import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:elite/parent/privacy.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD8E0FF),
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Contact Us'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(15, 15, 15, 5),

              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                'Welcome to the Contact Us section of the app. If you have any questions or need assistance, please feel free to reach out to us using the contact information provided below.',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              margin: EdgeInsets.fromLTRB(15, 0, 15, 5),
              padding: EdgeInsets.all(10),

              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                'School Office Contact:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF60951), // Light Pink
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              margin: EdgeInsets.fromLTRB(15, 0, 15, 5),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 1), // changes position of shadow
                  ),
                ],
                color: Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white),
              ),
              child: Column(
                children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 8),

                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 1), // changes position of shadow
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Color(0xFFFA2D6F), // Light Pink
                  ),
                  title: Text('Landline'),
                  subtitle: Text('022 28671599'),
                  onTap: () => launch('tel:022 28671599'),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 1), // changes position of shadow
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.email,
                    color: Color(0xFFA2FFC4), // Mint Green
                  ),
                  title: Text('Email'),
                  subtitle: Text('elitelearning@gmail.com'),
                  onTap: () => launch('elitelearning@gmail.com'),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 1), // changes position of shadow
                    ),
                  ],

                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Color(0xFFB8DFFD), // Baby Blue
                  ),
                  title: Text('Contact'),
                  subtitle: Text('Elite learning'),
                ),
              ),
              ]),
            ),
            SizedBox(height: 10.0),
            // Container(
            //   margin: EdgeInsets.fromLTRB(15, 0, 15, 5),
            //   padding: EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.6),
            //         spreadRadius: 2,
            //         blurRadius: 5,
            //         offset: Offset(0, 1), // changes position of shadow
            //       ),
            //     ],
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(5),
            //     border: Border.all(color: Colors.white),
            //
            //   ),
            //   // child: Text(
            //   //   'Frequently Asked Questions:',
            //   //   style: TextStyle(
            //   //     fontSize: 18.0,
            //   //     fontWeight: FontWeight.bold,
            //   //     color: Color(0xFF030005), // Lavender
            //   //   ),
            //   // ),
            // ),
            SizedBox(height: 10.0),
            // Container(
            //   margin: EdgeInsets.fromLTRB(15, 0, 15, 5),
            //
            //   padding: EdgeInsets.all(10),
            //   decoration: BoxDecoration(
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.5),
            //         spreadRadius: 2,
            //         blurRadius: 5,
            //         offset: Offset(0, 3), // changes position of shadow
            //       ),
            //     ],
            //     color: Color(0xFFEEF0FF),
            //     borderRadius: BorderRadius.circular(5),
            //     border: Border.all(color: Colors.white),
            //   ),
            //   child: Column(
            //     children: [
            //   Container(
            //     margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
            //     padding: EdgeInsets.all(5),
            //     decoration: BoxDecoration(
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.grey.withOpacity(0.5),
            //           spreadRadius: 2,
            //           blurRadius: 5,
            //           offset: Offset(0, 1), // changes position of shadow
            //         ),
            //       ],
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //     child: ExpansionTile(
            //       collapsedShape: RoundedRectangleBorder(
            //         side: BorderSide.none,
            //       ),
            //       shape: RoundedRectangleBorder(
            //         side: BorderSide.none,
            //       ),
            //       title: Text(
            //         'How do I update my contact information?',
            //         style: TextStyle(color: Color(0xFF000000),
            //         ), // Lavender
            //       ),
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            //           child: Text(
            //             'You can update your contact information by navigating to the Profile section of the app and selecting the "Edit Profile" option. Make sure to save your changes after updating.',
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            //   Container(
            //     padding: EdgeInsets.all(5),
            //     decoration: BoxDecoration(
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.grey.withOpacity(0.5),
            //           spreadRadius: 2,
            //           blurRadius: 5,
            //           offset: Offset(0, 3), // changes position of shadow
            //         ),
            //       ],
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //     child: ExpansionTile(
            //       collapsedShape: RoundedRectangleBorder(
            //         side: BorderSide.none,
            //       ),
            //       shape: RoundedRectangleBorder(
            //         side: BorderSide.none,
            //       ),
            //
            //       title: Text(
            //         'How can I pay the tuition fees?',
            //         style: TextStyle(color: Color(0xFF06000A)), // Lavender
            //       ),
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            //           child: Text(
            //             'You can pay the tuition fees through our online payment portal or by visiting the school office. Please refer to the billing statement for payment details and deadlines.',
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            //   Container(
            //
            //     margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
            //     padding: EdgeInsets.all(5),
            //     decoration: BoxDecoration(
            //       boxShadow: [
            //         BoxShadow(
            //           color: Colors.grey.withOpacity(0.5),
            //           spreadRadius: 2,
            //           blurRadius: 5,
            //           offset: Offset(0, 3), // changes position of shadow
            //         ),
            //       ],
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(5),
            //     ),
            //     child: ExpansionTile(
            //       collapsedShape: RoundedRectangleBorder(
            //         side: BorderSide.none,
            //       ),
            //       shape: RoundedRectangleBorder(
            //         side: BorderSide.none,
            //       ),
            //       title: Text(
            //         'What is the procedure for reporting an absence?',
            //         style: TextStyle(color: Color(0xFF000000)), // Lavender
            //       ),
            //       children: [
            //         Padding(
            //           padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            //           child: Text(
            //             'To report an absence, please inform the school office by phone or email before the start of the school day. Provide the student\'s name, grade, and reason for the absence.',
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            //       ],),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the items horizontally
            children: [
              // ... your existing bottom navigation items ...
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Privacy()), // Navigate to PrivacyPage
                  );
                },
                child: Text(
                  'Privacy & Security',
                  style: TextStyle(color: Colors.pinkAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}