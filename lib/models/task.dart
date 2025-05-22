enum Priority { high, medium, low }

class Task {
  String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    this.priority = Priority.medium,
    this.dueDate,
    this.isDone = false,
  });
}
