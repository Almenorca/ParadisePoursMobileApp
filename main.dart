import 'package:flutter/material.dart';
import 'package:paradise_pours_app/auth_service.dart';
import 'package:provider/provider.dart';

import 'package:paradise_pours_app/pages/home.dart';
import 'package:paradise_pours_app/pages/beer.dart';
import 'package:paradise_pours_app/pages/liquor.dart';
import 'package:paradise_pours_app/pages/wine.dart';
import 'package:paradise_pours_app/pages/login.dart';
import 'package:paradise_pours_app/pages/settings.dart';
import 'package:paradise_pours_app/pages/about.dart';
import 'package:paradise_pours_app/pages/verify_email.dart';
import 'package:paradise_pours_app/pages/change_password.dart';
import 'package:paradise_pours_app/pages/register.dart';
import 'package:paradise_pours_app/pages/recovery.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Paradise Pours', // name of the app on phone
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        ),
        // home: HomePage(),
        home: const LoginPage(),
        routes: {
          '/home': (context) => const HomePage(),
          '/beer': (context) => const BeerPage(),
          '/liquor': (context) => const LiquorPage(),
          '/wine': (context) => const WinePage(),
          '/login': (context) => const LoginPage(),
          '/settings': (context) => const SettingsPage(),
          '/about': (context) => const AboutUsPage(),
          '/verifyemail': (context) => const VerifyEmailPage(),
          '/changepassword': (context) => const ChangePasswordPage(),
          '/register': (context) => const RegisterPage(),
          '/recovery': (context) => const RecoveryPage(),
        },
      ),
    );
  }
}
