import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/chat_provider.dart';
import 'providers/task_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const MainShell(),
        '/chat': (context) => const ChatScreen(),
        '/tasks': (context) => const TasksScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
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

  final List<Widget> _screens = const [
    DashboardScreen(),
    ChatScreen(),
    TasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            selectedIconTheme: const IconThemeData(color: AppTheme.primary),
            unselectedIconTheme: IconThemeData(color: AppTheme.textMuted),
            selectedLabelTextStyle: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelTextStyle: TextStyle(color: AppTheme.textMuted),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.psychology_alt_rounded,
                        color: Colors.white, size: 26),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded),
                label: Text('AI Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.checklist_outlined),
                selectedIcon: Icon(Icons.checklist_rounded),
                label: Text('Tasks'),
              ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
