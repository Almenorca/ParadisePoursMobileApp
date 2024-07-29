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
  static const String _beerOfTheDayKey = 'beerOfTheDay';
  static const String _beerOfTheDayDateKey = 'beerOfTheDayDate';
  static const String _wineOfTheMonthKey = 'wineOfTheMonth';
  static const String _wineOfTheMonthDateKey = 'wineOfTheMonthDate';

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

  // Saves Beer of the Day
  Future<void> saveBeerOfTheDay(Map<String, dynamic> beer) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_beerOfTheDayKey, jsonEncode(beer));
    await prefs.setString(_beerOfTheDayDateKey, DateTime.now().toIso8601String().split('T').first);
  }

  // Retrieves Beer of the Day
  Future<Map<String, dynamic>?> getBeerOfTheDay() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? beerString = prefs.getString(_beerOfTheDayKey);
    String? dateString = prefs.getString(_beerOfTheDayDateKey);

    if (beerString != null && dateString != null) {
      DateTime storedDate = DateTime.parse(dateString);
      DateTime currentDate = DateTime.now();
      if (storedDate.day == currentDate.day) {
        return jsonDecode(beerString);
      }
    }
    return null;
  }

  // Saves Wine of the Month
  Future<void> saveWineOfTheMonth(Map<String, dynamic> wine) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wineOfTheMonthKey, jsonEncode(wine));
    await prefs.setString(_wineOfTheMonthDateKey, DateTime.now().toIso8601String().split('T').first);
  }

  // Retrieves Wine of the Month
  Future<Map<String, dynamic>?> getWineOfTheMonth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? wineString = prefs.getString(_wineOfTheMonthKey);
    String? dateString = prefs.getString(_wineOfTheMonthDateKey);

    if (wineString != null && dateString != null) {
      DateTime storedDate = DateTime.parse(dateString);
      DateTime currentDate = DateTime.now();
      if (storedDate.month == currentDate.month) {
        return jsonDecode(wineString);
      }
    }
    return null;
  }
}