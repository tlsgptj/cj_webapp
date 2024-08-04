import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class chartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<chartScreen> {
  final DatabaseReference _heartRateRef = FirebaseDatabase.instance.ref().child('heart_rate');
  String _currentHeartRate = 'Loading...';
  List<HeartRateData> _dailyData = [];
  List<HeartRateData> _weeklyData = [];

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
      _dailyData = dailyData;
      _weeklyData = weeklyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> dailySpots = _dailyData.map((data) => FlSpot(
      data.time.millisecondsSinceEpoch.toDouble(),
      data.heartRate.toDouble(),
    )).toList();

    List<FlSpot> weeklySpots = _weeklyData.map((data) => FlSpot(
      data.time.millisecondsSinceEpoch.toDouble(),
      data.heartRate.toDouble(),
    )).toList();

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
              child: LineChart(
                mainData(dailySpots),
              ),
            ),
            SizedBox(height: 20),
            Text('Weekly Heart Rate Statistics:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 200,
              child: LineChart(
                mainData(weeklySpots),
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

  LineChartData mainData(List<FlSpot> spots) {
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
              FlDotData(show: true),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot;
              return LineTooltipItem(
                '${DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt()).day}/${DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt()).month}\n',
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: '${flSpot.y.toInt()} bpm',
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
            y: 80, // 목표 수치
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
                child: Text('${date.day}/${date.month}'),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 10,
            getTitlesWidget: (value, meta) => Text(
              '$value bpm',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.white10),
      ),
      minX: spots.isEmpty ? 0 : spots.first.x,
      maxX: spots.isEmpty ? 1 : spots.last.x,
      minY: spots.isEmpty ? 0 : spots.reduce((a, b) => a.y < b.y ? a : b).y - 10,
      maxY: spots.isEmpty ? 100 : spots.reduce((a, b) => a.y > b.y ? a : b).y + 10,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          gradient: LinearGradient(
            colors: [Colors.blue.withOpacity(0.6), Colors.blue.withOpacity(0.3)],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.1)],
            ),
          ),
        ),
      ],
    );
  }
}

class HeartRateData {
  final DateTime time;
  final int heartRate;

  HeartRateData(this.time, this.heartRate);
}

