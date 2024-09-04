import 'dart:async';
import 'package:elite/parent/announcements.dart';
import 'package:elite/startpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:elite/parent/attendance.dart';
import 'package:elite/parent/events.dart';
import 'package:elite/parent/fee_payment.dart';
import 'package:elite/parent/gallery.dart';
import 'package:elite/parent/contact_us.dart';
import 'package:elite/parent/time_table.dart';
import 'package:elite/parent/birthday.dart';
import 'package:elite/login_page.dart';
import 'package:elite/parent/copyright.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'diary.dart';

class ParentModule extends StatefulWidget {
  @override
  _ParentModuleState createState() => _ParentModuleState();
}

class _ParentModuleState extends State<ParentModule> {
  final List<ModuleItem> moduleItems = [
    //1
    ModuleItem(
      title: 'Birthday',
      icon: Icons.cake,
      color: Colors.purple,
      route: Birthday(),
    ),
    //2
    ModuleItem(
      title: 'Attendance',
      icon: Icons.people,
      color: Colors.purple,
      route: AttendanceScreen(),
    ),
    //3
    ModuleItem(
      title: 'Announcements',
      icon: Icons.notification_add,
      color: Colors.purple,
      route: parentAnnouncements(),
    ),
    //4
    ModuleItem(
      title: 'Time Table',
      icon: Icons.schedule,
      color: Colors.purple,
      route: TimeTable(),
    ),
    //5
    ModuleItem(
      title: 'Events',
      icon: Icons.event,
      color: Colors.purple,
      route: Events(),
    ),
    //6
    ModuleItem(
      title: 'Fee Records',
      icon: Icons.payment,
      color: Colors.purple,
      route: FeeRecordsPage(),
    ),
    //7
    ModuleItem(
      title: 'Diary',
      icon: Icons.menu_book_rounded,
      color: Colors.purple,
      route: diary(),
    ),
    //8
    ModuleItem(
      title: 'Gallery',
      icon: Icons.photo_album,
      color: Colors.purple,
      route: Gallery(),
    ),

    //9
    ModuleItem(
      title: 'About Us',
      icon: Icons.info,
      color: Colors.purple,
      route: ContactUs(),
    ),
  ];

  final List<String> imagePaths = [];

  late PageController _pageController;
  int _currentPage = 0;
  Timer? _imageRotationTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    startImageRotation();
    getImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _imageRotationTimer?.cancel();
    super.dispose();
  }

  void startImageRotation() {
    _imageRotationTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_currentPage < imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> getImages() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    ListResult result = await storage.ref('images').listAll();

    List<String> paths = [];
    for (var ref in result.items) {
      String url = await ref.getDownloadURL();
      paths.add(url);
    }

    setState(() {
      imagePaths.addAll(paths);
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');

    // Optionally, you can also clear the isTeacher preference if you want
    await prefs.remove('isTeacher');

    // Navigate back to StartPage after signing out
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => StartPage()),
          (Route<dynamic> route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.purple,
        title: Text(
          'Elite Learning',
          style: TextStyle(
            fontFamily: 'Helvetica',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: signOut,
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 50,
        color: Colors.purple,

          child: Container(
            height: 20.0,
            child: Center(
              child: Text(
                '© 2024 All Rights Reserved\nDesigned by Shah and Anchor Kutchhi Engineering College',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

      body: Column(
        children: [
          Expanded(
            flex: 4, // 40% of the screen height
            child: PageView.builder(
              controller: _pageController,
              itemCount: imagePaths.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      imagePaths[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 6, // 60% of the screen height
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(20),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 3.0,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color(0xFFFBEEFF),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.count(
                     // physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      children: moduleItems.sublist(0, moduleItems.length).map(
                            (module) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => module.route),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: module.color,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      module.icon,
                                      size: 30.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  module.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.fromLTRB(10, 4, 10, 10),
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: MediaQuery.of(context).size.width * 0.05,
                  //     vertical: MediaQuery.of(context).size.height * 0.02,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.grey.withOpacity(0.5),
                  //         spreadRadius: 2,
                  //         blurRadius: 5,
                  //         offset: Offset(0, 3),
                  //       ),
                  //     ],
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(8.0),
                  //     border: Border.all(
                  //       color: Colors.white,
                  //       width: 1.0,
                  //     ),
                  //   ),
                  //   child: GestureDetector(
                  //     onTap: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (context) => moduleItems.last.route),
                  //       );
                  //     },
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Container(
                  //           alignment: Alignment.center,
                  //           decoration: BoxDecoration(
                  //             shape: BoxShape.circle,
                  //             color: moduleItems.last.color,
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(8.0),
                  //             child: Icon(
                  //               moduleItems.last.icon,
                  //               size: 30.0,
                  //               color: Colors.white,
                  //             ),
                  //           ),
                  //         ),
                  //         SizedBox(height: 5.0),
                  //         Text(
                  //           moduleItems.last.title,
                  //           textAlign: TextAlign.center,
                  //           style: TextStyle(
                  //             fontSize: 12.0,
                  //             fontWeight: FontWeight.bold,
                  //             color: Colors.grey[800],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModuleItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget route;

  ModuleItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}
