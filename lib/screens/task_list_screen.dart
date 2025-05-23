import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/add_task_dialog.dart';
import '../utils/priority_helper.dart';

class TaskListScreen extends StatefulWidget {
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final tasks = taskProv.tasks;
    final focusMode = taskProv.focusMode;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: focusMode ? Colors.blue.shade900 : Colors.green,
        title: Text('TaskFlow'),
        actions: [
          IconButton(
            icon: Icon(
              focusMode ? Icons.do_not_disturb_on : Icons.do_not_disturb_off,
              color: Colors.white,
            ),
            tooltip: 'Modo Enfoque',
            onPressed: () {
              taskProv.toggleFocusMode();
              final snackMsg = taskProv.focusMode
                  ? 'Modo Enfoque activado'
                  : 'Modo Enfoque desactivado';
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(snackMsg)));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (focusMode)
            Container(
              width: double.infinity,
              color: Colors.blue.shade100,
              padding: EdgeInsets.all(8),
              child: Text(
                'Modo Enfoque activado — Notificaciones silenciadas',
                style: TextStyle(color: Colors.blue.shade900),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: tasks.isEmpty
                ? Center(child: Text('No hay tareas. Agrega una nueva.'))
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      final t = tasks[i];
                      return ListTile(
                        leading: Checkbox(
                          value: t.isDone,
                          onChanged: (_) => taskProv.toggleTaskDone(t.id),
                        ),
                        title: Text(
                          t.title,
                          style: TextStyle(
                            decoration:
                                t.isDone ? TextDecoration.lineThrough : null,
                            color:
                                focusMode && t.isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        subtitle: t.dueDate != null
                            ? Text(
                                'Fecha límite: ${DateFormat('dd/MM/yyyy').format(t.dueDate!)}',
                                style: TextStyle(
                                    color: focusMode && t.isDone
                                        ? Colors.grey
                                        : Colors.black54),
                              )
                            : null,
                        trailing: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: PriorityHelper.getColor(t.priority),
                          ),
                        ),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Eliminar tarea'),
                              content: Text('¿Deseas eliminar esta tarea?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancelar'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                ElevatedButton(
                                  child: Text('Eliminar'),
                                  onPressed: () {
                                    taskProv.removeTask(t.id);
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
        child: Icon(Icons.add),
      ),
    );
  }
}