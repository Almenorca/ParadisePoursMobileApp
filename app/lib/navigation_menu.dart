import 'package:flutter/material.dart';

class NavigationMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final authService = Provider.of<AuthService>(context);
    // final isLoggedIn = authService.isLoggedIn;
    
    final isLoggedIn = false; // for testing

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Navigation Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading:
                ImageIcon(AssetImage('assets/images/beerbottlefilled2.png')),
            title: Text('Beer'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/beer');
            },
          ),
          ListTile(
            leading: Icon(Icons.local_bar),
            title: Text('Liquor'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/liquor');
            },
          ),
          ListTile(
            leading: Icon(Icons.wine_bar),
            title: Text('Wine'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/wine');
            },
          ),
          ListTile(
            leading: isLoggedIn ? Icon(Icons.logout) : Icon(Icons.login),
            title: isLoggedIn ? Text('Logout') : Text('Login'),
            onTap: () {
              Navigator.pop(context);
              if (isLoggedIn) {
                print('DEBUG: press detected - logout button');
                // authService.logout();
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }
}
