import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchUsers extends StatefulWidget {
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _currentPageItems = [];
  TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  int _perPage = 10; // Number of items per page
  int _currentPage = 0; // Current page index
  String _sortCategory = 'name'; // Default sort category
  bool _isAscending = true; // Default sort order

  double _minHeartRate = 0;
  double _maxHeartRate = 200;
  double _minSteps = 0;
  double _maxSteps = 20000;
  double _minDistance = 0;
  double _maxDistance = 100;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_filterItems);
    _fetchData(); // Fetch all data initially
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('user_fitness_data')
          .orderBy(_sortCategory, descending: !_isAscending)
          .get();
      final items = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

      setState(() {
        _allItems = items;
        _filterItems(); // Apply filters and pagination
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterItems() {
    setState(() {
      _currentPageItems = _applyFilters(_allItems)
          .skip(_currentPage * _perPage)
          .take(_perPage)
          .toList();
    });
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final heartRate = item['heartRate']?.toDouble() ?? 0.0;
      final steps = item['steps']?.toDouble() ?? 0.0;
      final distance = item['distance']?.toDouble() ?? 0.0;

      return heartRate >= _minHeartRate &&
          heartRate <= _maxHeartRate &&
          steps >= _minSteps &&
          steps <= _maxSteps &&
          distance >= _minDistance &&
          distance <= _maxDistance;
    }).toList();
  }

  void _changeItemsPerPage(int newValue) {
    setState(() {
      _perPage = newValue;
      _currentPage = 0;
      _filterItems(); // Re-filter items based on new page size
    });
  }

  void _changePage(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
      _filterItems(); // Update current page items
    });
  }

  void _changeSortCategory(String category) {
    setState(() {
      _sortCategory = category;
      _isAscending = !_isAscending; // Toggle sort order
      _fetchData(); // Re-fetch data with new sort order
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('필터 설정'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('심박수 범위'),
                    RangeSlider(
                      values: RangeValues(_minHeartRate, _maxHeartRate),
                      min: 0,
                      max: 200,
                      divisions: 20,
                      labels: RangeLabels(
                        _minHeartRate.toString(),
                        _maxHeartRate.toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _minHeartRate = values.start;
                          _maxHeartRate = values.end;
                        });
                      },
                    ),
                    Text('걸음수 범위'),
                    RangeSlider(
                      values: RangeValues(_minSteps, _maxSteps),
                      min: 0,
                      max: 20000,
                      divisions: 20,
                      labels: RangeLabels(
                        _minSteps.toString(),
                        _maxSteps.toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _minSteps = values.start;
                          _maxSteps = values.end;
                        });
                      },
                    ),
                    Text('이동거리 범위'),
                    RangeSlider(
                      values: RangeValues(_minDistance, _maxDistance),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      labels: RangeLabels(
                        _minDistance.toString(),
                        _maxDistance.toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _minDistance = values.start;
                          _maxDistance = values.end;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _filterItems(); // Re-filter items based on updated filters
                    Navigator.of(context).pop();
                  },
                  child: Text('적용'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildPageIndicators() {
    int totalPages = (_applyFilters(_allItems).length / _perPage).ceil();
    List<Widget> indicators = [];

    for (int i = 0; i < totalPages; i++) {
      indicators.add(_buildPageButton("${i + 1}", i));
    }

    return indicators;
  }

  Widget _buildPageButton(String label, int pageIndex) {
    return TextButton(
      onPressed: () {
        _changePage(pageIndex);
      },
      child: Text(
        label,
        style: TextStyle(
          color: pageIndex == _currentPage ? Colors.blue : Colors.black,
          fontWeight: pageIndex == _currentPage ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildItemView(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(Icons.person, size: 40),
        title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${item['name']}'),
            Text('Heart Rate: ${item['heartRate']} bpm'),
            Text('Steps: ${item['steps']}'),
            Text('Distance: ${item['distance']} km'),
          ],
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item['name']} 선택됨')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('STAFF LIST'),
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
                'CJ Health',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(title: Text('Home'), onTap: () => Navigator.pushNamed(context, '/home')),
            ListTile(title: Text('Login'), onTap: () => Navigator.pushNamed(context, '/login')),
            ListTile(title: Text('차트보기'), onTap: () => Navigator.pushNamed(context, '/chart')),
            ListTile(title: Text('119신고'), onTap: () => Navigator.pushNamed(context, '/DetailScreen')),
            ListTile(title: Text('마이페이지'), onTap: () => Navigator.pushNamed(context, '/mypage')),
            ListTile(title: Text('LogOut'), onTap: () => Navigator.pushNamed(context, '/login')),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: '검색',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _showFilterDialog();
                  },
                  child: Text('필터 설정'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    value: _perPage,
                    items: [10, 20, 50].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value개씩 보기'),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        _changeItemsPerPage(newValue);
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isAscending = !_isAscending; // Toggle sort order
                      _fetchData(); // Re-fetch data with new sort order
                    });
                  },
                  child: Text(_isAscending ? '내림차순 정렬' : '오름차순 정렬'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _currentPageItems.isEmpty
                  ? Center(child: Text('사용자를 찾을 수 없음'))
                  : ListView.builder(
                itemCount: _currentPageItems.length,
                itemBuilder: (context, index) {
                  final item = _currentPageItems[index];
                  return _buildItemView(item);
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicators(),
            ),
          ],
        ),
      ),
    );
  }
}


