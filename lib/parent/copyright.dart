// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(CopyrightPage());
// }
//
// class CopyrightPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//
//       home: Scaffold(
//         appBar: AppBar(
//           foregroundColor: Colors.white,
//
//           title: Text('Copyright'),
//             backgroundColor: Colors.purple,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () {
//               // Navigate back to the previous screen or part of the app.
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         body: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       'assets/copyright/sakec_logo_blue.png',
//                       height: 80,
//                       width: 80,
//                     ),
//                     SizedBox(width: 10),
//                     Text(
//                       'Team of Shah and Anchor Kutchhi Engineering College',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     Image.asset(
//                       'assets/copyright/research_cell_logo.png',
//                       height: 80,
//                       width: 80,
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 Container(
//                   padding: EdgeInsets.all(10),
//                   color: Colors.grey[300],
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         'assets/copyright/principal-pic.jpg',
//                         height: 200,
//                         width: 200,
//                       ),
//                       SizedBox(height: 10),
//                       Text(
//                         'Dr.Bhavesh Patel\nPrincipal\nShah & Anchor Kutchhi Engineering College',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Text(
//                   'Developing Team',
//                   style: TextStyle(
//                     fontSize: 40,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildTeamMember(
//                         'assets/copyright/NamrataMaam.jpg',
//                         'Dr.Namrata Kommineni\n(Research Coordinator)',
//                       ),
//                       _buildTeamMember(
//                         'assets/copyright/divya-pritam.jpg',
//                         'Divya Pritam\n(Mentor)',
//                       ),
//                       _buildTeamMember(
//                         'assets/copyright/jaya-zalte.jpg',
//                         'Jaya Zalte\n(Mentor)',
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildTeamMember(
//                         'assets/copyright/priyank.jpg',
//                         'Priyank Jhaveri\n(Developer)',
//                       ),
//                       _buildTeamMember(
//                         'assets/copyright/mohit.jpg',
//                         'Mohitkumar Pandey\n(Developer)',
//                       ),
//                       _buildTeamMember(
//                         'assets/copyright/bhumika.jpg',
//                         'Bhumika Thanvi\n(Developer)',
//                       ),
//                       _buildTeamMember(
//                         'assets/copyright/dhara.jpeg',
//                         'Dhara Shah \n(Developer)',
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTeamMember(String imagePath, String name) {
//     return Container(
//       padding: EdgeInsets.all(10),
//       child: Column(
//         children: [
//           Image.asset(
//             imagePath,
//             height: 200,
//             width: 200,
//           ),
//           SizedBox(height: 10),
//           Container(
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               name,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
