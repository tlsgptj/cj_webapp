import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  final String role;

  SignUpScreen({required this.role});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = '남성';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    if (password != confirmPassword) {
      Fluttertoast.showToast(msg: "비밀번호가 일치하지 않습니다.");
      return;
    }

    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Upload profile image to Firebase Storage
      String? imageUrl;
      if (_imageFile != null) {
        final ref = _storage.ref().child('user_images').child(userCredential.user!.uid + '.jpg');
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // Store user data in Firestore
      String collection = widget.role == 'admin' ? 'admins' : 'users';
      await _firestore.collection(collection).doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phone,
        'gender': _selectedGender,
        'role': widget.role,
        'profileImageUrl': imageUrl,
      });

      Fluttertoast.showToast(msg: "회원가입 성공");

      // Navigate to home or main screen
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      Fluttertoast.showToast(msg: "회원가입 실패: ${e}");
    }
  }

  Future<void> _checkEmailDuplicate() async {
    String email = _emailController.text.trim();

    try {
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isEmpty) {
        Fluttertoast.showToast(msg: "이메일 사용 가능합니다");
      } else {
        Fluttertoast.showToast(msg: "이미 사용중인 이메일입니다.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "이메일 확인 에러: ${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.role == 'admin' ? '관리자' : '일반'} 회원 가입',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '회원 가입',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _emailController,
                '이메일',
                false,
                icon: Icons.email,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _passwordController,
                '비밀번호',
                true,
                icon: Icons.lock,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _confirmPasswordController,
                '비밀번호 확인',
                true,
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _nameController,
                '이름',
                false,
                icon: Icons.person,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                _phoneController,
                '번호',
                false,
                icon: Icons.phone,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('남성'),
                      value: '남성',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('여성'),
                      value: '여성',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _checkEmailDuplicate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  '이메일 확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  '이미지 등록',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    _imageFile!,
                    height: 100,
                    width: 100,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[200],
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String labelText, bool obscureText,
      {IconData? icon}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}




