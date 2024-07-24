import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth_service.dart';
import '../navigation_menu.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // var userProvider = Provider.of<UserProvider>(context);

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
                        child: LoginForm(),
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

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController usernameController =
      TextEditingController(); //Controllers inside class not widget to prevent textform from refreshing.
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  String feedbackMessage = '';

  bool validateForm() {
    return usernameController.text.isNotEmpty &&
         passwordController.text.isNotEmpty;
  }

  void togglePasswordVisibility() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  Future<void> login() async {
    var url = Uri.parse('http://localhost:5000/api/login');

    if(!validateForm()){
        setState(
          () {
            feedbackMessage = "All fields must be filled";
          },
        );
      return;
    }

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(
          {
            'Username': usernameController.text.trim(),
            'Password': passwordController.text.trim(),
          },
        ),
      );

      //Responses from backend
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        User user = User.fromJson(data['user']); // Save user data.
        AuthService().saveUser(user);
        await Navigator.pushNamed(context, '/home');
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
          print('Error during login: $e');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoginForm();
  }


  //Returns login form
  Widget _buildLoginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Sign In',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: 'Username'),
          ),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
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
        SizedBox(height: 10.0),
        Text(
          feedbackMessage,
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //Login Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(12.0),
                    backgroundColor: Color(0xFFA0522D), 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                ),
                child: Text('Login',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
              ),
            ),
            SizedBox(height: 8.0),
            //Register Button
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context,'/register');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(12.0),
                      backgroundColor: Color(0xFFA0522D), 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('Create Account',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  ),
                  ),
                ],
              ),
            ],
          ),
          //Forget Account Link
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: GestureDetector(
              onTap: () {
                  Navigator.pushNamed(context,'/recovery');
              },
              child: Text(
                'Forgot Account',
                style: TextStyle(
                  color: Color(0xFFA0522D),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
      );
    }
}