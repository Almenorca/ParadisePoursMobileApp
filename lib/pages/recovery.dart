// ignore_for_file: use_key_in_widget_constructors, avoid_print, unused_element, library_private_types_in_public_api, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key});

  @override
  _RecoveryPageState createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
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
              decoration: const BoxDecoration(
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
                          kToolbarHeight),
 Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      padding: const EdgeInsets.all(40.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        border: Border.all(color: const Color(0xFFA0522D), width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: RecoveryForm(),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecoveryForm extends StatefulWidget {
  @override
  _RecoveryFormState createState() => _RecoveryFormState();
}

class _RecoveryFormState extends State<RecoveryForm> {
    final String app_name = 'paradise-pours-4be127640468';
    String buildPath(String route) {
        return 'https://$app_name.herokuapp.com/$route';
        
    }
    final TextEditingController emailController = TextEditingController();
    String feedbackMessage = '';

    @override
    Widget build(BuildContext context) {
      return _buildRecoveryForm();
    }
    Future<void> recovery() async {
      try {
        var response = await http.post(Uri.parse(buildPath('api/recoverAccount')),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(
            {
              'Email': emailController.text.trim()
            },
          ),
        );

        if (response.statusCode == 200) {
          setState(
            () {
              feedbackMessage = "Recovery Email has been sent!";
            }
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
      } catch (e) {
        setState(
          () {
            feedbackMessage = 'Failed to connect to the server';
            print('Error during recovery: $e');
          },
        );
      }
    }

  Widget _buildRecoveryForm() {
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
                  color: Color(0xFFA0522D),
                ),
                iconSize: 30,
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                }
              ),
            ),
            const Flexible(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Recover Account',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
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
            recovery();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(12.0),
            backgroundColor: const Color(0xFFA0522D), 
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Submit',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
        ),
      ],
    );
  }
}
