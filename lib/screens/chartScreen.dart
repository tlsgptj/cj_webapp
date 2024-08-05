import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'HeartRateData.dart';

class chartScreen extends StatefulWidget {
  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<chartScreen> {
  final DatabaseReference _heartRateRef =
  FirebaseDatabase.instance.ref().child('heart_rate');
  String _currentHeartRate = 'Loading...';
  List<HeartRateData> _dailyData = [];
  List<HeartRateData> _weeklyData = [];
  final Connectivity _connectivity = Connectivity();
  final Random _random = Random();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Initialize with dummy data
    _initializeDummyData();

    // Check connectivity and fetch data
    _checkConnectivityAndFetchData();

    // Start periodic updates
    _startHeartRateUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

   // Reverse to have the most recent first
  void _initializeDummyData() {
    // Populate with initial dummy data
    final DateTime now = DateTime.now();
    final List<HeartRateData> initialDailyData = List.generate(
      24, // 24 hours in a day
          (index) => HeartRateData(
        now.subtract(Duration(hours: index)),
        100 + _random.nextDouble() * 40, // Random value between 100 and 140
      ),
    ).reversed.toList(); // Reverse to have the most recent first

    final List<HeartRateData> initialWeeklyData = List.generate(
      7, // 7 days in a week
          (index) => HeartRateData(
        now.subtract(Duration(days: index)),
        100 + _random.nextDouble() * 40, // Random value between 100 and 140
      ),
    ).reversed.toList(); // Reverse to have the most recent first

    setState(() {
      _dailyData = initialDailyData;
      _weeklyData = initialWeeklyData;
    });
  }


  Future<void> _checkConnectivityAndFetchData() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _currentHeartRate = 'No internet connection';
          _dailyData = [];
          _weeklyData = [];
        });
        return;
      }

      await Future.wait([
        _fetchHeartRateData(),
        _fetchHeartRateStatistics(),
      ]);
    } catch (e) {
      setState(() {
        _currentHeartRate = 'Error checking connectivity: $e';
        _dailyData = [];
        _weeklyData = [];
      });
    }
  }

  Future<void> _fetchHeartRateData() async {
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
        _currentHeartRate = 'User1';
      });
    }
  }

  Future<void> _fetchHeartRateStatistics() async {
    // This function can be used to fetch additional statistics if needed
    try {
      // Add any additional fetching logic here if necessary
    } catch (e) {
      setState(() {
        _dailyData = [];
        _weeklyData = [];
      });
    }
  }

  void _startHeartRateUpdates() {
    _timer = Timer.periodic(Duration(minutes: 10), (timer) {
      int newHeartRate = 60 + _random.nextInt(40); // Random heart rate between 60 and 100

      setState(() {
        _currentHeartRate = newHeartRate.toString();

        // Add to daily data and maintain a max of 24 data points (one per hour)
        _dailyData.add(HeartRateData(DateTime.now(), newHeartRate.toDouble()));
        if (_dailyData.length > 24) {
          _dailyData.removeAt(0);
        }

        // Add to weekly data and maintain a max of 7 data points (one per day)
        _weeklyData.add(HeartRateData(DateTime.now(), newHeartRate.toDouble()));
        if (_weeklyData.length > 7) {
          _weeklyData.removeAt(0);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<FlSpot> dailySpots = _dailyData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.heartRate))
        .toList();

    List<FlSpot> weeklySpots = _weeklyData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.heartRate))
        .toList();

    int currentHeartRate = int.tryParse(_currentHeartRate) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Chart'),
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
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/home');
              },
            ),
            ListTile(
              title: Text('119신고내역'),
              onTap: () {
                Navigator.pushNamed(context, '/call119');
              },
            ),
            ListTile(
              title: Text('My Page'),
              onTap: () {
                Navigator.pushNamed(context, '/mypage');
              },
            ),
            ListTile(
              title: Text('뽀모도로'),
              onTap: () {
                Navigator.pushNamed(context, '/time');
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Color(0xFFF7F8FA),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  '심장박동수 통계',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Noto Sans HK',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Current Heart Rate: $_currentHeartRate bpm',
                style: TextStyle(
                  fontSize: 20,
                  color: currentHeartRate > 150 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                currentHeartRate >= 150 ? '안정을 취하세요' : '심박수가 정상입니다',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '하루 동안의 심박수 그래프',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 700,
                height: 300,
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    _mainData(dailySpots),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '일주일 심박수 그래프',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 700,
                height: 300,
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    _mainData(weeklySpots),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '평균 심박수 : ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontFamily: 'Noto Sans HK',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: '150',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontFamily: 'Noto Sans HK',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'bpm (고심박수)\n',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontFamily: 'Noto Sans HK',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: '심박수가 다소 높습니다. 열사병에 걸릴 위험이 있으니, 잠시 휴식을 취하고 심호흡을 해보세요.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Noto Sans HK',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                '다음 주 근무 중 자주 휴식을 취하시길 바랍니다',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _mainData(List<FlSpot> spots) {
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
                'Day ${flSpot.x.toInt()} \n',
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
            y: 110, // First target line
            color: Colors.red,
            strokeWidth: 2,
            dashArray: [20, 10],
          ),
          HorizontalLine(
            y: 150, // Second target line
            color: Colors.orange,
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
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text('${value.toInt()}'),
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
              '$value',
              style: TextStyle(fontSize: 10),
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
      minY: 60,
      maxY: 200,
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
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.blue.withOpacity(0.1)
              ],
            ),
          ),
        ),
      ],
    );
  }
}







