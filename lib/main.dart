import 'package:flutter/material.dart';
import 'package:cj_webapp/screens/homeScreen.dart';
import 'package:cj_webapp/screens/SignUpScreen.dart';
import 'package:cj_webapp/screens/loginScreen.dart';
import 'package:cj_webapp/screens/AdminScreen.dart';
import 'package:cj_webapp/screens/MyPage.dart';
import 'package:cj_webapp/screens/UserDetailScreen.dart';
import 'package:cj_webapp/screens/chartScreen.dart';
import 'package:cj_webapp/screens/userSearchScreen.dart';
import 'firebase_service.dart'; // FirebaseService를 사용하여 Firebase 초기화

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
      home: HomeScreen(title: 'CJ Health'), // 홈 화면을 설정
      routes: {
        '/signup': (context) => SignUpScreen(),
        '/login': (context) => loginScreen(),
        '/home': (context) => HomeScreen(title: 'CJ Health'), // title 전달
        '/managerMain': (context) => AdminScreen(),
        '/manageSearch': (context) => userSearchScreen(),
        '/chart': (context) => chartScreen(),
        '/Detail': (context) => UserDetailScreen(userId: null), // userId를 null로 설정
        '/mypage': (context) => MyPage(),
      },
    );
  }
}



