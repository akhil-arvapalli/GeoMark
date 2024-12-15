// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart'; // Import Geolocator for location services
// import 'biometrics_page.dart';

// class SliderPage extends StatefulWidget {
//   const SliderPage({super.key});

//   @override
//   State<SliderPage> createState() => _SliderPageState();
// }

// class _SliderPageState extends State<SliderPage> with SingleTickerProviderStateMixin {
//   double _sliderPosition = 0.5;
//   bool _isSliding = false;
//   String _dragDirection = '';
//   late AnimationController _bounceController;
//   final double _threshold = 0.2;

//   @override
//   void initState() {
//     super.initState();
//     _bounceController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 200),
//     );
//   }

//   @override
//   void dispose() {
//     _bounceController.dispose();
//     super.dispose();
//   }

//   void _handleDragUpdate(DragUpdateDetails details) {
//     setState(() {
//       double newPosition = _sliderPosition + (details.delta.dy / (200 - 60));
//       _sliderPosition = newPosition.clamp(0.0, 1.0);

//       if (details.delta.dy < 0) {
//         _dragDirection = 'up';
//       } else if (details.delta.dy > 0) {
//         _dragDirection = 'down';
//       }

//       // Check if the slider position is within the threshold for actions
//       if (_sliderPosition <= _threshold) {
//         _checkLocationAndAction(true); // Check-in
//       } else if (_sliderPosition >= (1 - _threshold)) {
//         _checkLocationAndAction(false); // Check-out
//       }
//     });
//   }

//   Future<void> _checkLocationAndAction(bool isCheckIn) async {
//     // Get the user's current location
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

