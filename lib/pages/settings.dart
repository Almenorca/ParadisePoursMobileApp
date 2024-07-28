import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../navigation_menu.dart';
import '../auth_service.dart'; // Import the AuthService

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final String app_name = 'paradise-pours-4be127640468';
  String buildPath(String route) {
    return 'https://$app_name.herokuapp.com/$route';
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isUsernameEditable = false;
  bool _isPasswordEditable = false;
  bool _showPasswordCriteria = false;
  bool _showConfirmPasswordCriteria = false;
  bool _hidePassword = true;
  bool pLenInput = false;
  bool pLettInput = false;
  bool pNumInput = false;
  bool pSpecInput = false;
  bool cpLenInput = false;
  bool cpLettInput = false;
  bool cpNumInput = false;
  bool cpSpecInput = false;
  String feedbackMessage = '';

  bool _showConfirmPassword = false;

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _passwordController.addListener(validatePassword);
    _confirmPasswordController.addListener(validateConfirmPassword);

    _passwordFocusNode.addListener(() {
      setState(() {
        if (_isPasswordEditable) {
          _showPasswordCriteria = _passwordFocusNode.hasFocus;
        }
      });
    });

    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _showConfirmPasswordCriteria = _confirmPasswordFocusNode.hasFocus;
      });
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final user = await AuthService().getUser();
      if (user != null) {
        setState(() {
          _emailController.text = user.email;
          // Fetch the username
          _fetchUsername(user.userId).then((_) {
            // Fetch the password after the username is updated
            _fetchPassword(_usernameController.text);
          });
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _fetchUsername(int userId) async {
    try {
      final response = await http.post(
        Uri.parse(buildPath('api/getUsername')),
        body: jsonEncode({'userId': userId}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _usernameController.text = data['Username'];
        });
      } else {
        print('Failed to fetch username: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> _fetchPassword(String username) async {
    try {
      final response = await http.post(
        Uri.parse(buildPath('api/getPassword')),
        body: jsonEncode({'Username': username}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _passwordController.text = data['Password'];
        });
      } else {
        print('Failed to fetch password: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching password: $e');
    }
  }

  void validatePassword() {
    final password = _passwordController.text;

    setState(() {
      pLenInput = password.length >= 8 && password.length <= 32;
      pLettInput = RegExp(r'[a-zA-Z]').hasMatch(password);
      pNumInput = password.contains(RegExp(r'[0-9]'));
      pSpecInput = password.contains(RegExp(r'[!@#$%^&*]'));
    });
  }

  void validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      cpLenInput = confirmPassword.length >= 8 && confirmPassword.length <= 32;
      cpLettInput = RegExp(r'[a-zA-Z]').hasMatch(confirmPassword);
      cpNumInput = confirmPassword.contains(RegExp(r'[0-9]'));
      cpSpecInput = confirmPassword.contains(RegExp(r'[!@#$%^&*]'));
    });
  }

  Future<void> _changeUsername() async {
    final user = await AuthService().getUser();
    if (user == null) {
      return;
    }

    final response = await http.post(
      Uri.parse(buildPath('api/changeUsername')),
      body: jsonEncode({
        'userId': user.userId,
        'newUsername': _usernameController.text,
      }),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Successfully changed username
      setState(() {
        _isUsernameEditable = false;
      });
      _showAlert('Success', 'Username changed successfully', true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to change username')),
      );
    }
  }

  Future<void> _changePassword() async {
    final user = await AuthService().getUser();
    if (user == null) {
      return;
    }

    if (_passwordController.text == _confirmPasswordController.text) {
      if (pLenInput && pLettInput && pNumInput && pSpecInput) {
        final response = await http.post(
          Uri.parse(buildPath('api/changePassword')),
          body: jsonEncode({
            'userId': user.userId,
            'newPassword': _passwordController.text,
            'confirmPassword': _confirmPasswordController.text,
          }),
          headers: {"Content-Type": "application/json"},
        );

        if (response.statusCode == 200) {
          // Successfully changed password
          setState(() {
            _isPasswordEditable = false;
            _hidePassword = true;
            _confirmPasswordController.clear();
            _showPasswordCriteria = false;
            _showConfirmPasswordCriteria = false;
          });
          _showAlert('Success', 'Password changed successfully', true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to change password')),
          );
        }
      } else {
        setState(() {
          feedbackMessage = 'Password does not meet the criteria';
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
    }
  }

  Future<void> _deleteAccount() async {
    final user = await AuthService().getUser();
    if (user == null) {
      return;
    }

    final response = await http.post(
      Uri.parse(buildPath('api/deleteAccount')),
      body: jsonEncode({
        'userId': user.userId,
      }),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Successfully deleted account
      _showGoodbyeMessage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account')),
      );
    }
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showGoodbyeMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Goodbye!'),
          content: const Text('We are sad to see you go! Drink Responsibly!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/login');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAlert(String title, String message, bool reload) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (reload) {
                  _fetchUserData();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _cancelPasswordEdit() {
    setState(() {
      _isPasswordEditable = false;
      _hidePassword = true;
      _passwordController.text = ''; // Clear password field
      _confirmPasswordController.clear();
      _showPasswordCriteria = false;
      _showConfirmPasswordCriteria = false;
      feedbackMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Settings',
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
                image: AssetImage('assets/images/Paradise_Pours_Logo.png')),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/BlankBackgroundImage.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.centerRight),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _usernameController,
                            enabled: _isUsernameEditable,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isUsernameEditable ? Icons.check : Icons.edit),
                          onPressed: () {
                            setState(() {
                              if (_isUsernameEditable) {
                                _changeUsername();
                              }
                              _isUsernameEditable = !_isUsernameEditable;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            enabled: _isPasswordEditable,
                            focusNode: _passwordFocusNode,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(_isPasswordEditable ? Icons.cancel : Icons.edit),
                          onPressed: () {
                            setState(() {
                              if (_isPasswordEditable) {
                                _cancelPasswordEdit();
                              } else {
                                _isPasswordEditable = true;
                                _showConfirmPassword = true;
                                _hidePassword = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isPasswordEditable && _showPasswordCriteria)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          const Text(
                            'Password must contain the following:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '8 to 32 characters',
                            style: TextStyle(color: pLenInput ? Colors.green : Colors.red),
                          ),
                          Text(
                            'At least one letter',
                            style: TextStyle(color: pLettInput ? Colors.green : Colors.red),
                          ),
                          Text(
                            'At least one number',
                            style: TextStyle(color: pNumInput ? Colors.green : Colors.red),
                          ),
                          Text(
                            'At least one special character',
                            style: TextStyle(color: pSpecInput ? Colors.green : Colors.red),
                          ),
                        ],
                      ),
                    if (_isPasswordEditable)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          TextField(
                            controller: _confirmPasswordController,
                            focusNode: _confirmPasswordFocusNode,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                          if (_showConfirmPasswordCriteria)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                const Text(
                                  'Confirm Password must contain the following:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '8 to 32 characters',
                                  style: TextStyle(
                                      color: cpLenInput ? Colors.green : Colors.red),
                                ),
                                Text(
                                  'At least one letter',
                                  style: TextStyle(
                                      color: cpLettInput ? Colors.green : Colors.red),
                                ),
                                Text(
                                  'At least one number',
                                  style: TextStyle(
                                      color: cpNumInput ? Colors.green : Colors.red),
                                ),
                                Text(
                                  'At least one special character',
                                  style: TextStyle(
                                      color: cpSpecInput ? Colors.green : Colors.red),
                                ),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Text(
                            feedbackMessage,
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _changePassword,
                                child: const Text('Update Password'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _cancelPasswordEdit,
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.brown,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _showDeleteAccountConfirmation,
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      endDrawer: const NavigationMenu(),
    );
  }
}
