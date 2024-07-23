import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class User {
  final int userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['UserId'],
      username: json['Username'],
      email: json['Email'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      phone: json['Phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UserId': userId,
      'Username': username,
      'Email': email,
      'FirstName': firstName,
      'LastName': lastName,
      'Phone': phone,
    };
  }
}

class AuthService extends ChangeNotifier {
  static const String _userKey = 'user'; //Key used to mark user data.

  //Saves User data from api login call
  Future<void> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  //Use this to retrieve user data in each page.
  Future<User?> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString(_userKey); //Retrives user string from shared preferences
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));// User string is decoded to retriever user information.
    }
    return null;
  }

  //Checks if user logged in. Purpose is for the navigation menu mainly.
  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  //Clears user data
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }
}