import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({super.key});

  @override
  State<AttendanceCalendarPage> createState() => _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _displayedMonth = DateTime.now();
  Set<DateTime> _presentDays = {};

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.100:8080/attendance?year=${_displayedMonth.year}&month=${_displayedMonth.month}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _presentDays = Set<DateTime>.from(
          (data['presentDays'] as List).map((date) => DateTime.parse(date)),
        );
      });
    } else {
      // Handle error
      _showErrorDialog('Failed to load attendance data: ${response.body}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true; // Allow the pop
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Attendance Timeline',
            style: TextStyle(color: Colors.black87),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            _buildMonthNavigator(),
            _buildCalendar(),
            _buildAttendanceSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month - 1,
                );
                _fetchAttendanceData(); // Fetch new data
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_displayedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _displayedMonth = DateTime(
                  _displayedMonth.year,
                  _displayedMonth.month + 1,
                );
                _fetchAttendanceData(); // Fetch new data
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildWeekDayHeaders(),
            const SizedBox(height: 8),
            Expanded(child: _buildCalendarGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDayHeaders() {
  final weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: weekDays
        .map((day) => Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ))
        .toList(), // Ensure this is correctly placed
  );
}

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday;

    final calendarDays = List<DateTime?>.filled(42, null);

    for (var i = 0; i < daysInMonth; i++) {
      calendarDays[i + firstWeekdayOfMonth - 1] = DateTime(
        _displayedMonth.year,
        _displayedMonth.month,
        i + 1,
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: 42,
      itemBuilder: (context, index) {
        final date = calendarDays[index];
        if (date == null) {
          return const SizedBox.shrink();
        }

        final isPresent = _presentDays.contains(date);
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isPresent ? Colors.green[200] : Colors.transparent,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                date.day.toString(),
                style: TextStyle(
                  color: isPresent ? Colors.white : Colors.black,
                  fontWeight: _selectedDate == date
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceSummary() {
    final presentCount = _presentDays.length;
    final totalDays = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Present', presentCount, Colors.green),
          _buildSummaryItem('Total', totalDays, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}