import 'package:cj_webapp/admin/AdminScreen.dart';
import 'package:cj_webapp/users/DetailChartScreen.dart';
import 'package:cj_webapp/users/MyPage.dart';
import 'package:cj_webapp/users/SignUpScreen.dart';
import 'package:cj_webapp/users/UserDetailScreen.dart';
import 'package:cj_webapp/users/chartScreen.dart';
import 'package:cj_webapp/users/homeScreen.dart';
import 'package:cj_webapp/users/loginScreen.dart';
import 'package:cj_webapp/users/restTimeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'admin/userSearchScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Assuming `currentUserRole` is globally accessible after login
  final String currentUserRole = 'admin'; // This should be dynamically set after user login

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CJ Health',
      initialRoute: '/login',
      routes: {
        '/': (context) => HomeScreen(title: 'CJ Health'),
        '/signup': (context) => SignUpScreen(role: 'admin'),
        '/login': (context) => loginScreen(),
        '/home': (context) => HomeScreen(title: 'CJ Health'),
        '/managerMain': (context) =>
        canAccessManagerFeatures(currentUserRole)
            ? AdminScreen()
            : UnauthorizedScreen(),
        '/manageSearch': (context) =>
        canAccessManagerFeatures(currentUserRole)
            ? userSearchScreen()
            : UnauthorizedScreen(),
        '/chart': (context) => chartScreen(),
        '/Detail': (context) => UserDetailScreen(userId: null),
        '/mypage': (context) => MyPage(),
        '/rest': (context) => RestTimeScreen(),
        '/DetailScreen': (context) => Detailchartscreen()
      },
    );
  }

  canAccessManagerFeatures(String currentUserRole) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<bool> canAccessManagerFeatures() async {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(
            currentUser.uid).get();
        if (userDoc.exists && userDoc.data() is Map) {
          Map userData = userDoc.data() as Map;
          if (userData['role'] == 'admin') {
            return true;
          }
        }
      }
      return false;
    }
  }
}


class UnauthorizedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("접근 권한 제한"),
      ),
      body: Center(
        child: Text("접근 권한이 제한된 페이지입니다."),
      ),
    );
  }
}




