// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Fixed Background Image with Scrollable Body'),
//           elevation: 0, // Remove shadow
//           backgroundColor: Colors.transparent, // Transparent app bar
//         ),
//         extendBodyBehindAppBar: true, // Extend background behind app bar
//         body: Stack(
//           children: <Widget>[
//             // Background image
//             Container(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/background.jpg'), // Your background image path
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             // Scrollable content
//             SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: <Widget>[
//                   SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight), // Match app bar height
//                   Center(
//                     child: Text(
//                       'Your Content Here',
//                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                     child: Text(
//                       'Other widgets can go here. This column will scroll when necessary.',
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Container(
//                     height: 1000, // Example of a tall widget that exceeds screen height
//                     color: Colors.blue,
//                     child: Center(
//                       child: Text(
//                         'Tall Widget',
//                         style: TextStyle(fontSize: 24, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
