import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'dart:math';
import '../database_helper.dart';

void main() async {
  final router = Router();
  final dbHelper = DatabaseHelper(); // Initialize DatabaseHelper

  // Mock user data ```dart
  const String validUsername = "admin";
  const String validPassword = "12345";

  // Define the allowed region for attendance (latitude, longitude, radius in meters)
  const double allowedLatitude = 17.60282508915414; // Replace with actual latitude
  const double allowedLongitude = 78.48654105337307; // Replace with actual longitude
  const double allowedRadius = 2000.0; // Radius in meters
 
  // Add CORS headers to the response
  Response addCORSHeaders(Response response) {
    return response.change(headers: {
      'Access-Control-Allow-Origin': '*', // Allow all origins or specify your frontend URL
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    });
  }

  // Handle preflight requests
  router.options('/<path>', (Request request) async {
    return addCORSHeaders(Response.ok(''));
  });

  /// Login endpoint
  router.post('/login', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    final username = data['user'];
    final password = data['password'];

    if (username == validUsername && password == validPassword) {
      return addCORSHeaders(Response.ok(jsonEncode({'message': 'Login successful!'}), headers: {
        'Content-Type': 'application/json',
      }));
    } else {
      return addCORSHeaders(Response.forbidden(jsonEncode({'message': 'Invalid credentials'}), headers: {
        'Content-Type': 'application/json',
      }));
    }
  });

  // Check if user is in the allowed region
  router.post('/check-location', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    final double userLatitude = data['latitude'];
    final double userLongitude = data['longitude'];

    // Calculate the distance between the user and the allowed location
    final double distance = _calculateDistance(
      allowedLatitude,
      allowedLongitude,
      userLatitude,
      userLongitude,
    );

    return addCORSHeaders(Response.ok(jsonEncode({'inRegion': distance <= allowedRadius}), headers: {
      'Content-Type': 'application/json',
    }));
  });

  // Check-in endpoint
  router.post('/check-in', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    final String user = data['user']; // Assume user is passed in the request
    final DateTime checkInTime = DateTime.now();
    final String date = checkInTime.toIso8601String().split('T')[0]; // Get date in YYYY-MM-DD format

    // Insert attendance data into the database
    await dbHelper.insertAttendance({
      'user': user,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': null,
      'date': date,
    });

    return addCORSHeaders(Response.ok(jsonEncode({'message': 'Check-in successful!'}), headers: {
      'Content-Type': 'application/json',
    }));
  });

  // Check-out endpoint
  router.post('/check-out', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    final String user = data['user']; // Assume user is passed in the request
    final DateTime checkOutTime = DateTime.now();
    final String date = checkOutTime.toIso8601String().split('T')[0]; // Get date in YYYY-MM-DD format

    // Update attendance data in the database
    final List<Map<String, dynamic>> attendanceRecords = await dbHelper.getAttendance();
    final attendanceRecord = attendanceRecords.firstWhere(
      (record) => record['user'] == user && record['date'] == date,
      orElse: () => {},
    );

    if (attendanceRecord.isNotEmpty) {
      await dbHelper.updateAttendance(attendanceRecord['id'], {
        'checkOutTime': checkOutTime.toIso8601String(),
      });
      return addCORSHeaders(Response.ok(jsonEncode({'message': 'Check-out successful!'}), headers: {
        'Content-Type': 'application/json',
      }));
    } else {
      return addCORSHeaders(Response.forbidden(jsonEncode({'message': 'No check-in record found for today'}), headers: {
        'Content-Type': 'application/json',
      }));
    }
  });

  // Biometric authentication endpoint
  router.post('/authenticate', (Request request) async {
    final payload = await request.readAsString();
    final data = jsonDecode(payload);

    // Here you can add logic to verify biometric data
    return addCORSHeaders(Response.ok(jsonEncode({'message': 'Authentication successful!'}), headers: {
      'Content-Type': 'application/json',
    }));
  });

  // Start the server
  final server = await shelf_io.serve(router.call, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

// Function to calculate the distance between two geographical points
double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // Earth radius in meters
  final double dLat = _degreesToRadians(lat2 - lat1);
  final double dLon = _degreesToRadians(lon2 - lon1);

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // Distance in meters
}

// Helper function to convert degrees to radians
double _degreesToRadians(double degrees) {
  return degrees * (pi / 180);
}