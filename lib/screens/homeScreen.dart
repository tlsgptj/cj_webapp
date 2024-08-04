import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 추가

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseReference _databaseReference;
  Map<String, dynamic> _data = {};
  List<FlSpot> _heartRateSpots = [];
  List<FlSpot> _stressLevelSpots = [];

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.ref('users');

    _databaseReference.onValue.listen((event) {
      final value = event.snapshot.value as Map<dynamic, dynamic>?;
      setState(() {
        if (value != null) {
          _data = value.cast<String, dynamic>();
          _updateHeartRateAndStressData();
        } else {
          _data = {};
        }
      });
    });
  }

  void _updateHeartRateAndStressData() {
    if (_data.isNotEmpty) {
      double heartRate = double.tryParse(_data['heart_rate_data'].toString()) ?? 0.0;
      double stressLevel = double.tryParse(_data['stressLevel'].toString()) ?? 0.0;
      DateTime now = DateTime.now();
      double xValue = now.millisecondsSinceEpoch.toDouble(); // 현재 시간을 밀리초 단위로 변환

      if (_heartRateSpots.length >= 60) {
        _heartRateSpots.removeAt(0); // 가장 오래된 데이터 제거
      }
      if (_stressLevelSpots.length >= 60) {
        _stressLevelSpots.removeAt(0); // 가장 오래된 데이터 제거
      }
      _heartRateSpots.add(FlSpot(xValue, heartRate));
      _stressLevelSpots.add(FlSpot(xValue, stressLevel));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.lightBlue,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildHeartRateGraph(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 20),
                      ),
                      onPressed: _showReportDialog,
                      child: Text('신고'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 20),
                      ),
                      onPressed: _showHelpDialog,
                      child: Text('도움'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartRateGraph() {
    double minX = _heartRateSpots.isEmpty ? 0 : _heartRateSpots.first.x;
    double maxX = _heartRateSpots.isEmpty ? DateTime.now().millisecondsSinceEpoch.toDouble() : _heartRateSpots.last.x;
    double minY = _heartRateSpots.isEmpty && _stressLevelSpots.isEmpty
        ? 0
        : [
      ..._heartRateSpots.map((e) => e.y),
      ..._stressLevelSpots.map((e) => e.y),
    ].reduce((a, b) => a < b ? a : b);
    double maxY = _heartRateSpots.isEmpty && _stressLevelSpots.isEmpty
        ? 100
        : [
      ..._heartRateSpots.map((e) => e.y),
      ..._stressLevelSpots.map((e) => e.y),
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      height: 500,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  DateTime date = DateTime.fromMillisecondsSinceEpoch(flSpot.x.toInt());
                  return LineTooltipItem(
                    '${DateFormat('HH:mm:ss').format(date)}\n${flSpot.y.toStringAsFixed(1)}',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                  FlDotData(show: true),
                );
              }).toList();
            },
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 100,
                color: Color(0xFFEAECFF),
                strokeWidth: 2,
                dashArray: [10, 5],
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
                color: Colors.grey,
                strokeWidth: 0.5,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey,
                strokeWidth: 0.5,
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
                    child: Text(
                      DateFormat('HH:mm:ss').format(date),
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toString(),
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _heartRateSpots,
              isCurved: true,
              color: Colors.red,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.3))
            ),
            LineChartBarData(
              spots: _stressLevelSpots,
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3))
            ),
          ],
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('도움요청'),
          content: Text('관리자에게 알림을 보냅니다.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('119에 신고가 접수되었습니다.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}






