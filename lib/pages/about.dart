import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../navigation_menu.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _launchURL(String str) async {
    final Uri url = Uri.parse(str);
    if (!await launchUrl(url)) {
      throw 'Could not launch $str';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'About Us',
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
                        kToolbarHeight), // Match app bar height
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.white.withAlpha(210),
                      elevation: 8.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _launchURL(
                                  'https://github.com/DanTySmall/Large-Project');
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.info_rounded,
                                  size: 24.0,
                                  color: Colors
                                      .blue, // Replace with your desired icon color
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'About Us',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Colors
                                        .blue, // Replace with your desired text color
                                    decoration: TextDecoration
                                        .underline, // Simulates link styling
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              '\t\t\tAt Paradise Pours, we aim to provide comprehensive insight into the nutritional content of any alcohol of your choice'
                              ' such as beer, wine, and liquor. Understanding these details is crucial for making informed choices about consumption.'
                              ' Whether you\'re curious about the calorie content, ABV, or other nutritional factors, our goal is to empower you with'
                              ' knowledge that promotes responsible and informed drinking habits. Explore our resources to uncover the nutritional '
                              'facts of your favorite drinks and discover how they fit into your lifestyle.',
                              style: TextStyle(fontSize: 18.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      endDrawer: const NavigationMenu(),
    );
  }
}
