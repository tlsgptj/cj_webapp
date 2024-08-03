import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MyPage extends StatefulWidget {
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
        _name = 'Error fetching user data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $_name', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle profile edit action
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Edit Profile Clicked')));
              },
              child: Text('Edit Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle password change action
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Change Password Clicked')));
              },
              child: Text('Change Password'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle push notifications settings
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Push Notifications Clicked')));
              },
              child: Text('Push Notifications'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/call119');
              },
              child: Text('View Reports'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notice Clicked')));
              },
              child: Text('Notice'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Inquiry Clicked')));
              },
              child: Text('1:1 Inquiry'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Customer Service Clicked')));
              },
              child: Text('Customer Service'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings Clicked')));
              },
              child: Text('Settings'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/searchActivity');
              },
              child: Text('Chart Pic'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('My Page Clicked')));
              },
              child: Text('My Page'),
            ),
          ],
        ),
      ),
    );
  }
}
