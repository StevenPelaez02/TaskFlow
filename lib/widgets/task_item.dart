// lib/widgets/task_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart'; // Necesario para DateFormat
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/priority_helper.dart'; // Necesario para PriorityHelper

class TaskItem extends StatelessWidget {
  final Task t;
  final bool done;
  final Color cardColor;
  final Color doneTextColor;
  final Color doneSubtitleColor;

  const TaskItem({
    super.key,
    required this.t,
    required this.done,
    required this.cardColor,
    required this.doneTextColor,
    required this.doneSubtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    // Se usa listen: false porque solo se invocan métodos, no se necesita reconstruir el widget
    final taskProv = Provider.of<TaskProvider>(context, listen: false);

    return Slidable(
      key: ValueKey(t.id), // Una clave única para el Slidable
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (ctx) async {
              // Muestra un diálogo de confirmación antes de eliminar
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirmar eliminación'),
                  content: const Text('¿Estás seguro de que quieres eliminar esta tarea?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // Llama al método deleteTask del TaskProvider
                taskProv.deleteTask(t.id); // ¡IMPORTANTE: Aquí se usa deleteTask!
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tarea eliminada.')),
                );
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
        ],
      ),
      child: Card(
        color: cardColor, // Usa el color de la tarjeta proporcionado
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListTile(
          leading: Checkbox(
            value: t.isDone,
            onChanged: (newValue) {
              // Llama al método toggleTaskDone del TaskProvider
              taskProv.toggleTaskDone(t.id); // ¡IMPORTANTE: Aquí se usa toggleTaskDone!
            },
          ),
          title: Text(
            t.title,
            style: TextStyle(
              decoration: done ? TextDecoration.lineThrough : null,
              color: doneTextColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (t.description != null && t.description!.isNotEmpty)
                Text(
                  t.description!,
                  style: TextStyle(
                    color: doneSubtitleColor,
                  ),
                ),
              if (t.category != null && t.category!.isNotEmpty)
                Text(
                  'Categoría: ${t.category}',
                  style: TextStyle(
                    color: doneSubtitleColor,
                  ),
                ),
              Row(
                children: [
                  Text(
                    'Prioridad: ${PriorityHelper.priorityToString(t.priority)}', // Uso de PriorityHelper
                    style: TextStyle(
                      color: doneSubtitleColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: PriorityHelper.getColor(t.priority), // Uso de PriorityHelper
                    ),
                  ),
                ],
              ),
              if (t.dueDate != null)
                Text(
                  'Fecha límite: ${DateFormat('dd/MM/yyyy').format(t.dueDate!)}',
                  style: TextStyle(
                    color: doneSubtitleColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}