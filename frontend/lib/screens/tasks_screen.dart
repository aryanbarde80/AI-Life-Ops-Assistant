import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _filterPriority = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildPriorityChips(),
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: const Text('Add Task', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.cyan],
              ).createShader(bounds),
              child: const Text('Objective Sync',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
            const SizedBox(height: 4),
            const Text('Manage your tactical objectives for the day.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChips() {
    return FadeIn(
      delay: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: Row(
          children: ['all', 'high', 'medium', 'low'].map((p) {
            final selected = _filterPriority == p;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: () => setState(() => _filterPriority = p),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary : AppTheme.surfaceElevated.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? AppTheme.primary : AppTheme.border),
                    boxShadow: selected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 10)] : null,
                  ),
                  child: Text(
                    p.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.black : AppTheme.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasks = provider.tasks.where((t) {
          if (_filterPriority == 'all') return true;
          return t.priority == _filterPriority;
        }).toList();

        if (tasks.isEmpty) return _buildEmpty();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 100),
          itemCount: tasks.length,
          itemBuilder: (context, index) => FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: _taskItem(tasks[index], provider),
          ),
        );
      },
    );
  }

  Widget _taskItem(Task task, TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => provider.deleteTask(task.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppTheme.rose.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: AppTheme.rose),
        ),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => provider.toggleTask(task.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: task.completed ? AppTheme.emerald : AppTheme.border, width: 2),
                    color: task.completed ? AppTheme.emerald : Colors.transparent,
                  ),
                  child: task.completed ? const Icon(Icons.check_rounded, size: 16, color: Colors.black) : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                            color: task.completed ? AppTheme.textMuted : AppTheme.textPrimary)),
                    if (task.description.isNotEmpty)
                      Text(task.description,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              _priorityBadge(task.priority),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityBadge(String p) {
    final color = p == 'high' ? AppTheme.rose : (p == 'medium' ? AppTheme.primary : AppTheme.emerald);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(p.toUpperCase(),
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rounded, size: 64, color: AppTheme.surfaceElevated),
          const SizedBox(height: 16),
          const Text('No objectives found.', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: AppTheme.surface.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: AppTheme.border)),          title: const Text('New Objective', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Task Title', border: UnderlineInputBorder()),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    context.read<TaskProvider>().addTask(title: _titleController.text);
                    _titleController.clear();
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Create')),
          ],
        ),
      ),
    );
  }
}
import 'dart:ui';
