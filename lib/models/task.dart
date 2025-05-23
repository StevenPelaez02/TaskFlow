// lib/models/task.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart'; // Asegúrate de que esta línea esté presente y sea correcta

@HiveType(typeId: 0)
enum Priority {
  @HiveField(0)
  Baja,
  @HiveField(1)
  Media,
  @HiveField(2)
  Alta,
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  String? description;
  @HiveField(3)
  Priority priority;
  @HiveField(4)
  bool isDone;
  @HiveField(5)
  DateTime? dueDate;
  @HiveField(6)
  String? category;

  Task({
    String? id,
    required this.title,
    this.description,
    this.priority = Priority.Media,
    this.isDone = false,
    this.dueDate,
    this.category,
  }) : id = id ?? const Uuid().v4();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    bool? isDone,
    DateTime? dueDate,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
    );
  }
}