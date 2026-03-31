import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class CommandPalette extends StatelessWidget {
  final VoidCallback onClose;

  const CommandPalette({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: Colors.black.withOpacity(0.8),
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 100),
        child: ZoomIn(
          duration: const Duration(milliseconds: 300),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: GlassCard(
              padding: EdgeInsets.zero,
              borderRadius: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Execute Jarvis Command...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: AppTheme.textMuted),
                            ),
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
                          ),
                        ),
                        Text('ESC TO CLOSE', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppTheme.border),
                  _commandItem(Icons.bolt_rounded, 'Flash Deletion', 'Wipe all resolved missions'),
                  _commandItem(Icons.terminal_rounded, 'Debug Mesh', 'Open agentic reasoning logs'),
                  _commandItem(Icons.cloud_sync_rounded, 'K8s Rollout', 'Trigger autonomous scale-up'),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _commandItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        onTap: onClose,
        hoverColor: AppTheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
