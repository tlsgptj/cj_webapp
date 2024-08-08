import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class userProvider with ChangeNotifier {
  User? _user;
  String? _role;

  User? get user => _user;
  String? get userId => _user?.uid;
  String? get role => _role;

  Future<void> setUser(User? user) async {
    _user = user;
    if (user != null) {
      await _fetchUserRole();
    }
    notifyListeners();
  }

  Future<void> _fetchUserRole() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists && userDoc.data() is Map) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          _role = userData['role'];
        } else {
          _role = null;
        }
      } catch (e) {
        print('Failed to fetch user role: $e');
        _role = null;
      }
    }
  }
}

