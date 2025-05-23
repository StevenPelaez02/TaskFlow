// lib/widgets/add_task_dialog.dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/priority_helper.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? initialTask;
  final String? initialCategory;
  final void Function(Task)? onSave;

  const AddTaskDialog({
    this.initialTask,
    this.initialCategory,
    this.onSave,
    super.key,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _selectedDate;
  Priority _priority = Priority.low;
  late String _taskCategory; // No es _selectedCategory, es la categoría FINAL de la tarea

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descController = TextEditingController(text: widget.initialTask?.description ?? '');
    _selectedDate = widget.initialTask?.dueDate;
    _priority = widget.initialTask?.priority ?? Priority.low;

    // Si estamos editando una tarea existente, usamos su categoría.
    // Si estamos creando una nueva tarea, usamos la initialCategory pasada desde la pestaña,
    // o 'Personal' como fallback si no se pasó ninguna.
    _taskCategory = widget.initialTask?.category ?? widget.initialCategory ?? 'Personal';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = Task(
        id: widget.initialTask?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        description: _descController.text,
        dueDate: _selectedDate,
        priority: _priority,
        isDone: widget.initialTask?.isDone ?? false,
        category: _taskCategory,
      );

      final taskProv = Provider.of<TaskProvider>(context, listen: false);
      if (widget.initialTask == null) {
        taskProv.addTask(task);
      } else {
        taskProv.updateTask(task);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Descripción (opcional)'),
                maxLines: 3,
                minLines: 1,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Prioridad:'),
                  SizedBox(width: 8),
                  DropdownButton<Priority>(
                    value: _priority,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _priority = newValue;
                        });
                      }
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
              // Aquí estaba el widget para mostrar la categoría asignada, ahora eliminado.
              // Puedes eliminar el SizedBox(height: 10) que estaba después si no hay nada más que necesite espacio.
              Row(
                children: [
                  Text("Fecha límite:"),
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