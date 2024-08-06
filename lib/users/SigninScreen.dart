import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final LocalAuthentication localAuth = LocalAuthentication();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // 사용자 인증 메서드
  Future<void> _authenticateUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 이메일과 비밀번호로 사용자 인증
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // 인증 성공 시 지문 등록 다이얼로그 표시
        _showFingerprintDialog();
      } catch (e) {
        // 인증 실패 시 오류 메시지 표시
        print('인증 실패: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('인증 실패: ${e.toString()}')),
        );
      }
    }
  }

  // 지문을 등록하는 메서드
  Future<void> _registerFingerprint() async {
    try {
      // 지문 인증을 수행
      bool didAuthenticate = await localAuth.authenticate(
        localizedReason: '지문 등록을 수행하세요',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // 지문 등록이 성공하면 메시지를 표시하고 홈 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('지문 등록 성공')),
        );
        Navigator.pushNamed(context, '/home'); // 성공 시 홈 화면으로 이동
      }
    } catch (e) {
      // 에러가 발생하면 에러 메시지를 표시
      print('지문 등록 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('지문 등록 실패: ${e.toString()}')),
      );
    }
  }

  // 지문 등록 여부를 묻는 다이얼로그를 표시하는 메서드
  void _showFingerprintDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지문 등록하기'),
        content: const Text('지문등록을 수행하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              // 지문 등록을 하지 않고 종료
              Navigator.of(context).pop();
            },
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () async {
              // 지문 등록을 수행
              Navigator.of(context).pop();
              await _registerFingerprint();
            },
            child: const Text('네'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지문 로그인'),
        backgroundColor: Colors.blue[900], // 앱바 배경색 설정
      ),
      body: Container(
        color: Colors.blue[50], // 전체 배경색 설정
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _authenticateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900], // 버튼 배경색 설정
                    minimumSize: const Size(double.infinity, 48), // 버튼 크기 설정
                  ),
                  child: const Text('로그인 후 지문 등록'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
