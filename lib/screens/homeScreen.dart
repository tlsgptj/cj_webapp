import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http; // Add this for HTTP requests

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _heartRateRef = FirebaseDatabase.instance.ref().child('heart_rate');
  String _currentHeartRate = 'Loading...';
  List<FlSpot> _heartRateSpots = [];
  final Random _random = Random();
  double _stressIndex = 50; // Stress index starting value for demonstration

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateDummyHeartRateData(); // Initial data generation
    // Timer for periodic updates to simulate real-time data generation every 10 minutes
    _timer = Timer.periodic(Duration(minutes: 10), (Timer t) => _generateDummyHeartRateData());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _sendFCMMessage() async {
    const String serverKey = 'YOUR_SERVER_KEY'; // Replace with your server key
    const String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notificationData = {
      "notification": {
        "title": "High Heart Rate Alert",
        "body": "Heart rate exceeded 150 bpm!"
      },
      "priority": "high",
      "to": "/topics/all", // Replace with specific token or topic if needed
    };

    final response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: notificationData,
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully.');
    } else {
      print('Failed to send FCM message.');
    }
  }

  void _generateDummyHeartRateData() {
    if (_heartRateSpots.length >= 10) {
      // Remove the first spot if there are already 10 spots
      _heartRateSpots.removeAt(0);
    }

    // Add a new data point with a random heart rate value
    final double nextX = _heartRateSpots.isNotEmpty ? _heartRateSpots.last.x + 10 : 0; // 10 minutes intervals
    final double nextY = 60 + _random.nextInt(100).toDouble();
    _heartRateSpots.add(FlSpot(nextX, nextY));

    if (nextY > 150) {
      _sendFCMMessage(); // Send FCM message if heart rate exceeds 150
    }

    setState(() {
      _currentHeartRate = '${nextY.toInt()} bpm';
      _stressIndex = _random.nextDouble() * 100; // Random stress index for demo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.lightBlue,
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('마지막 동기화 현재 시간: ${DateTime.now().toLocal()}'),
              SizedBox(height: 8),
              _buildHeartRateChart(),
              SizedBox(height: 20),
              _buildStressIndicator(),
              SizedBox(height: 20),
              _buildActionButtons(),
              SizedBox(height: 20),
              Text('스트레스 관리를 위한 추천:', style: TextStyle(fontSize: 25), textAlign: TextAlign.center),
              Text('마음을 편안히 하세요.', style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
    );
  }

  Widget _buildHeartRateChart() {
    return Container(
      height: 500,
      child: BarChart(
        BarChartData(
          maxY: 200, // Set max Y value to 200
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}m'),
              ),
            ),
          ),
          barGroups: _heartRateSpots.map((spot) {
            return BarChartGroupData(
              x: spot.x.toInt(),
              barRods: [BarChartRodData(toY: spot.y, color: Colors.orange)],
            );
          }).toList(),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: const Color(0xff37434d),
              width: 1,
            ),
          ),
          barTouchData: BarTouchData(enabled: false),
        ),
      ),
    );
  }

  Widget _buildStressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('심장 박동수: $_currentHeartRate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: _stressIndex / 100,
          color: _stressIndex > 75 ? Colors.red : Colors.green,
          backgroundColor: Colors.grey[300],
        ),
        SizedBox(height: 8),
        Text('스트레스 지수: ${_stressIndex.toStringAsFixed(0)}%', style: TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton('신고', Icons.report, Colors.red, '119에 신고가 접수되었습니다.'),
        _actionButton('도움', Icons.help, Colors.blue, '관리자에게 도움을 요청했습니다.'),
      ],
    );
  }

  Widget _actionButton(String label, IconData icon, Color color, String message) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(fontSize: 40)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color,
        minimumSize: Size(200, 200),
      ),
      onPressed: () {
        // Display a snackbar with the appropriate message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(seconds: 5),
          ),
        );
      },
    );
  }
}










