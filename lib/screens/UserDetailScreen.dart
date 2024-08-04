import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

import 'HeartRateData.dart';

class UserDetailScreen extends StatefulWidget {
  final String? userId;

  UserDetailScreen({required this.userId});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<HeartRateData> _heartRateData = [];
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

  LineChartData _lineChartData() {
    List<FlSpot> spots = _heartRateData.map((data) {
      return FlSpot(
        data.timestamp.millisecondsSinceEpoch.toDouble(),
        data.heartRate,
      );
    }).toList();

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              return LineTooltipItem(
                '${DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt()).toLocal().toString().split(' ')[0]}\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${flSpot.y.toStringAsFixed(1)} bpm',
                    style: TextStyle(
                      color: Colors.white,
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
            y: _threshold,
            color: Color(0xFFEAECFF),
            strokeWidth: 2,
            dashArray: [20, 10],
          ),
        ],
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 10,
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
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text('${date.day}/${date.month}'),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text('$value bpm'),
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white10),
      ),
      minX: _heartRateData.isNotEmpty ? _heartRateData.first.timestamp.millisecondsSinceEpoch.toDouble() : 0,
      maxX: _heartRateData.isNotEmpty ? _heartRateData.last.timestamp.millisecondsSinceEpoch.toDouble() : 0,
      minY: 0,
      maxY: (_heartRateData.isNotEmpty ? _heartRateData.map((data) => data.heartRate).reduce((a, b) => a > b ? a : b) : 100) + 10,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.blue.withOpacity(0.3), Colors.blueAccent.withOpacity(0.1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        backgroundColor: Colors.blueAccent,
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
              child: _heartRateData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : LineChart(_lineChartData()),
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





