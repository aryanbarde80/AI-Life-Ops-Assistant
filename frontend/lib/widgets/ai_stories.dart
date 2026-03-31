import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class AiStories extends StatelessWidget {
  const AiStories({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemBuilder: (context, index) {
          return _buildStoryItem(index);
        },
      ),
    );
  }

  Widget _buildStoryItem(int index) {
    final titles = ['Daily', 'Intel', 'Tasks', 'Focus', 'Goals', 'Sync'];
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          FadeInRight(
            delay: Duration(milliseconds: index * 100),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.accent, AppTheme.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.surfaceElevated,
                  child: Icon(
                    _getIcon(index),
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titles[index],
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0: return Icons.wb_sunny_rounded;
      case 1: return Icons.psychology_rounded;
      case 2: return Icons.checklist_rounded;
      case 3: return Icons.timer_rounded;
      case 4: return Icons.flag_rounded;
      default: return Icons.sync_rounded;
    }
  }
}
