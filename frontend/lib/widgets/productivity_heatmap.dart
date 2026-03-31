import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/app_theme.dart';

class ProductivityHeatmap extends StatelessWidget {
  const ProductivityHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Productivity Pulse', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: List.generate(24, (index) {
              final val = Random().nextDouble();
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(val < 0.2 ? 0.05 : val),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
