import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:elite/login_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool isTeacher = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/eliteimg.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: GlassmorphicContainer(
                margin: EdgeInsets.symmetric(horizontal: 25),
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                width: double.infinity,
                height: 200,
                borderRadius: 10,
                border: 0,
                blur: 4,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple.withOpacity(0.1),
                    Colors.purple.withOpacity(0.05),
                  ],
                  stops: [0.1, 1],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.withOpacity(0.8),
                    Colors.deepPurple.withOpacity(0.8),
                    Colors.purple.withOpacity(0.3),
                    Colors.purple.withOpacity(0.3),
                  ],
                  stops: [0.0, 0.1, 0.9, 1.0],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        label: Text(
                          'STUDENT LOGIN',
                          style: TextStyle(
                            fontFamily: 'Archives',
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                        ),
                        onPressed: () {
                          setState(() {
                            isTeacher = false;
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(isTeacher: false),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
                        label: Text(
                          'TEACHER LOGIN',
                          style: TextStyle(
                            fontFamily: 'Archives',
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade400,
                        ),
                        onPressed: () {
                          setState(() {
                            isTeacher = true;
                          });
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(isTeacher: true),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
