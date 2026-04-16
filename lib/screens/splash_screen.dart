// screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plant_disease_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    // After 3s, check auth and navigate
    Timer(const Duration(seconds: 3), _navigate);
  }

  Future<void> _navigate() async {
    final loggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const SizedBox(), // replaced by route
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    // Navigate based on auth state
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        loggedIn ? '/home' : '/login',
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D09),
      body: Stack(
        children: [
          // Grid background
          CustomPaint(size: Size.infinite, painter: _SplashGridPainter()),

          // Subtle rings
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _ring(280),
                _ring(200),
                _ring(140),
              ],
            ),
          ),

          // Main content
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hex logo frame
                    _buildHexLogo(),

                    const SizedBox(height: 28),

                    // Shimmer title
                    _buildShimmerTitle(),

                    const SizedBox(height: 8),

                    const Text(
                      'SMART PLANT DISEASE DETECTION',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2A4D38),
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // CNN model tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00DC64).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF00DC64).withOpacity(0.2)),
                      ),
                      child: const Text(
                        'CNN MODEL v2.1  •  TENSORFLOW',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF00DC64),
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Loading dots
                    _buildDots(),
                  ],
                ),
              ),
            ),
          ),

          // Version at bottom
          Positioned(
            bottom: 28,
            left: 0, right: 0,
            child: Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 10,
                  color: const Color(0xFF00DC64).withOpacity(0.2),
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ring(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00DC64).withOpacity(0.05),
        ),
      ),
    );
  }

  Widget _buildHexLogo() {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(90, 90),
            painter: _HexPainter(),
          ),
          Image.asset('assets/app_logo.png', height: 40),
        ],
      ),
    );
  }

  Widget _buildShimmerTitle() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -0.3, end: 1.3),
      duration: const Duration(seconds: 2),
      builder: (context, value, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFF4D7A5E),
                Color(0xFFE8FFF2),
                Color(0xFF00DC64),
                Color(0xFFE8FFF2),
                Color(0xFF4D7A5E),
              ],
              stops: [
                (value - 0.4).clamp(0, 1),
                (value - 0.2).clamp(0, 1),
                value.clamp(0, 1),
                (value + 0.2).clamp(0, 1),
                (value + 0.4).clamp(0, 1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: const Text(
            'AGROVISION',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.3, end: 1.0),
          duration: Duration(milliseconds: 600 + i * 200),
          builder: (_, val, __) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF00DC64).withOpacity(val),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────
class _HexPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final outerPaint = Paint()
      ..color = const Color(0xFF00DC64).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFF00DC64).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = _hexPath(cx, cy, r - 4);
    canvas.drawPath(path, outerPaint);
    canvas.drawPath(path, strokePaint);

    final innerPaint = Paint()
      ..color = const Color(0xFF00DC64).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(_hexPath(cx, cy, r - 14), innerPaint);
  }

  Path _hexPath(double cx, double cy, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * 3.14159 / 180;
      final x = cx + r * _cos(angle);
      final y = cy + r * _sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  double _cos(double r) => r < 3.14 / 2
      ? 1 - r * r / 2
      : -(1 - (r - 3.14159) * (r - 3.14159) / 2);
  double _sin(double r) {
    final x = r % (2 * 3.14159);
    return x < 3.14159 ? x - x * x * x / 6 : -(x - 3.14159 - (x - 3.14159) * (x - 3.14159) * (x - 3.14159) / 6);
  }

  @override
  bool shouldRepaint(_HexPainter old) => false;
}

class _SplashGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00DC64).withOpacity(0.03)
      ..strokeWidth = 0.5;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_SplashGridPainter old) => false;
}