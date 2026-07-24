import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                sin(_controller.value * 2 * pi) * 0.5,
                cos(_controller.value * 2 * pi) * 0.5,
              ),
              radius: 0.8,
              colors: const [
                Color(0xFF1A1A3E),
                Color(0xFF0A0A1A),
                Color(0xFF0A0A1A),
              ],
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        );
      },
    );
  }
}