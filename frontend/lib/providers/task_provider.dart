import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get completedTasks => _tasks.where((t) => t.completed).toList();
  List<Task> get pendingTasks => _tasks.where((t) => !t.completed).toList();

  int get totalCount => _tasks.length;
  int get completedCount => completedTasks.length;
  int get pendingCount => pendingTasks.length;
  double get completionRate =>
      _tasks.isEmpty ? 0 : completedCount / totalCount;

  void addTask({
    required String title,
    String description = '',
    String priority = 'medium',
  }) {
    if (title.trim().isEmpty) return;
    _tasks.add(Task(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description.trim(),
      priority: priority,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(
      completed: !_tasks[index].completed,
    );
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void updatePriority(String id, String priority) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(priority: priority);
    notifyListeners();
  }
}
