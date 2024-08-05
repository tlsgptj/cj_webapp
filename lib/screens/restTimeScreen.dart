import 'dart:async';
import 'package:flutter/material.dart';

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
      _timer = Timer(duration, _showWorkSnackBar);
    }
  }

  void _showWorkSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("다시 일할 시간이에요!! 힘내보아요:)"),
        duration: Duration(days: 1), // Set a long duration
        action: SnackBarAction(
          label: "확인",
          textColor: Colors.white,
          onPressed: () {
            // Dismiss the snackbar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
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
        title: Text('뽀모도로 설정'),
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
            ListTile(title: Text('차트보기'), onTap: () => Navigator.pushNamed(context, '/chart')),
            ListTile(title: Text('119신고'), onTap: () => Navigator.pushNamed(context, '/call119')),
            ListTile(title: Text('마이페이지'), onTap: () => Navigator.pushNamed(context, '/mypage')),
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
                '쉬는 시간을 설정하세요!: ${_selectedTime?.format(context) ?? '쉬는 시간이 설정되지 않았습니다.'}',
                style: TextStyle(fontSize: 30),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _pickTime,
                icon: Icon(Icons.timer, size: 30),
                label: Text('뽀모도로 설정'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


