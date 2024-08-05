import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RestTimeScreen extends StatefulWidget {
  @override
  _RestTimeScreenState createState() => _RestTimeScreenState();
}

class _RestTimeScreenState extends State<RestTimeScreen> {
  TimeOfDay? _selectedTime;
  Timer? _timer;

  void _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });

      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      final duration = selectedDateTime.difference(now);

      _timer?.cancel(); // Cancel any existing timer
      _timer = Timer(duration, _showWorkToast);
    }
  }

  void _showWorkToast() {
    Fluttertoast.showToast(
      msg: "It's time to get back to work!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Your Break Time'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'CJ Health',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(title: Text('Home'), onTap: () => Navigator.pushNamed(context, '/home')),
            ListTile(title: Text('Login'), onTap: () => Navigator.pushNamed(context, '/login')),
            ListTile(title: Text('Chart Details'), onTap: () => Navigator.pushNamed(context, '/chart')),
            ListTile(title: Text('Report 119'), onTap: () => Navigator.pushNamed(context, '/call119')),
            ListTile(title: Text('My Page'), onTap: () => Navigator.pushNamed(context, '/mypage')),
            ListTile(title: Text('LogOut'), onTap: () => Navigator.pushNamed(context, '/login')),
          ],
        ),
      ),
      body: Center( // Center the content vertically and horizontally
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Selected break time: ${_selectedTime?.format(context) ?? 'Not set'}',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickTime,
                child: Text('Pick Break Time'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

