import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../admin/MemberSelectionScreen.dart';

class loginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<loginScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _authenticateWithBiometrics() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      if (!isAvailable) {
        _showSnackbar('Biometric authentication is not available');
        return;
      }

      final isAuthenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to log in',
      );

      if (isAuthenticated) {
        _showSnackbar('Authentication successful');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showSnackbar('Authentication failed');
      }
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  Future<void> _loginWithEmailAndPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    try {
      UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      _showSnackbar('Login failed: ${e.toString()}');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(
            0xFF006ECD), // Ensuring the app bar matches the theme
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFF7F8FA),
        alignment: Alignment.center,
        // Center the stack within the container
        child: SingleChildScrollView( // Ensuring the form is scrollable on smaller devices
          child: Column(
            mainAxisSize: MainAxisSize.min, // Minimize the height of the column
            children: [
              _buildLoginForm(),
              SizedBox(height: 20),
              _buildAuxiliaryOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: 360, // A fixed width for the form
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF2F9FF),
        border: Border.all(width: 1, color: Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loginWithEmailAndPassword,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF006ECD),
              // Button text color
              minimumSize: Size(double.infinity, 48), // Full width button
            ),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuxiliaryOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAuxiliaryButton('Find ID', _onFindIdPressed),
          _buildAuxiliaryButton('Find Password', _onFindPasswordPressed),
          _buildAuxiliaryButton('Sign Up', _onSignUpPressed),
          _buildAuxiliaryButton('지문 인식', _onSignUpPressed),
        ],
      ),
    );
  }

  Widget _buildAuxiliaryButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: Colors.blue)),
    );
  }

  void _onFindIdPressed() {
    print("Find ID button pressed");
  }

  void _onFindPasswordPressed() {
    print("Find Password button pressed");
  }

  void _onSignUpPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MemberSelectionScreen()),
    );
  }
}


