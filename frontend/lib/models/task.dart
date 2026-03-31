class Task {
  final String id;
  String title;
  String description;
  bool completed;
  final DateTime createdAt;
  String priority; // 'high', 'medium', 'low'

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    required this.createdAt,
    this.priority = 'medium',
  });

  Task copyWith({
    String? title,
    String? description,
    bool? completed,
    String? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      createdAt: createdAt,
      priority: priority ?? this.priority,
    );
  }
}
