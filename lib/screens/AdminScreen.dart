import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<charts.Series<HeartRateData, DateTime>>? _seriesLineData;
  List<HeartRateData> _averageHeartRateData = [];
  List<String> _alertWorkers = [];
  List<String> _currentWorkers = [];
  List<String> _reports = [];
  double _averageHeartRate = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchWorkerData();
    _fetchReports();
  }

  Future<void> _fetchWorkerData() async {
    // Fetch alert workers
    final alertSnapshot = await _databaseRef.child('alert_workers').get();
    final alertData = alertSnapshot.value as Map?;
    if (alertData != null) {
      setState(() {
        _alertWorkers = alertData.values.map((e) => e.toString()).toList(); // Convert to List<String>
      });
    }

    // Fetch current workers
    final workersSnapshot = await _databaseRef.child('current_workers').get();
    final workersData = workersSnapshot.value as Map?;
    if (workersData != null) {
      setState(() {
        _currentWorkers = workersData.values.map((e) => e.toString()).toList(); // Convert to List<String>
      });
    }

    // Fetch average heart rate data for chart
    final heartRateSnapshot = await _databaseRef.child('average_heart_rate_data').get();
    final heartRateData = heartRateSnapshot.value as Map?;
    if (heartRateData != null) {
      final List<HeartRateData> heartRateList = heartRateData.entries.map((e) {
        final timestamp = DateTime.parse(e.key);
        final heartRate = (e.value as Map)['value'] as double;
        return HeartRateData(timestamp, heartRate);
      }).toList();

      setState(() {
        _averageHeartRateData = heartRateList;
        _seriesLineData = [
          charts.Series<HeartRateData, DateTime>(
            id: 'Average Heart Rate',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (HeartRateData data, _) => data.timestamp,
            measureFn: (HeartRateData data, _) => data.heartRate,
            data: heartRateList,
          ),
        ];
      });
    }
  }

  Future<void> _fetchReports() async {
    // Fetch reports
    final reportsSnapshot = await _databaseRef.child('reports').get();
    final reportsData = reportsSnapshot.value as Map?;
    if (reportsData != null) {
      setState(() {
        _reports = reportsData.values.map((e) => e.toString()).toList(); // Convert to List<String>
      });
    }
  }

  void _sendMessage(String workerName) {
    // Implement message sending logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Message'),
        content: Text('Send a message to $workerName'),
        actions: [
          TextButton(
            onPressed: () {
              // Logic to send message
              Navigator.of(context).pop();
            },
            child: Text('Send'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('관리자 화면'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주의 집중 근무자 명단',
              style: TextStyle(fontSize: 10),
            ),
            ..._alertWorkers.map((worker) => ListTile(
              title: Text(worker),
              subtitle: Text('심장 박동수가 불규칙합니다.'),
            )).toList(),
            SizedBox(height: 20),
            Text(
              '근무자 평균 심박수',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(
              height: 300,
              child: _seriesLineData == null
                  ? Center(child: CircularProgressIndicator())
                  : charts.TimeSeriesChart(
                _seriesLineData!,
                animate: true,
                dateTimeFactory: const charts.LocalDateTimeFactory(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '현재 일하고 있는 근무자 리스트',
              style: TextStyle(fontSize: 15),
            ),
            Expanded(
              child: ListView(
                children: _currentWorkers.map((worker) => ListTile(
                  title: Text(worker),
                  trailing: IconButton(
                    icon: Icon(Icons.message),
                    onPressed: () => _sendMessage(worker),
                  ),
                )).toList(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '신고내역',
              style: TextStyle(fontSize: 15),
            ),
            ...(_reports.isNotEmpty
                ? _reports.map((report) => ListTile(
              title: Text(report),
            )).toList()
                : [Text('신고가 없습니다.')]),
          ],
        ),
      ),
    );
  }
}

class HeartRateData {
  final DateTime timestamp;
  final double heartRate;

  HeartRateData(this.timestamp, this.heartRate);
}

