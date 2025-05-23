// lib/providers/task_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'auth_provider.dart';

class TaskProvider extends ChangeNotifier {
  late Box<Task> _taskBox;
  List<Task> _tasks = [];
  bool _focusMode = false;
  bool _isInitialized = false;

  List<Task> get tasks => _tasks;
  bool get focusMode => _focusMode;
  bool get isInitialized => _isInitialized;

  TaskProvider(AuthProvider authProvider) {
    authProvider.addListener(() {
      _handleAuthChange(authProvider.currentUserEmail); // Se usa currentUserEmail
    });
    _handleAuthChange(authProvider.currentUserEmail); // Se usa currentUserEmail
  }

  Future<void> _handleAuthChange(String? currentUserEmail) async {
    if (currentUserEmail != null && !_isInitialized) {
      await _openTaskBox(currentUserEmail); // Se usa currentUserEmail
    } else if (currentUserEmail == null && _isInitialized) {
      await _closeTaskBox();
    }
  }

  Future<void> _openTaskBox(String email) async {
    final String boxName = 'tasks_${email.replaceAll('@', '_').replaceAll('.', '_')}';

    if (_isInitialized && _taskBox.isOpen) {
      await _closeTaskBox();
    }

    _taskBox = await Hive.openBox<Task>(boxName);
    _tasks = _taskBox.values.toList();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _closeTaskBox() async {
    if (_isInitialized && _taskBox.isOpen) {
      await _taskBox.close();
      _tasks = [];
      _isInitialized = false;
      notifyListeners();
    }
  }

  void addTask(Task task) {
    if (!_isInitialized) {
      debugPrint('TaskProvider no inicializado. No se puede añadir tarea.');
      return;
    }
    _taskBox.add(task);
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    if (!_isInitialized) {
      debugPrint('TaskProvider no inicializado. No se puede actualizar tarea.');
      return;
    }
    final index = _taskBox.values.toList().indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _taskBox.putAt(index, updatedTask);
      _tasks = _taskBox.values.toList();
      notifyListeners();
    }
  }

  void toggleTaskDone(String taskId) {
    if (!_isInitialized) {
      debugPrint('TaskProvider no inicializado. No se puede alternar tarea.');
      return;
    }
    final index = _taskBox.values.toList().indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _taskBox.getAt(index)!;
      task.isDone = !task.isDone;
      _taskBox.putAt(index, task);
      _tasks = _taskBox.values.toList();
      notifyListeners();
    }
  }

  void deleteTask(String id) { // ¡Este es el método correcto para eliminar!
    if (!_isInitialized) {
      debugPrint('TaskProvider no inicializado. No se puede eliminar tarea.');
      return;
    }
    final Map<dynamic, Task> tasksMap = _taskBox.toMap();
    dynamic keyToDelete;
    tasksMap.forEach((key, value) {
      if (value.id == id) {
        keyToDelete = key;
      }
    });
    if (keyToDelete != null) {
      _taskBox.delete(keyToDelete);
      _tasks = _taskBox.values.toList();
      notifyListeners();
    }
  }

  void toggleFocusMode() {
    _focusMode = !_focusMode;
    notifyListeners();
  }
}