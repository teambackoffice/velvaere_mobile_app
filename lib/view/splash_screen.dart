import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:velvaere_app/service/login_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final LoginService _loginService = LoginService();

  // Orbit ring
  late AnimationController _ringController;
  // Logo reveal
  late AnimationController _logoController;
  // Particle burst
  late AnimationController _particleController;
  // Text + tagline
  late AnimationController _textController;
  // Exit wipe
  late AnimationController _exitController;

  late Animation<double> _ringRotation;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late Animation<double> _particleProgress;

  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _tagOpacity;
  late Animation<Offset> _tagSlide;

  late Animation<double> _exitScale;
  late Animation<double> _exitOpacity;

  // final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    // _generateParticles();
    _setupAnimations();
    _startSequence();
  }

  // void _generateParticles() {
  //   final rng = math.Random(42);
  //   for (int i = 0; i < 24; i++) {
  //     _particles.add(
  //       _Particle(
  //         angle: (i / 24) * math.pi * 2 + rng.nextDouble() * 0.4,
  //         distance: 80 + rng.nextDouble() * 70,
  //         size: 2.0 + rng.nextDouble() * 3.5,
  //         speed: 0.6 + rng.nextDouble() * 0.6,
  //         hue: 120 + rng.nextDouble() * 40, // green spectrum
  //       ),
  //     );
  //   }
  // }

  void _setupAnimations() {
    // ── Ring ──────────────────────────────────────────────
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringRotation = Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );
    _ringScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));
    _ringOpacity = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_ringController);

    // ── Logo ──────────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // ── Particles ─────────────────────────────────────────
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _particleProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeOut),
    );

    // ── Text ──────────────────────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _tagOpacity = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _tagSlide = Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        );

    // ── Exit ──────────────────────────────────────────────
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _exitScale = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 150));

    // Ring sweeps in
    _ringController.forward();

    // Logo pops at ring peak
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    // Particles burst on logo land
    await Future.delayed(const Duration(milliseconds: 200));
    _particleController.forward();

    // Text slides up
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    // Hold splash visible for a couple of seconds, then navigate
    await Future.delayed(const Duration(milliseconds: 1200));
    _navigate();
  }

  Future<void> _navigate() async {
    final loggedIn = await _loginService.isLoggedIn();
    if (!mounted) return;

    await _exitController.forward();
    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060F09),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _ringController,
          _logoController,
          _particleController,
          _textController,
          _exitController,
        ]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.15),
                    radius: 1.2,
                    colors: [Color(0xFF0D2A18), Color(0xFF060F09)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Ambient scanlines texture
                    // CustomPaint(
                    //   painter: _ScanlinePainter(),
                    //   size: MediaQuery.of(context).size,
                    // ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ── Logo + Ring + Particles ──────────────
                          SizedBox(
                            width: 260,
                            height: 260,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Orbit ring
                                Transform.rotate(
                                  angle: _ringRotation.value,
                                  child: Transform.scale(
                                    scale: _ringScale.value,
                                    child: Opacity(
                                      opacity: _ringOpacity.value,
                                      child: CustomPaint(
                                        size: const Size(240, 240),
                                        painter: _OrbitRingPainter(
                                          progress: _ringController.value,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Particle burst
                                // if (_particleController.value > 0)
                                //   CustomPaint(
                                //     size: const Size(260, 260),
                                //     painter: _ParticlePainter(
                                //       particles: _particles,
                                //       progress: _particleProgress.value,
                                //     ),
                                //   ),

                                // Soft inner glow disc
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(0xFF4CAF50).withOpacity(
                                          0.18 * _logoOpacity.value,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),

                                // Logo
                                Transform.scale(
                                  scale: _logoScale.value,
                                  child: Opacity(
                                    opacity: _logoOpacity.value,
                                    child: Image.asset(
                                      'assets/logo.png',
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.eco_rounded,
                                        color: Color(0xFF66BB6A),
                                        size: 64,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Brand name ───────────────────────────
                          // SlideTransition(
                          //   position: _textSlide,
                          //   child: Opacity(
                          //     opacity: _textOpacity.value,
                          //     child: const Text(
                          //       'VELVAERE',
                          //       style: TextStyle(
                          //         fontFamily: 'Georgia',
                          //         fontSize: 30,
                          //         fontWeight: FontWeight.w300,
                          //         letterSpacing: 12,
                          //         color: Color(0xFFE8F5E9),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Orbit Ring ────────────────────────────────────────────────────────────────

class _OrbitRingPainter extends CustomPainter {
  final double progress;
  _OrbitRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer dashed arc
    final dashPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFF4CAF50).withOpacity(0.35);

    _drawDashedCircle(canvas, center, radius, dashPaint, 48);

    // Inner thinner ring
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0xFF81C784).withOpacity(0.2);
    canvas.drawCircle(center, radius - 14, innerPaint);

    // Bright arc sweep (progress-driven)
    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF69F0AE).withOpacity(0.8),
          const Color(0xFF00E676),
        ],
        stops: const [0.0, 0.7, 1.0],
        startAngle: 0,
        endAngle: math.pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = math.pi * 2 * math.min(progress * 1.5, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      sweepPaint,
    );

    // Leading dot on the arc
    if (sweepAngle > 0) {
      final dotAngle = -math.pi / 2 + sweepAngle;
      final dotPos = Offset(
        center.dx + radius * math.cos(dotAngle),
        center.dy + radius * math.sin(dotAngle),
      );
      canvas.drawCircle(dotPos, 4, Paint()..color = const Color(0xFF00E676));
      // Glow around dot
      canvas.drawCircle(
        dotPos,
        8,
        Paint()
          ..color = const Color(0xFF00E676).withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // 4 orbital accent dots evenly spaced
    for (int i = 0; i < 4; i++) {
      final a = (i / 4) * math.pi * 2 - math.pi / 2 + progress * math.pi;
      final r = radius - 14;
      canvas.drawCircle(
        Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a)),
        2,
        Paint()..color = const Color(0xFF4CAF50).withOpacity(0.5),
      );
    }
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
    int count,
  ) {
    for (int i = 0; i < count; i++) {
      final start = (i / count) * math.pi * 2;
      final end = start + (math.pi * 2 / count) * 0.55;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        end - start,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitRingPainter old) => old.progress != progress;
}

// // ─── Particles ─────────────────────────────────────────────────────────────────

// class _Particle {
//   final double angle;
//   final double distance;
//   final double size;
//   final double speed;
//   final double hue;
//   _Particle({
//     required this.angle,
//     required this.distance,
//     required this.size,
//     required this.speed,
//     required this.hue,
//   });
// }

// class _ParticlePainter extends CustomPainter {
//   final List<_Particle> particles;
//   final double progress;

//   _ParticlePainter({required this.particles, required this.progress});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);

//     for (final p in particles) {
//       final t = (progress * p.speed).clamp(0.0, 1.0);
//       final opacity = (1.0 - t * t).clamp(0.0, 1.0);
//       if (opacity <= 0) continue;

//       final dist = p.distance * t;
//       final x = center.dx + dist * math.cos(p.angle);
//       final y = center.dy + dist * math.sin(p.angle);

//       canvas.drawCircle(
//         Offset(x, y),
//         p.size * (1 - t * 0.5),
//         Paint()
//           ..color = HSVColor.fromAHSV(opacity * 0.9, p.hue, 0.6, 0.9).toColor(),
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
// }

// // ─── Scanlines ─────────────────────────────────────────────────────────────────

// class _ScanlinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.018)
//       ..strokeWidth = 1;

//     for (double y = 0; y < size.height; y += 4) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(_) => false;
// }
