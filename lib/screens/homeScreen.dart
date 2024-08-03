import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

class homeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<homeScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('heart_rate_data');
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isConnected = false;
  List<charts.Series<HeartRateData, DateTime>>? _seriesLineData;
  DateTime? _startWorkTime;
  Timer? _updateTimer;
  List<HeartRateData> _heartRateData = [];

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _fetchHeartRateData();
    _updateTimer = Timer.periodic(Duration(hours: 3), (Timer t) => _fetchHeartRateData());
    _startWorkTime = DateTime.now(); // Example start time
  }

  Future<void> _checkConnection() async {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = (result == ConnectivityResult.wifi || result == ConnectivityResult.mobile);
      });
    } as void Function(List<ConnectivityResult> event)?) as StreamSubscription<ConnectivityResult>?;

    var connectivityResult = await _connectivity.checkConnectivity();
    setState(() {
      _isConnected = (connectivityResult == ConnectivityResult.wifi || connectivityResult == ConnectivityResult.mobile);
    });
  }

  Future<void> _fetchHeartRateData() async {
    final snapshot = await _databaseRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map?;
      if (data != null) {
        final List<HeartRateData> heartRateList = data.entries.map((e) {
          final timestamp = DateTime.parse(e.key);
          final heartRate = (e.value as Map)['value'] as double;
          return HeartRateData(timestamp, heartRate);
        }).toList();

        setState(() {
          _heartRateData = heartRateList;
          _seriesLineData = [
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
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workDuration = _startWorkTime != null ? DateTime.now().difference(_startWorkTime!) : Duration.zero;

    return Scaffold(
      appBar: AppBar(
        title: Text('CJ Health'),
      ),
      body: _isConnected ? _buildContent(workDuration) : _buildNoConnection(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle report action
          Navigator.pushNamed(context, '/report'); // Navigate to a Report Screen
        },
        child: Icon(Icons.report),
        tooltip: 'Report',
      ),
    );
  }

  Widget _buildNoConnection() {
    return Center(
      child: Text('No internet connection.'),
    );
  }

  Widget _buildContent(Duration workDuration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CachedNetworkImage(
          imageUrl: 'https://example.com/cj_health_image.jpg',
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Time since work started: ${workDuration.inHours} hours'),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _seriesLineData == null
              ? CircularProgressIndicator()
              : SizedBox(
            height: 300,
            child: charts.TimeSeriesChart(
              _seriesLineData!,
              animate: true,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Handle help action
              Navigator.pushNamed(context, '/help'); // Navigate to a Help Screen
            },
            child: Text('Help'),
          ),
        ),
        Spacer(),
        Center(
          child: Text(
            '근무 중 자주 휴식을 취하세요.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class HeartRateData {
  final DateTime timestamp;
  final double heartRate;

  HeartRateData(this.timestamp, this.heartRate);
}
