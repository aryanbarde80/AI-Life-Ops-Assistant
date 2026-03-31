import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/chat_provider.dart';
import 'providers/task_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/landing_page.dart';
import 'providers/metrics_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => SystemMetricsProvider()..startListening()),
      ],
      child: const AiLifeOpsApp(),
    ),
  );
}

class AiLifeOpsApp extends StatelessWidget {
  const AiLifeOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Life Ops Assistant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _showLanding = true;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ChatScreen(),
    TasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_showLanding) {
      return LandingPage(
        onEnter: () => setState(() => _showLanding = false),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            extended: MediaQuery.of(context).size.width > 900,
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary.withOpacity(0.2),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: GestureDetector(
                onTap: () => setState(() => _showLanding = true),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 26),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded, color: AppTheme.primary),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppTheme.primary),
                label: Text('AI Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.checklist_outlined),
                selectedIcon: Icon(Icons.checklist_rounded, color: AppTheme.primary),
                label: Text('Tasks'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppTheme.border),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
