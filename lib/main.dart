import 'package:flutter/material.dart';
import 'firebase_service.dart'; // FirebaseService를 사용하여 Firebase 초기화
import 'screens/homeScreen.dart';
import 'screens/SignUpScreen.dart';
import 'screens/loginScreen.dart';
import 'package:cj_webapp/screens/AdminScreen.dart';
import 'package:cj_webapp/screens/MyPage.dart';
import 'package:cj_webapp/screens/UserDetailScreen.dart';
import 'package:cj_webapp/screens/chartScreen.dart';
import 'package:cj_webapp/screens/userSearchScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
        '/managerMain': (context) => AdminScreen(),
        '/manageSearch': (context) => userSearchScreen(),
        '/chart': (context) => chartScreen(),
        '/Detail': (context) => UserDetailScreen(userId: null), // userId를 null로 설정
        '/mypage': (context) => MyPage(),
      },
    );
  }
}



