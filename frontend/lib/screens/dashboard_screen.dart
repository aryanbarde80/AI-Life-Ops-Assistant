import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/ai_stories.dart';
import '../widgets/dynamic_bg.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AiStories(),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      child: const Text(
                        'Command Center',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeInDown(
                      delay: const Duration(milliseconds: 200),
                      child: const Text(
                        'All systems operational. Advanced Agentic Mesh active.',
                        style: TextStyle(color: AppTheme.textSecondary, letterSpacing: 0.1),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildStatsGrid(context),
                    const SizedBox(height: 40),
                    _buildUserOverview(context),
                    const SizedBox(height: 40),
                    _buildMissionBoard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Expanded(child: _statCard('AGENTS', '04', AppTheme.primary, Icons.hub_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _statCard('STREAK', '12d', AppTheme.amber, Icons.local_fire_department_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _statCard('EFFICIENCY', '94%', AppTheme.emerald, Icons.speed_rounded)),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return FadeInUp(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted, letterSpacing: 1.5)),
                Icon(icon, color: color.withOpacity(0.5), size: 14),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserOverview(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://api.dicebear.com/7.x/avataaars/svg?seed=Felix'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Agent Felix', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Rank: Elite Optimizer • Level 8', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                  _buildStatusChip('ONLINE'),
                ],
              ),
              const SizedBox(height: 24),
              _buildXpBar(0.72),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.emerald.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.emerald.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.emerald, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppTheme.emerald, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildXpBar(double progress) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('XP PROGRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
            Text('${(progress * 100).toInt()}% TO LEVEL 9', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.surfaceElevated,
            color: AppTheme.primary,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionBoard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mission Criticals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Consumer<TaskProvider>(
          builder: (context, provider, _) {
            final tasks = provider.pendingTasks.take(3).toList();
            if (tasks.isEmpty) return const Text('No missions active.', style: TextStyle(color: AppTheme.textMuted));
            return Column(
              children: tasks.map((t) => _missionItem(t)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _missionItem(dynamic task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(task.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppTheme.surfaceElevated, shape: BoxShape.circle),
              child: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
