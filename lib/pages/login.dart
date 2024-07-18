import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../navigation_menu.dart';

class LoginPage extends StatefulWidget {
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        
        //Header
        appBar: AppBar(
          title: const Text(
            'Welcome to Paradise Pours - Your Ultimate Alcohol Atlas!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.orange.withAlpha(150),
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
        
        //Page Content
        body: Stack(
          children: <Widget>[
            //Background
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BlankBackgroundImage.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),
            SingleChildScrollView(

              //Body
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                SizedBox(
                    height: MediaQuery.of(context).padding.top +
                        kToolbarHeight),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      margin: EdgeInsets.only(top: 20.0),
                      padding: EdgeInsets.all(40.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        border: Border.all(color: Color(0xFFA0522D), width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: LoginForm(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

        endDrawer: NavigationMenu(),

      ),
    );
  }
}

//Login Form
class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

//Login Function when user presses button.
class _LoginFormState extends State<LoginForm> {
    final TextEditingController usernameController = TextEditingController(); //Controllers inside class not widget to prevent textform from refreshing.
    final TextEditingController passwordController = TextEditingController();
    String feedbackMessage = '';

    Future<void> login() async {
      
      var url = Uri.parse('http://localhost:5000/api/login');

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
          print('Login Successful: ${response.body}');
          await Navigator.pushNamed(context, '/about');
        }
        else if (response.statusCode == 401) {
          var data = jsonDecode(response.body);
          setState(
            () {
              feedbackMessage = data['error'];
            },
          );
        } 
        else {
          var data = jsonDecode(response.body);
          setState(
            () {
              feedbackMessage = data['error'];
            },
          );
        }
      } 
      catch (e) {
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
            obscureText: true,
            controller: passwordController,
            decoration: InputDecoration(labelText: 'Password'),
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
                child: Text('Login',),
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
                    child: Text('Create Account'),
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
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
      );
    }
}