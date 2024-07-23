import 'package:flutter/material.dart';
import 'package:paradise_pours_app/auth_service.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return FutureBuilder<bool>(
      future: authService.isLoggedIn(),
      builder: (context, snapshot) {
      bool isLoggedIn = snapshot.data ?? false;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Paradise_Pours_Logo.png'),
                    fit: BoxFit.cover,
                  ),
                  color: Color(0xffa0522d),
                ),
                child: Column(
                children: [
                    Text(
                    'Navigation Menu',
                    style: TextStyle(
                      color: Colors.white,
                    fontSize: 24,
                      ),
                  ),
                  ImageIcon(
                      AssetImage('assets/images/Paradise_Pours_Logo.png'),
                  ),
                 ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/home');
                },
              ),
              ListTile(
                leading: const ImageIcon(
                  AssetImage('assets/images/beerbottlefilled2.png'),
                ),
                title: const Text('Beer'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/beer');
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_bar),
                title: const Text('Liquor'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/liquor');
                },
              ),
              ListTile(
                leading: const Icon(Icons.wine_bar),
                title: const Text('Wine'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/wine');
                },
              ),
              ListTile(
                leading: isLoggedIn ? const Icon(Icons.logout) : const Icon(Icons.login),
                title: isLoggedIn ? const Text('Logout') : const Text('Login'),
                onTap: () async {
                  Navigator.pop(context);
                  if (isLoggedIn) {
                    await authService.logout();
                    Navigator.pushNamed(context, '/login');
                  } else {
                    Navigator.pushNamed(context, '/login');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/about');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}