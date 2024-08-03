import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class UserDetailScreen extends StatefulWidget {
  final String userId;

  UserDetailScreen({required this.userId});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<HeartRateData> _heartRateData = [];
  List<charts.Series<HeartRateData, DateTime>>? _chartSeries;
  double _threshold = 0.0;
  List<String> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch heart rate data
    final heartRateSnapshot = await _databaseRef.child('users/${widget.userId}/heart_rate_data').get();
    final heartRateData = heartRateSnapshot.value as Map?;
    if (heartRateData != null) {
      final List<HeartRateData> heartRateList = heartRateData.entries.map((e) {
        final timestamp = DateTime.parse(e.key);
        final heartRate = (e.value as Map)['value'] as double;
        return HeartRateData(timestamp, heartRate);
      }).toList();

      setState(() {
        _heartRateData = heartRateList;
        _chartSeries = [
          charts.Series<HeartRateData, DateTime>(
            id: 'HeartRate',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (HeartRateData data, _) => data.timestamp,
            measureFn: (HeartRateData data, _) => data.heartRate,
            data: heartRateList,
          ),
        ];
      });
    }

    // Fetch threshold
    final thresholdSnapshot = await _databaseRef.child('users/${widget.userId}/threshold').get();
    final thresholdValue = thresholdSnapshot.value as double?;
    setState(() {
      _threshold = thresholdValue ?? 0.0;
    });

    // Fetch reports
    final reportsSnapshot = await _databaseRef.child('users/${widget.userId}/reports').get();
    final reportsData = reportsSnapshot.value as Map?;
    if (reportsData != null) {
      setState(() {
        _reports = reportsData.values.map((e) {
          final details = (e as Map)['details'] as String;
          return details;
        }).toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateThreshold(double newThreshold) async {
    await _databaseRef.child('users/${widget.userId}/threshold').set(newThreshold);
    setState(() {
      _threshold = newThreshold;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: ${widget.userId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Threshold: ${_threshold.toStringAsFixed(2)}'),
            Row(
              children: [
                Text('Set Threshold: '),
                Expanded(
                  child: Slider(
                    value: _threshold,
                    min: 0.0,
                    max: 200.0,
                    divisions: 200,
                    onChanged: (value) {
                      setState(() {
                        _threshold = value;
                      });
                    },
                    onChangeEnd: _updateThreshold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Heart Rate Chart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 300,
              child: _chartSeries == null
                  ? Center(child: CircularProgressIndicator())
                  : charts.TimeSeriesChart(
                _chartSeries!,
                animate: true,
                dateTimeFactory: const charts.LocalDateTimeFactory(),
              ),
            ),
            SizedBox(height: 20),
            Text('Report History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: _reports.isNotEmpty
                    ? _reports.map((report) => ListTile(title: Text(report))).toList()
                    : [Text('No reports available')],
              ),
            ),
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

