import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'login_screen.dart';

class BubbleSplashScreen extends StatefulWidget {
  const BubbleSplashScreen({super.key});

  @override
  State<BubbleSplashScreen> createState() => _BubbleSplashScreenState();
}

class _BubbleSplashScreenState extends State<BubbleSplashScreen>
    with TickerProviderStateMixin {
  final List<Bubble> _bubbles = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    for (int i = 0; i < 25; i++) {
      _bubbles.add(Bubble(
        x: Random().nextDouble(),
        size: 10 + Random().nextDouble() * 20,
        speed: 0.5 + Random().nextDouble() * 2,
      ));
    }

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background + animated bubbles
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFADD8E6),
                  Color(0xFF00008B),
                ],
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: BubblePainter(_bubbles, _controller.value),
                  child: Container(), // empty child so painter has size
                );
              },
            ),
          ),

          // Foreground UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 1000),
                  child: const Icon(
                    Icons.anchor,
                    size: 90,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: const Text(
                    "Fishers App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInUp(
                  duration: const Duration(milliseconds: 1300),
                  child: const Text(
                    "Connecting Fisher Communities",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  duration: const Duration(milliseconds: 1500),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Bubble model
class Bubble {
  double x;
  double size;
  double speed;

  Bubble({required this.x, required this.size, required this.speed});
}

// Bubble painter
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final double progress;

  BubblePainter(this.bubbles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.3);

    for (var bubble in bubbles) {
      double y = size.height -
          (progress * bubble.speed * size.height) % size.height;
      double x = bubble.x * size.width;

      canvas.drawCircle(Offset(x, y), bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BubblePainter oldDelegate) => true;
}
