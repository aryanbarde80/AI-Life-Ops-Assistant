import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class K8sStatusWidget extends StatelessWidget {
  const K8sStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('K8s INFRASTRUCTURE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted, letterSpacing: 1.5)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('ZONE: US-EAST-1', style: TextStyle(fontSize: 8, color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _podIndicator('Brain-1', true),
            _podIndicator('Brain-2', true),
            _podIndicator('Research-1', true),
            _podIndicator('ML-1', false),
          ],
        ),
      ],
    );
  }

  Widget _podIndicator(String name, bool active) {
    return Column(
      children: [
        Pulse(
          infinite: active,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: active ? AppTheme.emerald : AppTheme.textMuted,
              shape: BoxShape.circle,
              boxShadow: active ? [BoxShadow(color: AppTheme.emerald.withOpacity(0.5), blurRadius: 8)] : null,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontSize: 8, color: AppTheme.textSecondary)),
      ],
    );
  }
}
