import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/slider_page.dart';
import 'screens/thank_you_page.dart';
import 'screens/home_page.dart';
import 'screens/attendance_calendar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoMark Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Robotp',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/slider': (context) => const SliderPage(),
        '/thankyou': (context) => const ThankYouPage(),
        '/HomePage': (context) => const HomePage(),
        '/attendance': (context) => const AttendanceCalendarPage(),
      },
    );
  }
}