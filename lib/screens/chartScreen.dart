import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:connectivity_plus/connectivity_plus.dart';

class chartScreen extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<chartScreen> {
  final DatabaseReference _heartRateRef = FirebaseDatabase.instance.ref().child('heart_rate');
  String _currentHeartRate = 'Loading...';
  List<charts.Series<HeartRateData, DateTime>> _dailyChartSeries = [];
  List<charts.Series<HeartRateData, DateTime>> _weeklyChartSeries = [];

  @override
  void initState() {
    super.initState();
    _fetchHeartRateData();
    _fetchHeartRateStatistics();
  }

  void _fetchHeartRateData() async {
    try {
      final snapshot = await _heartRateRef.child('current').get();
      if (snapshot.exists) {
        setState(() {
          _currentHeartRate = snapshot.value.toString();
        });
      } else {
        setState(() {
          _currentHeartRate = 'No data';
        });
      }
    } catch (e) {
      setState(() {
        _currentHeartRate = 'Error fetching data';
      });
    }
  }

  void _fetchHeartRateStatistics() async {
    // Dummy data for charts
    final List<HeartRateData> dailyData = [
      HeartRateData(DateTime.now().subtract(Duration(days: 1)), 72),
      HeartRateData(DateTime.now(), 75),
    ];
    final List<HeartRateData> weeklyData = [
      HeartRateData(DateTime.now().subtract(Duration(days: 6)), 70),
      HeartRateData(DateTime.now().subtract(Duration(days: 5)), 74),
      HeartRateData(DateTime.now().subtract(Duration(days: 4)), 71),
      HeartRateData(DateTime.now().subtract(Duration(days: 3)), 76),
      HeartRateData(DateTime.now().subtract(Duration(days: 2)), 73),
      HeartRateData(DateTime.now().subtract(Duration(days: 1)), 72),
      HeartRateData(DateTime.now(), 75),
    ];

    setState(() {
      _dailyChartSeries = [
        charts.Series<HeartRateData, DateTime>(
          id: 'Daily Heart Rate',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (HeartRateData data, _) => data.time,
          measureFn: (HeartRateData data, _) => data.heartRate,
          data: dailyData,
        ),
      ];
      _weeklyChartSeries = [
        charts.Series<HeartRateData, DateTime>(
          id: 'Weekly Heart Rate',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (HeartRateData data, _) => data.time,
          measureFn: (HeartRateData data, _) => data.heartRate,
          data: weeklyData,
        ),
      ];
    });
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
            Center(
              child: Image.asset(
                'assets/cj_health.png', // 실제 경로로 변경
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(height: 20),
            Text('Current Heart Rate: $_currentHeartRate bpm', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('Daily Heart Rate Statistics:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: charts.TimeSeriesChart(
                _dailyChartSeries,
                animate: true,
              ),
            ),
            SizedBox(height: 20),
            Text('Weekly Heart Rate Statistics:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: charts.TimeSeriesChart(
                _weeklyChartSeries,
                animate: true,
              ),
            ),
            Spacer(),
            Center(
              child: Text(
                '근무 중 자주 휴식을 취하세요.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chart');
                  },
                  child: Text('Go to Chart'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/myPage');
                  },
                  child: Text('My Page'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HeartRateData {
  final DateTime time;
  final int heartRate;

  HeartRateData(this.time, this.heartRate);
}
