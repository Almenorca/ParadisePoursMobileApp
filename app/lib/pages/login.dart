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
        appBar: AppBar(
          title: const Text(
            'Paradise Pours',
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
        body: Stack(
          children: <Widget>[
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BlankBackgroundImage.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.centerRight,
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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
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
        endDrawer: NavigationMenu(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Track which form to display: 0 - Login, 1 - Create Account, 2 - Recover Account
  int _currentFormIndex = 0;

  void _showLoginForm() {
    setState(
      () {
        _currentFormIndex = 0;
      },
    );
  }

  void _showCreateAccountForm() {
    setState(
      () {
        _currentFormIndex = 1;
      },
    );
  }

  void _showRecoverAccountForm() {
    setState(
      () {
        _currentFormIndex = 2;
      },
    );
  }

  void _goBackToLoginForm() {
    setState(
      () {
        _currentFormIndex = 0;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _currentFormIndex == 0
        ? _buildLoginForm()
        : _currentFormIndex == 1
            ? _buildCreateAccountForm()
            : _buildRecoverAccountForm();
  }

  Widget _buildLoginForm() {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    bool lastLoginAttempt = true;
    bool missFieldError = false;
    bool error = false;

    String feedbackMessage = '';

    Future<void> login() async {
      setState(
        () {
          error = false;
          missFieldError = false;
        },
      );

      var url = Uri.parse('http://localhost:5000/api/login');

      bool validateForm() {
        return usernameController.text.isNotEmpty &&
            passwordController.text.isNotEmpty;
      }

      void setLastLoginAttempt(bool success) {
        setState(() {
          lastLoginAttempt = success;
        });
      }

      if (!validateForm()) {
        setState(
          () {
            missFieldError = true;
          },
        );
        return;
      }

      if (!lastLoginAttempt) {
        setState(
          () {
            error = true;
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

        if (response.statusCode == 200) {
          print('Login Successful: ${response.body}');
          Navigator.pushNamed(context, '/home');
          setLastLoginAttempt(true);
        } else if (response.statusCode == 401) {
          var data = jsonDecode(response.body);
          setState(
            () {
              feedbackMessage = data['error'];
            },
          );
        } else {
          setState(
            () {
              feedbackMessage = 'Invalid Username or Password';
              setLastLoginAttempt(false);
              setState(
                () {
                  error = true;
                },
              );
            },
          );
        }
      } catch (e) {
        setState(
          () {
            feedbackMessage = 'Failed to connect to the server';
            print('Error during login: $e');
            setLastLoginAttempt(false);
            setState(
              () {
                error = true;
              },
            );
          },
        );
      }
    }

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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _showCreateAccountForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Create Account'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: _showRecoverAccountForm,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                    child: Text('Forgot?'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateAccountForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
                iconSize: 30,
                onPressed: _goBackToLoginForm,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
            decoration: InputDecoration(labelText: 'Email'),
          ),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(labelText: 'Username'),
          ),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              // createAccount
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Next',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecoverAccountForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
                iconSize: 30,
                onPressed: _goBackToLoginForm,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Recover Account',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        ),
        // Add your recover account form fields and logic here
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(labelText: 'Username'),
          ),
        ),
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(labelText: 'Recovery Code'),
          ),
        ),
        SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {
                  // sendRecoveryCode
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: Text(
                  'Send recovery code',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // recoverAccount
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Next',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
