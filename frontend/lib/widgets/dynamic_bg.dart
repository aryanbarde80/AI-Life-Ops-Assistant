import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class DynamicBackground extends StatefulWidget {
  final Widget child;
  const DynamicBackground({super.key, required this.child});

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getMorphingColor(0),
                _getMorphingColor(0.5),
                _getMorphingColor(1),
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
          child: Stack(
            children: [
              _buildPulseRing(1.0),
              _buildPulseRing(1.5),
              widget.child,
            ],
          ),
        );
      },
    );
  }

  Color _getMorphingColor(double offset) {
    // Morphing based on time of day + animation cycle
    final hour = DateTime.now().hour;
    final t = (_controller.value + offset) % 1.0;
    
    if (hour >= 5 && hour < 11) { // Morning: Rose/Cyan
      return Color.lerp(AppTheme.accent.withOpacity(0.1), AppTheme.cyan.withOpacity(0.05), t)!;
    } else if (hour >= 11 && hour < 17) { // Day: Primary/Cyan
      return Color.lerp(AppTheme.primary.withOpacity(0.1), AppTheme.cyan.withOpacity(0.05), t)!;
    } else if (hour >= 17 && hour < 21) { // Evening: Gold/Rose
      return Color.lerp(Colors.orange.withOpacity(0.1), AppTheme.accent.withOpacity(0.05), t)!;
    } else { // Night: Deep Blue/Primary
      return Color.lerp(const Color(0xFF0A0E21).withOpacity(0.2), AppTheme.primary.withOpacity(0.05), t)!;
    }
  }

  Widget _buildPulseRing(double scaleFactor) {
    return Center(
      child: Opacity(
        opacity: (1 - _controller.value) * 0.1,
        child: Container(
          width: 600 * _controller.value * scaleFactor,
          height: 600 * _controller.value * scaleFactor,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primary, width: 2),
            gradient: RadialGradient(
              colors: [
                AppTheme.primary.withOpacity(0.2),
                AppTheme.primary.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
