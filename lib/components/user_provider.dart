// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Import the provider package
// import 'package:shared_preferences/shared_preferences.dart';

// class User {
//   String userID;

//   User({required this.userID});
// }

// class UserProvider with ChangeNotifier {
//   User? _user;

//   User? get user => _user;

//   void setUser(String userID) {
//     _user = User(userID: userID);
//     notifyListeners();
//   }

// // Future<void> setUserID(String userId) async {
// //   SharedPreferences prefs = await SharedPreferences.getInstance();
// //   await prefs.setString('userID', userId);
// // }

//   void loadUserFromStorage() {
//     // Retrieve user ID from local storage (shared preferences example)
//     String? storedUserID =
//         localStorage.getItem('userID'); // Retrieve userID from local storage
//     if (storedUserID != null) {
//       setUser(storedUserID);
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  String userID;

  User({required this.userID});
}

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  Future<void> setUser(String userID) async {
    _user = User(userID: userID);
    notifyListeners();

    // Store userID in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userID', userID);
  }

  Future<void> loadUserFromStorage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUserID = prefs.getString('userID');

      if (storedUserID != null) {
        setUser(storedUserID);
      }
    } catch (e) {
      print('Error loading user from storage: $e');
      // Handle error appropriately, e.g., notify user or fallback to default behavior
    }
  }
}
