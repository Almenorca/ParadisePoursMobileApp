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
  static const String _userKey = 'user';

  Future<void> saveUserData(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userString = prefs.getString(_userKey); //Can be null if not found.
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));// Convert string to User
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    notifyListeners();
  }
}