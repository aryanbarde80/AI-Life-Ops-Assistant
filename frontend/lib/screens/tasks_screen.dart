import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedPriority = 'medium';
  String _filterPriority = 'all';
  bool _showCompleted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _openAddTaskSheet() {
    _titleController.clear();
    _descController.clear();
    _selectedPriority = 'medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Add New Task',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Task title...',
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Optional description...',
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Priority',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: ['low', 'medium', 'high'].map((p) {
                  final colors = {
                    'low': AppTheme.accentGreen,
                    'medium': AppTheme.primary,
                    'high': AppTheme.accentAmber,
                  };
                  final color = colors[p]!;
                  final selected = _selectedPriority == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () =>
                          setModalState(() => _selectedPriority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withOpacity(0.2)
                              : AppTheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selected ? color : AppTheme.border),
                        ),
                        child: Text(
                          p[0].toUpperCase() + p.substring(1),
                          style: TextStyle(
                            color: selected ? color : AppTheme.textSecondary,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.trim().isEmpty) return;
                    context.read<TaskProvider>().addTask(
                          title: _titleController.text,
                          description: _descController.text,
                          priority: _selectedPriority,
                        );
                    Navigator.pop(context);
                  },
                  child: const Text('Add Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTaskSheet,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Task',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Tasks',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              SizedBox(height: 4),
              Text('Stay organised and on track.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          Row(
            children: [
              const Text('Show completed',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(width: 8),
              Switch(
                value: _showCompleted,
                onChanged: (v) => setState(() => _showCompleted = v),
                activeColor: AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: ['all', 'high', 'medium', 'low'].map((filter) {
          final selected = _filterPriority == filter;
          final colors = {
            'all': AppTheme.primary,
            'high': AppTheme.accentAmber,
            'medium': AppTheme.primary,
            'low': AppTheme.accentGreen,
          };
          final color = colors[filter]!;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterPriority = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withOpacity(0.2)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? color : AppTheme.border),
                ),
                child: Text(
                  filter[0].toUpperCase() + filter.substring(1),
                  style: TextStyle(
                    color: selected ? color : AppTheme.textSecondary,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        var tasks = provider.tasks.where((t) {
          if (!_showCompleted && t.completed) return false;
          if (_filterPriority != 'all' && t.priority != _filterPriority) {
            return false;
          }
          return true;
        }).toList();

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.task_alt_rounded,
                    size: 64, color: AppTheme.textMuted),
                const SizedBox(height: 16),
                const Text('No tasks here.',
                    style: TextStyle(
                        fontSize: 18, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                const Text('Tap "+ New Task" to get started.',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textMuted)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
          itemCount: tasks.length,
          itemBuilder: (context, index) =>
              _buildTaskCard(tasks[index], provider),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task, TaskProvider provider) {
    final priorityColors = {
      'high': AppTheme.accentAmber,
      'medium': AppTheme.primary,
      'low': AppTheme.accentGreen,
    };
    final color = priorityColors[task.priority] ?? AppTheme.primary;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => provider.deleteTask(task.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => provider.toggleTask(task.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color:
                      task.completed ? color : Colors.transparent,
                  border: Border.all(color: color, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: task.completed
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: task.completed
                          ? AppTheme.textMuted
                          : AppTheme.textPrimary,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(task.description,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                task.priority,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppTheme.textMuted),
              onPressed: () => provider.deleteTask(task.id),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
