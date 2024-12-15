import 'package:flutter/material.dart';

class AttendanceMarkedPage extends StatefulWidget {
  const AttendanceMarkedPage({super.key});

  @override
  State<AttendanceMarkedPage> createState() => _AttendanceMarkedPageState();
}

class _AttendanceMarkedPageState extends State<AttendanceMarkedPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _checkmarkScaleAnimation;
  late Animation<double> _messageOpacityAnimation;
  late Animation<double> _nextButtonSlideAnimation;

  static const primaryColor = Color(0xFF2ECC71);
  static const secondaryColor = Color(0xFFE8F5E9);
  static const backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/HomePage');
      }
    });
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _checkmarkScaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _messageOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
    );

    _nextButtonSlideAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    );
  }

  void _startAnimations() {
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Attendance Marked ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _checkmarkScaleAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeTransition(
          opacity: _messageOpacityAnimation,
          child: const Text(
            'Attendance Marked!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 40),
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_nextButtonSlideAnimation),
          child: _buildNextButton(),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/HomePage');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Next',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}