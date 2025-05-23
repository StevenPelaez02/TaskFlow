enum Priority { low, medium, high }

class Task {
  final String id;
  final String title;
  final DateTime? dueDate;
  final Priority priority;
  final bool isDone;
  final String description;

  Task({
    required this.id,
    required this.title,
    this.dueDate,
    this.priority = Priority.low,
    this.isDone = false,
    this.description = "",
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    Priority? priority,
    bool? isDone,
    String? description,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      description: description ?? this.description,
    );
  }
}