//     // Check if the user is in the allowed region
//     final response = await http.post(
//       Uri.parse('http://localhost:8080/check-location'), // Change to your server URL
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'latitude': position.latitude, 'longitude': position.longitude}),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['inRegion']) {
//         // Proceed with check-in or check-out
//         if (isCheckIn) {
//           _handleCheckIn();
//         } else {
//           _handleCheckOut();
//         }
//       } else {
//         _showErrorDialog('You are not in the allowed attendance region.');
//       }
//     } else {
//       _showErrorDialog('Location check failed.');
//     }
//   }

//   Future<void> _handleCheckIn() async {
//     // Send check-in request to the backend
//     final response = await http.post(
//       Uri.parse('http://localhost:8080/check-in'), // Change to your server URL
//     );

//     if (response.statusCode == 200) {
//       // Handle successful check-in response
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const BiometricsPage(isCheckIn: true),
//         ),
//       );
//     } else {
//       // Handle error response
//       _showErrorDialog('Check-in failed: ${response.body}');
//     }

//     _resetSlider();
//   }

//   Future<void> _handleCheckOut() async {
//     // Send check-out request to the backend
//     final response = await http.post(
//       Uri.parse('http://localhost:8080/check-out'), // Change to your server URL
//     );

//     if (response.statusCode == 200) {
//       // Handle successful check-out response
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const BiometricsPage(isCheckIn: false),
//         ),
//       );
//     } else {
//       // Handle error response
//       _showErrorDialog('Check-out failed: ${response.body}');
//     }

//     _resetSlider();
//   }

//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _resetSlider() {
//     setState(() {
//       _sliderPosition = 0.5;
//       _dragDirection = '';
//       _isSliding = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Scaffold(
//         body: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Colors.green.withOpacity(0.3),
//                 Colors.white,
//                 Colors.red.withOpacity(0.3),
//               ],
//               stops: const [0.0, 0.5, 1.0],
//             ),
//           ),
//           child: SafeArea(
//             child: Stack(
//               children: [
//                 Positioned(
//                   top: 10,
//                   right: 10,
//                   child: Icon(
//                     Icons.check_circle_outline,
//                     color: Colors.green[700],
//                     size: 30,
//                   ),
//                 ),
//                 Center(
//                   child: Container(
//                     width: 70,
//                     height: 200,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(35),
//                     ),
//                     child: Stack(
//                       children: [
//                         Positioned(
//                           top: 10,
//                           left: 0,
//                           right: 0,
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: _dragDirection == 'up'
//                                   ? Colors.green[700]
//                                   : Colors.green,
//                             ),
//                             child: Icon(
//                               Icons.login,
//                               color: Colors.white,
//                               size: _dragDirection == 'up' ? 28 : 24,
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           bottom: 10,
//                           left: 0,
//                           right: 0,
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             width: 40,
//                             height: 40,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: _dragDirection == 'down'
//                                   ? Colors.red[700]
//                                   : Colors.red,
//                             ),
//                             child: Icon(
//                               Icons.logout,
//                               color: Colors.white,
//                               size: _dragDirection == 'down' ? 28 : 24,
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           top: (_sliderPosition * (200 - 60)),
//                           left: 5,
//                           child: GestureDetector(
//                             onVerticalDragStart: (_) {
//                               setState(() => _isSliding = true);
//                               _bounceController.forward(from: 0.0);
//                             },
//                             onVerticalDragUpdate: _handleDragUpdate,
//                             onVerticalDragEnd: (_) => _resetSlider(),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               width: 60,
//                               height: 60,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.purple[300],
//                                 border: Border.all(
//                                   color: Colors.brown[300]!,
//                                   width: _isSliding ? 4 : 3,
//                                 ),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black
//                                         .withOpacity(_isSliding ? 0.3 : 0.2),
//                                     blurRadius: _isSliding ? 6 : 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Import Geolocator for location services
import 'biometrics_page.dart';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  State<SliderPage> createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> with SingleTickerProviderStateMixin {
  double _sliderPosition = 0.5;
  bool _isSliding = false;
  String _dragDirection = '';
  late AnimationController _bounceController;
  final double _threshold = 0.2;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      double newPosition = _sliderPosition + (details.delta.dy / (200 - 60));
      _sliderPosition = newPosition.clamp(0.0, 1.0);

      if (details.delta.dy < 0) {
        _dragDirection = 'up';
      } else if (details.delta.dy > 0) {
        _dragDirection = 'down';
      }

      // Check if the slider position is within the threshold for actions
      if (_sliderPosition <= _threshold) {
        _checkLocationAndAction(true); // Check-in
      } else if (_sliderPosition >= (1 - _threshold)) {
        _checkLocationAndAction(false); // Check-out
      }
    });
  }

  Future<void> _checkLocationAndAction(bool isCheckIn) async {
    // Get the user's current location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Check if the user is in the allowed region
    final response = await http.post(
      Uri.parse('http://localhost:8080/check-location'), // Change to your server URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitude': position.latitude, 'longitude': position.longitude}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['inRegion']) {
        // Proceed with check-in or check-out
        if (isCheckIn) {
          _handleCheckIn();
        } else {
          _handleCheckOut();
        }
      } else {
        _showErrorDialog('You are not in the allowed attendance region.');
      }
    } else {
      _showErrorDialog('Location check failed.');
    }
  }

  Future<void> _handleCheckIn() async {
    // Send check-in request to the backend
    final response = await http.post(
      Uri.parse('http://localhost:8080/check-in'), // Change to your server URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user': 'admin'}), // Include user data
    );

    if (response.statusCode == 200) {
      // Handle successful check-in response
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BiometricsPage(isCheckIn: true),
        ),
      );
    } else {
      // Handle error response
      _showErrorDialog('Check-in failed: ${response.body}');
    }

    _resetSlider();
  }

  Future<void> _handleCheckOut() async {
    // Send check-out request to the backend
    final response = await http.post(
      Uri.parse('http://localhost:8080/check-out'), // Change to your server URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user': 'admin'}), // Include user data
    );

    if (response.statusCode == 200) {
      // Handle successful check-out response
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BiometricsPage(isCheckIn: false),
        ),
      );
    } else {
      // Handle error response
      _showErrorDialog('Check-out failed: ${response.body}');
    }

    _resetSlider();
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

  void _resetSlider() {
    setState(() {
      _sliderPosition = 0.5;
      _dragDirection = '';
      _isSliding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.withOpacity(0.3),
                Colors.white,
                Colors.red.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[700],
                    size: 30,
                  ),
                ),
                Center(
                  child: Container(
                    width: 70,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _dragDirection == 'up'
                                  ? Colors.green[700]
                                  : Colors.green,
                            ),
                            child: Icon(
                              Icons.login,
                              color: Colors.white,
                              size: _dragDirection == 'up' ? 28 : 24,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _dragDirection == 'down'
                                  ? Colors.red[700]
                                  : Colors.red,
                            ),
                            child: Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: _dragDirection == 'down' ? 28 : 24,
                            ),
                          ),
                        ),
                        Positioned(
                          top: (_sliderPosition * (200 - 60)),
                          left: 5,
                          child: GestureDetector(
                            onVerticalDragStart: (_) {
                              setState(() => _isSliding = true);
                              _bounceController.forward(from: 0.0);
                            },
                            onVerticalDragUpdate: _handleDragUpdate,
                            onVerticalDragEnd: (_) => _resetSlider(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple[300],
                                border: Border.all(
                                  color: Colors.brown[300]!,
                                  width: _isSliding ? 4 : 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(_isSliding ? 0.3 : 0.2),
                                    blurRadius: _isSliding ? 6 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 