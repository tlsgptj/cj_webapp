import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart'; // Import the fl_chart package
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

import 'AdminScreen.dart';
import 'HeartRateData.dart';

class homeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<homeScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref('heart_rate_data');
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<DatabaseEvent>? _databaseSubscription;
  bool _isConnected = false;
  List<HeartRateData> _heartRateData = [];
  DateTime? _startWorkTime;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _fetchInitialHeartRateData();
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

  Future<void> _fetchInitialHeartRateData() async {
    _databaseSubscription = _databaseRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final List<HeartRateData> heartRateList = data.entries.map((e) {
          final timestamp = DateTime.parse(e.key);
          final heartRate = (e.value as Map)['value'] as double;
          return HeartRateData(timestamp, heartRate);
        }).toList();

        setState(() {
          _heartRateData = heartRateList;
        });
      }
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
        });
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _databaseSubscription?.cancel();
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
    // Convert data to FlSpot
    List<FlSpot> spots = _heartRateData.map((data) => FlSpot(
      data.timestamp.millisecondsSinceEpoch.toDouble(),
      data.heartRate,
    )).toList();

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
          child: _heartRateData.isEmpty
              ? CircularProgressIndicator()
              : SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      final spot = barData.spots[spotIndex];
                      if (spot.x == 0 || spot.x == 6) {
                        return null;
                      }
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.white24,
                          strokeWidth: 4,
                        ),
                        FlDotData(show: true), // Provide the second argument here
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final flSpot = barSpot;
                        if (flSpot.x == 0 || flSpot.x == 6) {
                          return null;
                        }
                        return LineTooltipItem(
                          '${flSpot.x.toInt()}일 수면시간\n',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: '${flSpot.y.toInt()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const TextSpan(
                              text: ' 시간 ',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                          textAlign: TextAlign.center,
                        );
                      }).toList();
                    },
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 6.5,
                      color: Color(0xFFEAECFF),
                      strokeWidth: 2,
                      dashArray: [20, 10],
                    ),
                  ],
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.white10,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Text(
                        '$value',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white10),
                ),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty ? [FlSpot(0, 0)] : spots,
                    isCurved: true,
                    color: Colors.blue,
                    gradient: LinearGradient(
                      colors: [Colors.blue.withOpacity(0.6), Colors.blue.withOpacity(0.3)],
                    ),
                    barWidth: 5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.1)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
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


