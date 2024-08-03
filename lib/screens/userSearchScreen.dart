import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'UserDetailScreen.dart';

class userSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<userSearchScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<String> _userList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUserList();
  }

  Future<void> _fetchUserList() async {
    final snapshot = await _databaseRef.child('users').get();
    if (snapshot.exists) {
      final users = snapshot.value as Map?;
      if (users != null) {
        setState(() {
          _userList = users.keys.map((key) => key.toString()).toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search User',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: _userList
                  .where((user) => user.toLowerCase().contains(_searchQuery))
                  .map((user) => ListTile(
                title: Text(user),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailScreen(userId: user),
                    ),
                  );
                },
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}


