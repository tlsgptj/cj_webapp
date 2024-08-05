import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users/user1');
  String _name = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    try {
      final snapshot = await _userRef.get();
      if (snapshot.exists) {
        setState(() {
          _name = snapshot.child('name').value.toString();
        });
      } else {
        setState(() {
          _name = 'No user data found';
        });
      }
    } catch (e) {
      setState(() {
        _name = 'User1';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.blue,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    SizedBox(height: 40),
                    Text('Name: $_name', style: TextStyle(fontSize: 30, color: Colors.white)),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            ...List.generate(
              _menuItems.length,
                  (index) => ListTile(
                title: Text(_menuItems[index].title),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _menuItems[index].onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final String title;
  final VoidCallback onTap;

  MenuItem(this.title, this.onTap);
}

List<MenuItem> _menuItems = [
  MenuItem('프로필 수정', () => print('Edit Profile Clicked')),
  MenuItem('비밀번호 변경', () => print('Change Password Clicked')),
  MenuItem('알람 설정', () => print('Push Notifications Clicked')),
  MenuItem('신고 내역 조회', () => print('View Reports Clicked')),
  MenuItem('공지사항', () => print('Notice Clicked')),
  MenuItem('1:1 문의', () => print('1:1 Inquiry Clicked')),
  MenuItem('고객 서비스', () => print('Customer Service Clicked')),
  MenuItem('설정', () => print('Settings Clicked')),
];
