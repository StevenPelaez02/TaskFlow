// lib/models/task.dart
import 'package:hive/hive.dart';

part 'task.g.dart'; // Asegúrate de que esta línea esté presente

@HiveType(typeId: 0) // El typeId debe ser único para cada clase de HiveObject
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 1) // El typeId debe ser único para cada clase de HiveObject
class Task extends HiveObject { // Asegúrate de que Task extienda HiveObject
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime? dueDate;
  @HiveField(3)
  final Priority priority;
  @HiveField(4)
  final bool isDone;
  @HiveField(5)
  final String description;
  @HiveField(6) // <<-- ¡NUEVO CAMPO! Asigna un nuevo HiveField id único
  final String category; // <<-- ¡NUEVA PROPIEDAD!

  Task({
    required this.id,
    required this.title,
    this.dueDate,
    this.priority = Priority.low,
    this.isDone = false,
    this.description = "",
    this.category = "Personal", // <<-- VALOR POR DEFECTO PARA CATEGORÍA
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? dueDate,
    Priority? priority,
    bool? isDone,
    String? description,
    String? category, // <<-- NUEVO CAMPO EN copyWith
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isDone: isDone ?? this.isDone,
      description: description ?? this.description,
      category: category ?? this.category, // <<-- NUEVO CAMPO EN copyWith
    );
  }
}