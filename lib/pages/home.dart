import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../navigation_menu.dart';
import 'beer.dart';
import 'liquor.dart';
import 'wine.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slideIn;

  void _openDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Increased duration to 3 seconds
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    _slideIn = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
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
                        kToolbarHeight), // Match app bar height
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 8.0,
                      // child: LoginForm(),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _slideIn,
                          child: FadeTransition(
                            opacity: _opacity,
                            child: const Text(
                              'Welcome to',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _slideIn,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.beerMugEmpty, color: Colors.white),
                              SizedBox(width: 8),
                              FaIcon(FontAwesomeIcons.wineGlassEmpty, color: Colors.white),
                              SizedBox(width: 8),
                              FaIcon(FontAwesomeIcons.martiniGlassCitrus, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Paradise Pours',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10.0,
                                      color: Colors.black,
                                      offset: Offset(2.0, 2.0),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(width: 8),
                              FaIcon(FontAwesomeIcons.martiniGlassCitrus, color: Colors.white),
                              SizedBox(width: 8),
                              FaIcon(FontAwesomeIcons.wineGlassEmpty, color: Colors.white),
                              SizedBox(width: 8),
                              FaIcon(FontAwesomeIcons.beerMugEmpty, color: Colors.white),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _slideIn,
                          child: FadeTransition(
                            opacity: _opacity,
                            child: const Text(
                              'Your Ultimate Alcohol Atlas!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32), // Add some space between sections
                        SlideTransition(
                          position: _slideIn,
                          child: FadeTransition(
                            opacity: _opacity,
                            child: Column(
                              children: [
                                const Text(
                                  'Please Start By Selecting a Drink',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10.0,
                                        color: Colors.black,
                                        offset: Offset(2.0, 2.0),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const BeerPage()),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.beerMugEmpty, ),
                                      SizedBox(width: 8),
                                      Text('Beer'),
                                      SizedBox(width: 8),
                                      FaIcon(FontAwesomeIcons.beerMugEmpty, ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LiquorPage()),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.martiniGlassCitrus, ),
                                      SizedBox(width: 8),
                                      Text('Liquor'),
                                      SizedBox(width: 8),
                                      FaIcon(FontAwesomeIcons.martiniGlassCitrus,),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const WinePage()),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.wineGlass, ),
                                      SizedBox(width: 8),
                                      Text('Wine'),
                                      SizedBox(width: 8),
                                      FaIcon(FontAwesomeIcons.wineGlass, ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      endDrawer: const NavigationMenu(),
    );
  }
}
