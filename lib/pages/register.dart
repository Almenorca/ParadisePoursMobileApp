// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously, avoid_print

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
  final String app_name = 'paradise-pours-4be127640468';
    String buildPath(String route) {
      return 'https://$app_name.herokuapp.com/$route';
  }

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String feedbackMessage = '';
  bool showUsernameCriteria = false;
  bool showPasswordCriteria = false;
  bool hidePassword = true;
  bool lenInput = false;
  bool letterInput = false;
  bool pLenInput = false;
  bool pLettInput = false;
  bool pNumInput = false;
  bool pSpecInput = false;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(validateUsername);
    passwordController.addListener(validatePassword);
  }

  @override
  Widget build(BuildContext context) {
    return _buildRegisterForm();
  }
  
  bool validateForm() {
  return firstnameController.text.isNotEmpty &&
         lastnameController.text.isNotEmpty &&
         usernameController.text.isNotEmpty &&
         passwordController.text.isNotEmpty &&
         emailController.text.isNotEmpty &&
         phoneController.text.isNotEmpty;
}

  void validateUsername() {
    final username = usernameController.text;

    setState(() {
      lenInput = username.length >= 3 && username.length <= 18;
      letterInput = RegExp(r'[a-zA-Z]').hasMatch(username);
    });
  }

  void validatePassword() {
    final password = passwordController.text;

    setState(() {
      pLenInput = password.length >= 8 && password.length <= 32;
      pLettInput = RegExp(r'[a-zA-Z]').hasMatch(password);
      pNumInput = password.contains(RegExp(r'[0-9]'));
      pSpecInput = password.contains(RegExp(r'[!@#$%^&*]'));
    });
  }

  void togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  Future<void> register() async {
    if(!validateForm()){
        setState(
          () {
            feedbackMessage = "All fields must be filled";
          },
        );
      return;
    }
    
    try {
      var response = await http.post(Uri.parse(buildPath('api/login')),
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
      } 
      else {
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
                    color: Color(0xffa0522d),
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
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'XXX-XXX-XXXX'),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                showUsernameCriteria = hasFocus;
              });
            },
            child: TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {
                showPasswordCriteria = hasFocus;
              });
            },
            child: TextField(
              obscureText: hidePassword,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: togglePasswordVisibility, // Toggle button pressed
                ),
              ),
            ),
            ),
          ),
        //Username Criteria
        Visibility(
          visible: showUsernameCriteria,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Username must contain the following:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('At least one letter*', style: TextStyle(color: letterInput ? Colors.green : Colors.red)),
                Text('3 to 18 characters*', style: TextStyle(color: lenInput ? Colors.green : Colors.red)),
                const Text('Username may contain the following:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Text('Numbers', style: TextStyle(color: Colors.grey)),
                const Text('Underscores', style: TextStyle(color: Colors.grey)),
                const Text('Hyphens', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
        //Password Criteria
        Visibility(
          visible: showPasswordCriteria,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Password must contain the following:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('8 to 32 characters*', style: TextStyle(color: pLenInput ? Colors.green : Colors.red)),
                Text('At least one letter*', style: TextStyle(color: pLettInput ? Colors.green : Colors.red)),
                Text('At least one number*', style: TextStyle(color: pNumInput ? Colors.green : Colors.red)),
                Text('At least one special character*', style: TextStyle(color: pSpecInput ? Colors.green : Colors.red)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          feedbackMessage,
          style: const TextStyle(
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () {
            register();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(12.0),
            backgroundColor: const Color(0xFFA0522D), 
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
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
