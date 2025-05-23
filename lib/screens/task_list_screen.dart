// lib/screens/task_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';
import '../utils/priority_helper.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key}); // Añadir key y const

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddTaskDialog(initialCategory: 'Personal'), // Añadir un initialCategory por defecto
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final tasks = taskProv.tasks;
    final focusMode = taskProv.focusMode;
    final theme = Theme.of(context); // Obtener el tema para consistencia de colores

    return Scaffold(
      appBar: AppBar(
        // Usar los colores del tema para consistencia
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: const Text('TaskFlow'),
        actions: [
          IconButton(
            icon: Icon(
              focusMode ? Icons.self_improvement : Icons.sunny, // Iconos más representativos
              color: theme.appBarTheme.foregroundColor,
            ),
            tooltip: 'Modo Enfoque',
            onPressed: () {
              taskProv.toggleFocusMode();
              final snackMsg = taskProv.focusMode
                  ? 'Modo Enfoque activado.'
                  : 'Modo Enfoque desactivado.';
              ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Ocultar snackbar anterior
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(snackMsg), duration: const Duration(seconds: 1)));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (focusMode)
            Container(
              width: double.infinity,
              color: theme.colorScheme.primary.withOpacity(0.1), // Usar color del tema
              padding: const EdgeInsets.all(8),
              child: Text(
                'Modo Enfoque activado — Notificaciones silenciadas',
                style: TextStyle(color: theme.colorScheme.primary), // Usar color del tema
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('No hay tareas. Agrega una nueva.'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      final t = tasks[i];
                      // Lógica de colores para ListTile
                      final Color titleColor = t.isDone
                          ? (focusMode ? Colors.grey : theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.black54)
                          : (theme.textTheme.bodyMedium?.color ?? Colors.black);

                      final Color subtitleColor = t.isDone
                          ? (focusMode ? Colors.grey.shade600 : theme.textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.black45)
                          : (theme.textTheme.bodySmall?.color ?? Colors.black54);


                      return ListTile(
                        leading: Checkbox(
                          value: t.isDone,
                          onChanged: (_) => taskProv.toggleTaskDone(t.id), // Correcto
                        ),
                        title: Text(
                          t.title,
                          style: TextStyle(
                            decoration: t.isDone ? TextDecoration.lineThrough : null,
                            color: titleColor,
                          ),
                        ),
                        subtitle: t.dueDate != null
                            ? Text(
                                'Fecha límite: ${DateFormat('dd/MM/yyyy').format(t.dueDate!)}',
                                style: TextStyle(
                                    color: subtitleColor,
                                ),
                              )
                            : null,
                        trailing: Container(
                          width: 18, // Aumentar tamaño para visibilidad
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: PriorityHelper.getColor(t.priority), // Correcto
                          ),
                        ),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar tarea'),
                              content: const Text('¿Deseas eliminar esta tarea?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                ElevatedButton(
                                  child: const Text('Eliminar'),
                                  onPressed: () {
                                    taskProv.deleteTask(t.id); // ¡CORRECCIÓN CLAVE! Usar deleteTask
                                    Navigator.of(ctx).pop();
                                  },
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Agregar tarea',
        child: const Icon(Icons.add),
      ),
    );
  }
}