// lib/providers/task_provider.dart
import 'package:flutter/foundation.dart'; // Importar para @required o @protected (opcional)
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _taskBox; // Será inicializada asíncronamente
  List<Task> _tasks = [];
  bool _focusMode = false; // Estado del modo enfoque

  List<Task> get tasks {
    // Si la caja no ha sido inicializada, devuelve una lista vacía para evitar errores
    if (!Hive.isBoxOpen('tasks')) {
      return [];
    }
    return [..._tasks];
  }

  bool get focusMode => _focusMode;

  TaskProvider() {
    _initHiveBox(); // Iniciar la carga de la caja de forma asíncrona
  }

  Future<void> _initHiveBox() async {
    // Asegurarse de que la caja esté abierta antes de intentar acceder a ella.
    // Si ya está abierta, Hive.openBox simplemente devolverá la instancia existente.
    _taskBox = await Hive.openBox<Task>('tasks');
    _loadTasks(); // Cargar tareas una vez que la caja esté lista
  }

  void _loadTasks() {
    // Solo cargar si la caja está abierta y fue inicializada
    if (_taskBox.isOpen) {
      _tasks = _taskBox.values.toList();
      notifyListeners(); // Notifica a la UI que las tareas han cargado
    }
  }

  void addTask(Task task) {
    if (_taskBox.isOpen) {
      _taskBox.put(task.id, task);
      _loadTasks(); // Recargar todas las tareas
    }
  }

  void updateTask(Task updatedTask) {
    if (_taskBox.isOpen) {
      _taskBox.put(updatedTask.id, updatedTask);
      _loadTasks(); // Recargar todas las tareas
    }
  }

  void removeTask(String taskId) {
    if (_taskBox.isOpen) {
      _taskBox.delete(taskId);
      _loadTasks(); // Recargar todas las tareas
    }
  }

  void toggleTaskDone(String taskId) {
    if (_taskBox.isOpen) {
      final task = _taskBox.get(taskId);
      if (task != null) {
        final updatedTask = task.copyWith(isDone: !task.isDone);
        _taskBox.put(updatedTask.id, updatedTask);
        _loadTasks(); // Recargar todas las tareas
      }
    }
  }

  void toggleFocusMode() {
    _focusMode = !_focusMode;
    notifyListeners();
  }
}