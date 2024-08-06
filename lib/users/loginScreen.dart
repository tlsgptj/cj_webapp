import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import '../admin/MemberSelectionScreen.dart';
import 'SigninScreen.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginScreen> {
  // 이메일과 비밀번호 입력 필드를 위한 컨트롤러
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 폼의 상태를 관리하기 위한 GlobalKey
  final _formKey = GlobalKey<FormState>();

  // FirebaseAuth 인스턴스
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // LocalAuthentication 인스턴스
  final LocalAuthentication localAuth = LocalAuthentication();

  // 지문 인증을 수행하는 메서드
  Future<void> _authenticateWithBiometrics() async {
    try {
      final isAvailable = await localAuth.canCheckBiometrics;
      if (!isAvailable) {
        _showSnackbar('지문 인증이 허용되지 않습니다.');
        return;
      }

      // 지문 인증 수행
      final isAuthenticated = await localAuth.authenticate(
        localizedReason: '로그인을 위한 인증을 수행하세요',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      // 인증 성공 시
      if (isAuthenticated) {
        _showSnackbar('인증 성공');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showSnackbar('인증 실패');
      }
    } catch (e) {
      _showSnackbar('인증 실패: $e');
    }
  }

  // 이메일과 비밀번호로 로그인
  Future<void> _loginWithEmailAndPassword() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (_formKey.currentState!.validate()) {
      try {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        _showSnackbar('로그인 실패: ${e.toString()}');
      }
    }
  }

  // 스낵바를 표시하는 메서드
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // 위젯 빌드 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
        backgroundColor: const Color(0xFF006ECD),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF7F8FA),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLoginForm(),
              const SizedBox(height: 20),
              _buildAuxiliaryOptions(),
            ],
          ),
        ),
      ),
    );
  }

  // 로그인 폼 위젯
  Widget _buildLoginForm() {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F9FF),
        border: Border.all(width: 1, color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '이메일을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '비밀번호 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithEmailAndPassword,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF006ECD),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }

  // 보조 옵션 위젯
  Widget _buildAuxiliaryOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAuxiliaryButton('ID 찾기', _onFindIdPressed),
          _buildAuxiliaryButton('Password 찾기', _onFindPasswordPressed),
          _buildAuxiliaryButton('회원가입', _onSignUpPressed),
          _buildAuxiliaryButton('지문으로 로그인', _authenticateWithBiometrics),
          _buildAuxiliaryButton('지문등록하기', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SigninScreen()),
            );
          }),
        ],
      ),
    );
  }

  // 보조 버튼 위젯
  Widget _buildAuxiliaryButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: Colors.blue)),
    );
  }

  // ID 찾기 버튼 클릭 핸들러
  void _onFindIdPressed() {
    print("ID 찾기 버튼");
  }

  // 비밀번호 찾기 버튼 클릭 핸들러
  void _onFindPasswordPressed() {
    print("Password 찾기 버튼");
  }

  // 회원가입 버튼 클릭 핸들러
  void _onSignUpPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MemberSelectionScreen()),
    );
  }
}



