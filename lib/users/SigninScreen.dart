import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  // LocalAuthentication 인스턴스
  final LocalAuthentication localAuth = LocalAuthentication();

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
        // 지문 등록이 성공하면 메시지를 표시하고 로그인 화면으로 이동
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
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showFingerprintDialog,
          child: const Text('지문으로 로그인'),
        ),
      ),
    );
  }
}
