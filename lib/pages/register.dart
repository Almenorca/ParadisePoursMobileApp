import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../navigation_menu.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Paradise Pours',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xffa0522d).withAlpha(150),
          foregroundColor: Colors.white,
          leading: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/images/Paradise_Pours_Logo.png'),
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            // Background image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Bar_pic.jpeg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            // Scrollable content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                      height: MediaQuery.of(context).padding.top +
                          kToolbarHeight), // Match app bar height
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 8.0,
                        child: RegisterForm(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        endDrawer: const NavigationMenu(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String feedbackMessage = '';

  @override
  Widget build(BuildContext context) {
    return _buildRegisterForm();
  }

  Future<void> register() async {
    var url = Uri.parse('http://localhost:5000/api/register');

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {
            'FirstName': firstnameController.text.trim(),
            'LastName': lastnameController.text.trim(),
            'Username': usernameController.text.trim(),
            'Password': passwordController.text.trim(),
            'Email': emailController.text.trim(),
            'Phone': phoneController.text.trim()
          },
        ),
      );

      if (response.statusCode == 201) {
        print('Registration Successful: ${response.body}');
        Navigator.pushNamed(context, '/login');
      } else if (response.statusCode == 401) {
        var data = jsonDecode(response.body);
        setState(
          () {
            feedbackMessage = data['error'];
          },
        );
      } else {
        var data = jsonDecode(response.body);
        setState(
          () {
            feedbackMessage = data['error'];
          },
        );
      }
    } catch (e) {
      setState(
        () {
          feedbackMessage = 'Failed to connect to the server';
          print('Error during register: $e');
        },
      );
    }
  }

  Widget _buildRegisterForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.blue,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  }),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Create Account',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        // Add your create account form fields and logic here
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: firstnameController,
            decoration: const InputDecoration(labelText: 'First Name'),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: lastnameController,
            decoration: const InputDecoration(labelText: 'Last Name'),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone Number'),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            obscureText: true,
            controller: passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            register();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa0522d),
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Register',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
