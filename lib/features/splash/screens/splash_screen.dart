import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../home/screens/home_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _glowPulseAnimation;
  late Animation<double> _ringScaleAnimation;
  late Animation<double> _ringOpacityAnimation;

  String _statusMessage = 'Initializing...';
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startLoading();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Logo scale: breathe effect
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Logo rotation: subtle spin
    _logoRotationAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Text fade in
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Text slide up
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Glow pulse
    _glowPulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Outer ring scale
    _ringScaleAnimation = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Outer ring opacity
    _ringOpacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _startLoading() async {
    try {
      await _updateProgress('Connecting to AI Brain...', 0.1);
      await Future.delayed(const Duration(milliseconds: 600));

      await _updateProgress('Loading your profile...', 0.25);
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress('Syncing study data...', 0.45);
      await Future.delayed(const Duration(milliseconds: 600));

      await _updateProgress('Preparing AI Assistant...', 0.7);
      await Future.delayed(const Duration(milliseconds: 500));

      await _updateProgress('Almost ready!', 0.9);
      await Future.delayed(const Duration(milliseconds: 400));

      await _updateProgress('Welcome!', 1.0);
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        _navigateToNextScreen();
      }
    }
  }

  Future<void> _updateProgress(String message, double progress) async {
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
      _progressValue = progress;
    });
  }

  void _navigateToNextScreen() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          Widget nextScreen;
          if (authProvider.isAuthenticated) {
            nextScreen = const HomeScreen();
          } else {
            final prefs = SharedPreferences.getInstance();
            prefs.then((sharedPrefs) {
              final isOnboardingComplete = sharedPrefs.getBool('onboarding_complete') ?? false;
              if (!mounted) return;
              if (isOnboardingComplete) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                );
              }
            });
            return const SizedBox.shrink();
          }
          return nextScreen;
        },
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0E17),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F3460),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated particles
              ..._buildParticles(),

              // Glow effects
              _buildGlowEffects(),

              // Main content
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with animations
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _logoRotationAnimation.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer pulsing ring
                                  Transform.scale(
                                    scale: _ringScaleAnimation.value,
                                    child: Opacity(
                                      opacity: _ringOpacityAnimation.value,
                                      child: Container(
                                        width: 200,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFF00D2FF).withValues(alpha: 0.3),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF00D2FF).withValues(alpha: 0.1),
                                              blurRadius: 40,
                                              spreadRadius: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Main logo container
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF00D2FF).withValues(alpha: 0.2),
                                          const Color(0xFF3A7BD5).withValues(alpha: 0.1),
                                          Colors.transparent,
                                        ],
                                        radius: 0.8,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF00D2FF).withValues(alpha: 0.2),
                                          blurRadius: 50,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFF00D2FF),
                                            const Color(0xFF3A7BD5),
                                            const Color(0xFF6C3CE1),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF00D2FF).withValues(alpha: 0.4),
                                            blurRadius: 30,
                                            spreadRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Transform.scale(
                                          scale: 1.0 + (_glowPulseAnimation.value - 0.5) * 0.1,
                                          child: Icon(
                                            Icons.auto_awesome_rounded,
                                            color: Colors.white,
                                            size: 60,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 50),

                      // App Name with animation
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: FadeTransition(
                          opacity: _textFadeAnimation,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    colors: const [
                                      Color(0xFF00D2FF),
                                      Color(0xFF6C3CE1),
                                      Color(0xFF00D2FF),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'AI Study Buddy',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 6,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your Intelligent Learning Companion',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 70),

                      // Loading progress
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 600),
                        child: Column(
                          children: [
                            // Progress bar
                            Container(
                              width: 250,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: _progressValue.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF00D2FF),
                                        const Color(0xFF6C3CE1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00D2FF).withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Status message
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _statusMessage,
                                key: ValueKey(_statusMessage),
                                style: GoogleFonts.inter(
                                  color: Colors.white60,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Loading dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(3, (index) {
                                return AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    final delay = index * 0.2;
                                    final progress = (_animationController.value + delay) % 1.0;
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF00D2FF).withValues(
                                          alpha: 0.2 + (progress * 0.8),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Footer
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 800),
                        child: Column(
                          children: [
                            Text(
                              'Powered by Advanced AI',
                              style: GoogleFonts.inter(
                                color: Colors.white30,
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.shade400,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.shade400.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'F&k Company (pvt) Limited',
                                  style: GoogleFonts.inter(
                                    color: Colors.green.shade400,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Particle effects
  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    final random = DateTime.now().millisecondsSinceEpoch % 1000;
    final size = MediaQuery.of(context).size;

    for (int i = 0; i < 20; i++) {
      final particleSize = 1.5 + (i % 4).toDouble();
      final x = ((i * 137 + random * (i + 1)) % size.width).toDouble();
      final y = ((i * 251 + random * (i + 2)) % size.height).toDouble();
      final opacity = 0.05 + (i % 6) * 0.03;

      particles.add(
        Positioned(
          left: x,
          top: y,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final floatOffset = (i % 8) * 0.15;
              final floatValue = (1 + sin(_animationController.value * 2 + floatOffset)) * 15;
              return Transform.translate(
                offset: Offset(0, floatValue),
                child: Container(
                  width: particleSize,
                  height: particleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00D2FF).withValues(alpha: opacity),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return particles;
  }

  // Background glow effects
  Widget _buildGlowEffects() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C3CE1).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                radius: 0.6,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -30,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF00D2FF).withValues(alpha: 0.06),
                  Colors.transparent,
                ],
                radius: 0.6,
              ),
            ),
          ),
        ),
        Positioned(
          top: 250,
          left: 30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3A7BD5).withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                radius: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}