import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/priority_helper.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? initialTask;
  final void Function(Task)? onSave;
  const AddTaskDialog({this.initialTask, this.onSave, super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _selectedDate;
  Priority _priority = Priority.low;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descController = TextEditingController(text: widget.initialTask?.description ?? '');
    _selectedDate = widget.initialTask?.dueDate;
    _priority = widget.initialTask?.priority ?? Priority.low;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.initialTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        dueDate: _selectedDate,
        priority: _priority,
        isDone: widget.initialTask?.isDone ?? false,
        description: _descController.text.trim(),
      );

      if (widget.onSave != null) {
        widget.onSave!(task);
      } else {
        final provider = Provider.of<TaskProvider>(context, listen: false);
        if (widget.initialTask == null) {
          provider.addTask(task);
        } else {
          provider.updateTask(task);
        }
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      title: Text(widget.initialTask == null ? 'Nueva Tarea' : 'Editar Tarea'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Título'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Ingrese un título' : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Descripción'),
                minLines: 2,
                maxLines: 4,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Prioridad:"),
                  SizedBox(width: 10),
                  DropdownButton<Priority>(
                    value: _priority,
                    borderRadius: BorderRadius.circular(10),
                    onChanged: (value) {
                      if (value != null) setState(() => _priority = value);
                    },
                    items: Priority.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(PriorityHelper.getText(p)),
                            ))
                        .toList(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("Fecha:"),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _pickDate,
                      child: Text(
                        _selectedDate == null
                            ? "Seleccionar"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                      ),
                    ),
                  ),
                  if (_selectedDate != null)
                    IconButton(
                      icon: Icon(Icons.close, size: 20),
                      onPressed: () => setState(() => _selectedDate = null),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text(widget.initialTask == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }
}
