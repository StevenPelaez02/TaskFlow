import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../providers/task_provider.dart';

class AddTaskDialog extends StatefulWidget {
  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nueva tarea'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 10),
            DropdownButton<Priority>(
              value: _selectedPriority,
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPriority = val);
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(_selectedDate == null
                    ? 'Sin fecha'
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!)),
                Spacer(),
                TextButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Text('Seleccionar fecha'),
                ),
              ],
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar')),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isEmpty) return;
            final newTask = Task(
              id: DateTime.now().toString(),
              title: _titleController.text.trim(),
              priority: _selectedPriority,
              dueDate: _selectedDate,
            );
            Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
            Navigator.of(context).pop();
          },
          child: Text('Agregar'),
        ),
      ],
    );
  }
}
