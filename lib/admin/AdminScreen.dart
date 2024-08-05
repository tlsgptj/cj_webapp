import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

import '../users/HeartRateData.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<HeartRateData> _averageHeartRateData = [];
  List<String> _alertWorkers = [];
  List<String> _currentWorkers = [];
  List<String> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkerData();
    _fetchReports();
  }

  Future<void> _fetchWorkerData() async {
    try {
      // Fetch alert workers
      final alertSnapshot = await _databaseRef.child('alert_workers').get();
      if (alertSnapshot.exists) {
        final alertData = alertSnapshot.value as Map?;
        if (alertData != null) {
          setState(() {
            _alertWorkers = alertData.values.map((e) => e.toString()).toList();
          });
        }
      } else {
        // Handle case where snapshot doesn't exist
        print('No data for alert workers');
      }

      // Fetch current workers
      final workersSnapshot = await _databaseRef.child('current_workers').get();
      if (workersSnapshot.exists) {
        final workersData = workersSnapshot.value as Map?;
        if (workersData != null) {
          setState(() {
            _currentWorkers = workersData.values.map((e) => e.toString()).toList();
          });
        }
      } else {
        // Handle case where snapshot doesn't exist
        print('No data for current workers');
      }

      // Fetch average heart rate data for chart
      final heartRateSnapshot = await _databaseRef.child('average_heart_rate_data').get();
      if (heartRateSnapshot.exists) {
        final heartRateData = heartRateSnapshot.value as Map?;
        if (heartRateData != null) {
          final List<HeartRateData> heartRateList = heartRateData.entries.map((e) {
            final timestamp = DateTime.parse(e.key);
            final heartRate = (e.value as Map)['value'] as double;
            return HeartRateData(timestamp, heartRate);
          }).toList();

          setState(() {
            _averageHeartRateData = heartRateList;
          });
        }
      } else {
        // Handle case where snapshot doesn't exist
        print('No data for average heart rate');
      }
    } catch (e) {
      print('Error fetching worker data: $e');
    }
  }

  Future<void> _fetchReports() async {
    try {
      // Fetch reports
      final reportsSnapshot = await _databaseRef.child('reports').get();
      if (reportsSnapshot.exists) {
        final reportsData = reportsSnapshot.value as Map?;
        if (reportsData != null) {
          setState(() {
            _reports = reportsData.values.map((e) => e.toString()).toList();
          });
        }
      } else {
        // Handle case where snapshot doesn't exist
        print('No data for reports');
      }
    } catch (e) {
      print('Error fetching reports: $e');
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

  LineChartData mainData() {
    // Prepare chart data
    List<FlSpot> spots = _averageHeartRateData.map((data) => FlSpot(
      data.timestamp.millisecondsSinceEpoch.toDouble(),
      data.heartRate,
    )).toList();

    return LineChartData(
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            final spot = barData.spots[spotIndex];
            return TouchedSpotIndicatorData(
              FlLine(
                color: Colors.white24,
                strokeWidth: 4,
              ),
              FlDotData(
                show: true,
              ),
            );
          }).toList();
        },
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
            y: 80, // Adjust based on your data
            color: Colors.redAccent,
            strokeWidth: 2,
            dashArray: [8, 4],
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
            color: Colors.blueGrey.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.blueGrey.withOpacity(0.1),
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
            reservedSize: 40,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text('${date.day}/${date.month}', style: TextStyle(fontSize: 12)),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text('$value bpm', style: TextStyle(fontSize: 12)),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.blueGrey),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 100, // Adjust based on your data
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
            show: true,
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
        title: Text('관리자 화면'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Alert Workers Section
            Text(
              '주의 집중 근무자 명단',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ..._alertWorkers.map((worker) => Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.all(8),
                title: Text(worker, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('심장 박동수가 불규칙합니다.'),
                tileColor: Colors.orangeAccent.withOpacity(0.1),
                leading: Icon(Icons.warning, color: Colors.orange),
              ),
            )).toList(),

            SizedBox(height: 20),

            // Average Heart Rate Section
            Text(
              '근무자 평균 심박수',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: _averageHeartRateData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : LineChart(mainData()),
            ),

            SizedBox(height: 20),

            // Current Workers Section
            Text(
              '현재 일하고 있는 근무자 리스트',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ..._currentWorkers.map((worker) => Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.all(8),
                title: Text(worker, style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () => _sendMessage(worker),
                ),
              ),
            )).toList(),

            SizedBox(height: 20),

            // Reports Section
            Text(
              '신고내역',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ...(_reports.isNotEmpty
                ? _reports.map((report) => Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.all(8),
                title: Text(report),
              ),
            )).toList()
                : [Card(
              margin: EdgeInsets.symmetric(vertical: 5),
              elevation: 4,
              child: ListTile(
                contentPadding: EdgeInsets.all(8),
                title: Text('신고가 없습니다.'),
              ),
            )]),
          ],
        ),
      ),
    );
  }
}






