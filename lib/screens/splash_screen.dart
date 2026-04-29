import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/classifier.dart';

class SplashScreen extends StatefulWidget {
  final TomatoClassifier classifier;
  const SplashScreen({super.key, required this.classifier});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Animation controllers ──────────────────────────────────────
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _leafCtrl;
  late AnimationController _textCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;

  // ── Animations ─────────────────────────────────────────────────
  late Animation<double> _bgFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _leafSlide;
  late Animation<double> _leafFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _pulse;
  late Animation<double> _progress;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;

  String _statusText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _leafCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400));

    _bgFade = CurvedAnimation(parent: _bgCtrl, curve: Curves.easeIn);

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade =
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);

    _leafSlide =
        Tween<Offset>(begin: const Offset(-1.6, 0), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _leafCtrl, curve: Curves.easeOutCubic));
    _leafFade =
        CurvedAnimation(parent: _leafCtrl, curve: Curves.easeIn);

    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _textCtrl, curve: Curves.easeOutCubic));
    _titleFade =
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);

    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: _textCtrl,
                curve: const Interval(0.3, 1.0,
                    curve: Curves.easeOutCubic)));
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _textCtrl,
            curve:
                const Interval(0.3, 1.0, curve: Curves.easeIn)));

    _pulse = Tween<double>(begin: 0.96, end: 1.06).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _progress =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _dot1 = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
            parent: _pulseCtrl,
            curve:
                const Interval(0.0, 0.4, curve: Curves.easeInOut)));
    _dot2 = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
            parent: _pulseCtrl,
            curve:
                const Interval(0.3, 0.7, curve: Curves.easeInOut)));
    _dot3 = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
            parent: _pulseCtrl,
            curve:
                const Interval(0.6, 1.0, curve: Curves.easeInOut)));
  }

  Future<void> _startSequence() async {
    // 1. Background fades in
    await Future.delayed(const Duration(milliseconds: 80));
    _bgCtrl.forward();

    // 2. Logo bounces in
    await Future.delayed(const Duration(milliseconds: 350));
    _logoCtrl.forward();

    // 3. Leaf row slides in from left
    await Future.delayed(const Duration(milliseconds: 650));
    _leafCtrl.forward();

    // 4. Title + subtitle slide up
    await Future.delayed(const Duration(milliseconds: 450));
    _textCtrl.forward();

    // 5. Progress bar starts + model loads
    await Future.delayed(const Duration(milliseconds: 350));
    _progressCtrl.forward();
    setState(() => _statusText = 'Loading AI model...');

    await widget.classifier.loadModel();

    setState(() => _statusText = 'Ready!');
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    // 6. Slide into HomeScreen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) =>
            HomeScreen(classifier: widget.classifier),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.07),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 550),
      ),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _leafCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _bgFade,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B5E20),
                Color(0xFF2E7D32),
                Color(0xFF388E3C),
                Color(0xFF1B5E20),
              ],
              stops: [0.0, 0.35, 0.65, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // ── Decorative background circles ─────────────────
              _buildBgCircles(),

              // ── Main content ──────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Logo
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _pulse,
                          child: Container(
                            width: 124,
                            height: 124,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.14),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.38),
                                  width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.22),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.eco_rounded,
                                size: 66, color: Colors.white),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Leaf icon row (slides from left)
                    SlideTransition(
                      position: _leafSlide,
                      child: FadeTransition(
                        opacity: _leafFade,
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final isMid = i == 2;
                            final isNearMid = i == 1 || i == 3;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4),
                              child: Icon(
                                Icons.eco,
                                size: isMid
                                    ? 26
                                    : isNearMid
                                        ? 20
                                        : 15,
                                color: Colors.white.withOpacity(
                                    isMid
                                        ? 1.0
                                        : isNearMid
                                            ? 0.7
                                            : 0.4),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // App title
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: const Text(
                          'Tomato Doctor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Subtitle pill
                    SlideTransition(
                      position: _subtitleSlide,
                      child: FadeTransition(
                        opacity: _subtitleFade,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    Colors.white.withOpacity(0.22)),
                          ),
                          child: const Text(
                            'AI-Powered Leaf Disease Detection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // Disease chips row
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Early Blight',
                            'Late Blight',
                            'Leaf Mold',
                            'Septoria Spot',
                            'Yellow Curl',
                            'Healthy',
                          ]
                              .map((label) => Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.white
                                              .withOpacity(0.24)),
                                    ),
                                    child: Text(label,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w500)),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Progress bar + status
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 44),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _progress,
                            builder: (_, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _progress.value,
                                minHeight: 5,
                                backgroundColor:
                                    Colors.white.withOpacity(0.2),
                                valueColor:
                                    const AlwaysStoppedAnimation<
                                        Color>(Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                _statusText,
                                style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (_, __) => Row(
                                  children: [
                                    _dot(_dot1.value),
                                    _dot(_dot2.value),
                                    _dot(_dot3.value),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // FYP badge
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: Text(
                        'Final Year Project  •  YOLOv8n',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.42),
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(double opacity) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );

  Widget _buildBgCircles() => Stack(children: [
        Positioned(
            top: -55,
            right: -55,
            child: _circle(210, 0.05)),
        Positioned(
            bottom: -75,
            left: -75,
            child: _circle(270, 0.05)),
        Positioned(
            top: 170,
            left: -38,
            child: _circle(125, 0.04)),
        Positioned(
            bottom: 190,
            right: -28,
            child: _circle(95, 0.04)),
      ]);

  Widget _circle(double size, double opacity) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}
