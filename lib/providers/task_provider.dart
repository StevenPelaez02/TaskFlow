import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  bool focusMode = false;

  void addTask(Task t) {
    _tasks.insert(0, t);
    notifyListeners();
  }

  void updateTask(Task t) {
    final idx = _tasks.indexWhere((x) => x.id == t.id);
    if (idx >= 0) {
      _tasks[idx] = t;
      notifyListeners();
    }
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void toggleTaskDone(String id) {
    final idx = _tasks.indexWhere((x) => x.id == id);
    if (idx >= 0) {
      final old = _tasks[idx];
      _tasks[idx] = old.copyWith(isDone: !old.isDone);
      notifyListeners();
    }
  }

  void toggleFocusMode() {
    focusMode = !focusMode;
    notifyListeners();
  }
}
