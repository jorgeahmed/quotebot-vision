import 'package:flutter/material.dart';
import 'dart:math' as math;

class TechLoading extends StatefulWidget {
  final String message;
  final Color baseColor;

  const TechLoading({
    super.key,
    this.message = 'ANALYZING...',
    this.baseColor = const Color(0xFF6366F1), // Indigo
  });

  @override
  State<TechLoading> createState() => _TechLoadingState();
}

class _TechLoadingState extends State<TechLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.baseColor.withOpacity(0.3),
                        width: 4,
                      ),
                      gradient: SweepGradient(
                        colors: [
                          Colors.transparent,
                          widget.baseColor,
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Inner pulsing dot
                // Note: Removed "AnimatedBuilder" here to simplify, using static size for now
                // or reusing controller for scale
                ScaleTransition(
                  scale: Tween(begin: 0.5, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: widget.baseColor.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.baseColor.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Terminal text effect
          Text(
            widget.message,
            style: TextStyle(
              color: widget.baseColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              fontFamily: 'Courier', // Monospace feeling
            ),
          ),
        ],
      ),
    );
  }
}
