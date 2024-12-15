import 'package:flutter/material.dart';
import 'attendance_calendar_page.dart';
import 'profile_page.dart';
// Import SliderPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const Placeholder(), // Replace with your Timer page
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AttendanceCalendarPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today), // Icon for attendance
            onPressed: () {
              // Navigate to SliderPage when the icon is pressed
              Navigator.pushNamed(context, '/slider', arguments: 'username'); // Replace 'username' with actual username if needed
            },
          ),
        ],
      ),
      body: _selectedIndex == 1
          ? const AttendanceCalendarPage()
          : _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 100),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            children: [
              Container(color: Colors.pink[50], child: const Center(child: Text(''))),
              Container(color: Colors.pink[50], child: const Center(child: Text(''))),
              Container(color: Colors.pink[50], child: const Center(child: Text(''))),
              Container(color: Colors.pink[50], child: const Center(child: Text(''))),
            ],
          ),
        ],
      ),
    );
  }
}