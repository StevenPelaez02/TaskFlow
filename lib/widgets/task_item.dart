import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_dialog.dart';
import '../utils/priority_helper.dart';

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
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(t.id),
      direction: Axis.horizontal,
      closeOnScroll: true,
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            onPressed: (_) async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: theme.cardColor,
                  title: Text('Eliminar tarea', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  content: Text('¿Seguro que deseas eliminar esta tarea?',
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  actions: [
                    TextButton(
                      child: Text('Cancelar', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                    ElevatedButton(
                      child: Text('Eliminar'),
                      onPressed: () => Navigator.of(ctx).pop(true),
                    )
                  ],
                ),
              );
              Slidable.of(context)?.close();
              if (confirm == true) {
                Provider.of<TaskProvider>(context, listen: false).removeTask(t.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tarea eliminada')),
                );
              }
            },
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.red[400],
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red[400],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(1, 2),
                  )
                ],
              ),
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(Icons.delete, color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
      endActionPane: null,
      child: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AddTaskDialog(
              initialTask: t,
              onSave: (editedTask) {
                Provider.of<TaskProvider>(context, listen: false)
                    .updateTask(editedTask);
              },
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              if (!done)
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                )
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 12),
            minLeadingWidth: 0,
            leading: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: PriorityHelper.getColor(t.priority),
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(right: 14),
            ),
            title: Text(
              t.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: doneTextColor,
                decoration: done ? TextDecoration.lineThrough : null,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (t.dueDate != null)
                  Text(
                    DateFormat('dd/MM/yyyy').format(t.dueDate!),
                    style: TextStyle(
                      color: doneSubtitleColor,
                      fontSize: 13.5,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    PriorityHelper.getText(t.priority),
                    style: TextStyle(
                      color: PriorityHelper.getColor(t.priority),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (t.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      t.description,
                      style: TextStyle(
                        color: doneSubtitleColor,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            trailing: Checkbox(
              value: t.isDone,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              onChanged: (_) => Provider.of<TaskProvider>(context, listen: false).toggleTaskDone(t.id),
              activeColor: Colors.green,
            ),
            onTap: () => Provider.of<TaskProvider>(context, listen: false).toggleTaskDone(t.id),
          ),
        ),
      ),
    );
  }
}
