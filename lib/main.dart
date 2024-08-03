import 'package:cj_webapp/screens/AdminScreen.dart';
import 'package:cj_webapp/screens/MyPage.dart';
import 'package:cj_webapp/screens/SignUpScreen.dart';
import 'package:cj_webapp/screens/UserDetailScreen.dart';
import 'package:cj_webapp/screens/chartScreen.dart';
import 'package:cj_webapp/screens/userSearchScreen.dart';
import 'package:flutter/material.dart';
import 'screens/homeScreen.dart';
import 'screens/SignUpScreen.dart';
import 'screens/loginScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  get userId => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CJ project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: homeScreen(),
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => loginScreen(),
        '/home': (context) => homeScreen(),
        '/managerMain' : (context) => AdminScreen(),
        '/manageSearch' : (context) => userSearchScreen(),
        '/chart': (context) => chartScreen(),
        '/Detail': (context) => UserDetailScreen(userId: userId),
        '/mypage' : (context) => MyPage()
      },
    );
  }
}

