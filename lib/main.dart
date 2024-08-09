import 'package:cj_webapp/users/DetailChartScreen.dart';
import 'package:cj_webapp/users/MyPage.dart';
import 'package:cj_webapp/users/SignUpScreen.dart';
import 'package:cj_webapp/users/SigninScreen.dart';
import 'package:cj_webapp/users/UserDetailScreen.dart';
import 'package:cj_webapp/users/chartScreen.dart';
import 'package:cj_webapp/users/homeScreen.dart';
import 'package:cj_webapp/users/loginScreen.dart';
import 'package:cj_webapp/users/restTimeScreen.dart';
import 'package:cj_webapp/users/searchUsers.dart';
import 'package:cj_webapp/users/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin/AdminScreen.dart';
import 'admin/userSearchScreen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => userProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<userProvider>(
      builder: (context, userProvider, child) {
        String userId = userProvider.userId ?? '';
        String role = userProvider.role ?? 'user';

        return MaterialApp(
          title: 'CJ Health',
          initialRoute: '/login',
          routes: {
            '/': (context) => HomeScreen(title: 'CJ Health'),
            '/signup': (context) => SignUpScreen(role: 'admin'),
            '/login': (context) => loginScreen(),
            '/home': (context) => HomeScreen(title: 'CJ Health'),
            '/managerMain': (context) =>
            canAccessManagerFeatures(role) ? AdminScreen() : UnauthorizedScreen(),
            '/manageSearch': (context) =>
            canAccessManagerFeatures(role) ? userSearchScreen() : UnauthorizedScreen(),
            '/chart': (context) => chartScreen(),
            '/Detail': (context) => UserDetailScreen(userId: userId),
            '/mypage': (context) => MyPage(userId: userId),
            '/rest': (context) => RestTimeScreen(),
            '/DetailScreen': (context) => Detailchartscreen(),
            '/fingerprint': (context) => SigninScreen(),
            '/searchUsers': (context) => SearchUsers()
          },
        );
      },
    );
  }

  bool canAccessManagerFeatures(String role) {
    return role == 'admin';
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






