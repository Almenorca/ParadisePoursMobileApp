// import 'package:flutter/material.dart';
// import '../navigation_menu.dart';

// class RecoveryPage extends StatefulWidget {
//   @override
//   _RecoveryPageState createState() => _RecoveryPageState();
// }

// class _RecoveryPageState extends State<RecoveryPage> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   void _openDrawer() {
//     _scaffoldKey.currentState?.openEndDrawer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       extendBody: true,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text(
//           'Create Account',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.orange.withAlpha(150),
//         foregroundColor: Colors.white,
//         leading: Container(
//           decoration: const BoxDecoration(
//             shape: BoxShape.circle,
//             image: DecorationImage(
//                 fit: BoxFit.fill,
//                 image: AssetImage('assets/images/Paradise_Pours_Logo.png')),
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/BlankBackgroundImage.jpg',
//               fit: BoxFit.cover,
//               alignment: Alignment.centerRight,
//             ),
//           ),
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Card(
//                 elevation: 8.0,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: RegisterForm(),
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//       endDrawer: NavigationMenu(),
//     );
//   }
// }

// class RegisterForm extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         TextField(
//           decoration: InputDecoration(labelText: 'Email'),
//         ),
//         SizedBox(height: 16.0),
//         TextField(
//           decoration: InputDecoration(labelText: 'Username'),
//         ),
//         SizedBox(height: 16.0),
//         TextField(
//           obscureText: true,
//           decoration: InputDecoration(labelText: 'Password'),
//         ),
//         SizedBox(height: 16.0),
//         ElevatedButton(
//           onPressed: () {
//             // Handle logic
//           },
//           child: Text('Next'),
//         ),
//       ],
//     );
//   }
// }
