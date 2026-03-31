import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/chat_provider.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.05),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: _buildHeader(context),
                ),
                const SizedBox(height: 32),
                _buildStatsGrid(context),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: FadeInLeft(
                        delay: const Duration(milliseconds: 400),
                        child: _buildMainFocus(context),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: FadeInRight(
                        delay: const Duration(milliseconds: 600),
                        child: _buildAiInsights(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ).createShader(bounds),
              child: const Text(
                'Command Center',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "System is operational. Your life ops are synced.",
              style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.2),
            ),
          ],
        ),
        _buildGlassBadge(_formattedDate()),
      ],
    );
  }

  Widget _buildGlassBadge(String text) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 12,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Expanded(
              child: FadeInUp(
                delay: const Duration(milliseconds: 100),
                child: _premiumStatCard(
                  title: 'Tasks Active',
                  value: provider.pendingCount.toString(),
                  icon: Icons.bolt_rounded,
                  color: AppTheme.cyan,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: _premiumStatCard(
                  title: 'Completed',
                  value: provider.completedCount.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: AppTheme.emerald,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: FadeInUp(
                delay: const Duration(milliseconds: 300),
                child: _premiumStatCard(
                  title: 'Efficiency',
                  value: '${(provider.completionRate * 100).toInt()}%',
                  icon: Icons.auto_graph_rounded,
                  color: AppTheme.amber,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _premiumStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary)),
              Icon(icon, color: color.withOpacity(0.8), size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: title == 'Efficiency' ? 0.7 : 0.4, // placeholder logic
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.5)),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFocus(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.radar_rounded, color: AppTheme.primary, size: 20),
              SizedBox(width: 12),
              Text('Current Objectives',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Consumer<TaskProvider>(
            builder: (context, provider, _) {
              final tasks = provider.pendingTasks.take(4).toList();
              if (tasks.isEmpty) {
                return _buildEmptyObjectives();
              }
              return Column(
                children: tasks.map((t) => _objectiveRow(t)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _objectiveRow(dynamic task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.priority == 'high' ? AppTheme.rose : AppTheme.primary,
              boxShadow: [
                BoxShadow(
                  color: (task.priority == 'high' ? AppTheme.rose : AppTheme.primary).withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(task.title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ),
          Text(task.priority.toUpperCase(),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textMuted,
                  letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildEmptyObjectives() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.emerald, size: 40),
            SizedBox(height: 12),
            Text('All systems clear.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildAiInsights() {
    return GlassCard(
      color: AppTheme.primary.withOpacity(0.08),
      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨ AI Insights',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary)),
          const SizedBox(height: 16),
          _insightLine("Your productivity is up 12% this week."),
          _insightLine("Focus on the 'high priority' task first."),
          _insightLine("You haven't checked in for 4 hours."),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(double.infinity, 44),
            ),
            child: const Text('Open Insights'),
          ),
        ],
      ),
    );
  }

  Widget _insightLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppTheme.primary, fontSize: 18)),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
