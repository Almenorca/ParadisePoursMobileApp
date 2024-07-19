// import 'package:flutter/material.dart';

// class User {
//   final String id;
//   final String name;
//   final String email;

//   User({
//     required this.id,
//     required this.name,
//     required this.email,
//   });
// }

// class AuthService with ChangeNotifier {
//   User? _user;

//   User? get user => _user;

//   bool get isLoggedIn => _user != null;

//   void login(String email, String password) {
//     // Simulate a login process
//     _user = User(id: '1', name: 'John Doe', email: email);
//     notifyListeners();
//   }

//   void logout() {
//     // Simulate a logout process
//     _user = null;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';

class AuthService with ChangeNotifier {
  String? _userID;

  String? get userID => _userID;

  bool get isLoggedIn => _userID != null;

  void login(String email, String password) {
    // Simulate a login process
    _userID = '1'; // You can set other properties like name and email if needed
    notifyListeners();
  }

  void logout() {
    // Simulate a logout process
    _userID = null;
    notifyListeners();
  }
}
