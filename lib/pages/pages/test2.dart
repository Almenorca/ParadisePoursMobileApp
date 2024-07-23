// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   TextEditingController usernameController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   bool lastLoginAttempt = true;
//   bool missFieldError = false;
//   bool error = false;

//   Future<void> loginButtonHandler() async {
//     setState(() {
//       error = false;
//       missFieldError = false;
//     });

//     if (!validateForm()) {
//       setState(() {
//         missFieldError = true;
//       });
//       return;
//     }

//     if (!lastLoginAttempt) {
//       setState(() {
//         error = true;
//       });
//       return;
//     }

//     try {
//       var url = Uri.parse('http://localhost:5000/api/login');
//       var response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'Username': usernameController.text,
//           'Password': passwordController.text,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Login Successful: ${response.body}');
//         Navigator.pushNamed(context, '/homepage');
//         setLastLoginAttempt(true);
//       } else {
//         print('Login failed...');
//         setLastLoginAttempt(false);
//         setState(() {
//           error = true;
//         });
//       }
//     } catch (e) {
//       print('Error during login: $e');
//       setLastLoginAttempt(false);
//       setState(() {
//         error = true;
//       });
//     }
//   }

//   bool validateForm() {
//     return usernameController.text.isNotEmpty &&
//         passwordController.text.isNotEmpty;
//   }

//   void setLastLoginAttempt(bool success) {
//     setState(() {
//       lastLoginAttempt = success;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Login'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (missFieldError)
//               Text(
//                 'Please fill in all fields.',
//                 style: TextStyle(color: Colors.red),
//               ),
//             if (error)
//               Text(
//                 'Invalid credentials. Please try again.',
//                 style: TextStyle(color: Colors.red),
//               ),
//             TextField(
//               controller: usernameController,
//               decoration: InputDecoration(labelText: 'Username'),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: loginButtonHandler,
//               child: Text('Login'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     title: 'Flutter Demo',
//     initialRoute: '/',
//     routes: {
//       '/': (context) => LoginPage(),
//       '/homepage': (context) => Scaffold(
//             appBar: AppBar(
//               title: Text('Homepage'),
//             ),
//             body: Center(
//               child: Text('Welcome to Homepage!'),
//             ),
//           ),
//     },
//   ));
// }
