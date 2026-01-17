import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stock_management/ui/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _navigateToLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Color
          Positioned.fill(child: Container(color: const Color(0xFFF8FAFC))),

          // Geo Pattern
          Positioned.fill(child: CustomPaint(painter: GeoPatternPainter())),

          // Top Right Blur
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0066FF).withValues(alpha: 0.08),
              ),
              child: const SizedBox.expand(),
            ),
          ),

          // Bottom Left Blur
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C2FF).withValues(alpha: 0.08),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Animated Logo Container
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0066FF), Color(0xFF00C2FF)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF0066FF,
                            ).withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Shine effect simulation (optional improvement)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: CustomPaint(
                                size: const Size(64, 64),
                                painter: LogoPainter(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                const Text(
                  'Wareef',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                    color: Color(0xFF0F172A),
                    fontFamily:
                        'SpaceGrotesk', // Fallback to sans-serif if not found
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                SizedBox(
                  width: 260,
                  child: Text(
                    'Smart inventory for modern business',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                ),

                const Spacer(flex: 4),

                // Loading Spinner
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0066FF),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Version
                const Text(
                  'V2.0.1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GeoPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0066FF).withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    const double spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw a tiny dot
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Outer eye shape (simplified path reflecting the SVG)
    final path = Path();
    path.moveTo(size.width * 0.04, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.15,
      size.width * 0.5,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.15,
      size.width * 0.96,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.85,
      size.width * 0.5,
      size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.85,
      size.width * 0.04,
      size.height * 0.5,
    );
    path.close();

    canvas.drawPath(path, paint..color = Colors.white.withValues(alpha: 0.2));

    // Inner circle
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, size.width * 0.22, innerPaint);

    // Pupil Rects
    // Left white rect
    final whiteRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.42,
        size.width * 0.06,
        size.height * 0.16,
      ),
      const Radius.circular(1),
    );
    canvas.drawRRect(whiteRect, Paint()..color = Colors.white);

    // Right orange/yellow rect
    final orangeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.52,
        size.height * 0.34,
        size.width * 0.06,
        size.height * 0.25,
      ),
      const Radius.circular(1),
    );
    canvas.drawRRect(orangeRect, Paint()..color = const Color(0xFFFFB020));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
