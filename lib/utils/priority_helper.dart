import 'package:flutter/material.dart';
import '../models/task.dart';

class PriorityHelper {
  static Color getColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade600;
      case Priority.medium:
        return Colors.orange.shade700;
      case Priority.low:
      default:
        return Colors.green.shade400;
    }
  }

  static String getText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return "Alta";
      case Priority.medium:
        return "Media";
      case Priority.low:
      default:
        return "Baja";
    }
  }
}
