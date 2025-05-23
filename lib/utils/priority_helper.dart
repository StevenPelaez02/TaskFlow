// lib/utils/priority_helper.dart
import 'package:flutter/material.dart';
import '../models/task.dart';

class PriorityHelper {
  static String priorityToString(Priority priority) {
    switch (priority) {
      case Priority.Baja:
        return 'Baja';
      case Priority.Media:
        return 'Media';
      case Priority.Alta:
        return 'Alta';
      default:
        return 'Desconocida';
    }
  }

  static Priority stringToPriority(String priorityString) {
    switch (priorityString) {
      case 'Baja':
        return Priority.Baja;
      case 'Media':
        return Priority.Media;
      case 'Alta':
        return Priority.Alta;
      default:
        return Priority.Baja;
    }
  }

  static Color getColor(Priority priority) {
    switch (priority) {
      case Priority.Baja:
        return Colors.blue;
      case Priority.Media:
        return Colors.orange;
      case Priority.Alta:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}