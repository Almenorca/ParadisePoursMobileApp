import 'package:flutter/material.dart';
import '../navigation_menu.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatefulWidget {
  @override
  _AboutUsPageState createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
                        kToolbarHeight),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        border: Border.all(color: Color(0xFFE0BF19), width: 10.0),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: Offset(0, 4), // changes position of shadow
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(30.0),
                      child: AboutUs(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      endDrawer: NavigationMenu(),
    );
  }
}

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 30.0),
              GestureDetector(
                onTap: _launchURL,
                child: Text(
                  'About Us',
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
        SizedBox(height: 30.0),
        Text(
          'At Paradise Pours, we aim to provide comprehensive insight into the nutritional content of any alcohol of your choice such as beer, wine, and liquor. Understanding these details is crucial for making informed decisions about consumption. Whether you\'re curious about the calorie content, ABV, or other nutritional factors, our goal is to empower you with knowledge that promotes responsible and informed drinking habits. Explore our resources to uncover the nutritional facts of your favorite drinks and discover how they fit into your lifestyle.',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            height: 1.55, 
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  _launchURL() async {
    final Uri url = Uri.parse('https://github.com/DanTySmall/Large-Project');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}