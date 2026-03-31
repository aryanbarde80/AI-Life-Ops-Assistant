import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class LandingPage extends StatelessWidget {
  final VoidCallback onEnter;

  const LandingPage({super.key, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          _buildBackgroundParticles(),
          SingleChildScrollView(
            child: Column(
              children: [
                _buildNavbar(),
                _buildHero(context),
                _buildFeatures(context),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundParticles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: _glowCircle(AppTheme.primary, 400),
        ),
        Positioned(
          bottom: -150,
          right: -150,
          child: _glowCircle(AppTheme.accent, 500),
        ),
      ],
    );
  }

  Widget _glowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.0),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4.seconds);
  }

  Widget _buildNavbar() {
    return FadeInDown(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.black),
                ),
                const SizedBox(width: 16),
                const Text(
                  'LIFE OPS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _navLink('Features'),
                _navLink('Architecture'),
                _navLink('Security'),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: onEnter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('LAUNCH APP', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: const Text(
                'NEXT-GEN PRODUCTIVITY IS HERE',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: const Text(
              'Unleash the Power of\nAgentic AI in Your Life',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.w900,
                height: 1.1,
                letterSpacing: -2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Text(
                'AI Life Ops Assistant is not just an app. It is your second brain. '
                'Seamlessly integrated with LangChain, OpenAI, and a self-healing local engine.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          FadeInUp(
            delay: const Duration(milliseconds: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onEnter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('ENTER COMMAND CENTER', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                ),
                const SizedBox(width: 24),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                  child: const Text('VIEW SOURCE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 100),
      child: Column(
        children: [
          const Text('SYSTEM CAPABILITIES', style: TextStyle(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 16),
          const Text('Built for the Modern Optimizer', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 64),
          Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.center,
            children: [
              _featureCard(Icons.psychology_rounded, 'Agentic Intelligence', 'Independent reasoning loop with per-user persistent memory.'),
              _featureCard(Icons.storage_rounded, 'Real-time Sync', 'Firestore-backed state management across all your devices.'),
              _featureCard(Icons.shield_rounded, 'Self-Healing', 'Automatic fallback to local tiny LLMs when APIs are down.'),
              _featureCard(Icons.auto_graph_rounded, 'Clean Architecture', 'Production-grade system design for maximum stability.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 32),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(desc, style: const TextStyle(color: AppTheme.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 64),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('© 2026 AI Life Ops Assistant. Production Ready.', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          Row(
            children: [
              Text('GitHub', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              SizedBox(width: 24),
              Text('Privacy', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              SizedBox(width: 24),
              Text('Terms', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
