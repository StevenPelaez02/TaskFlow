// lib/widgets/add_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/priority_helper.dart';

class AddTaskDialog extends StatefulWidget {
  final Task? taskToEdit;
  final String? initialCategory;

  const AddTaskDialog({
    super.key,
    this.taskToEdit,
    this.initialCategory,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  Priority _selectedPriority = Priority.Media;
  DateTime? _selectedDueDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedPriority = widget.taskToEdit?.priority ?? Priority.Media;
    _selectedDueDate = widget.taskToEdit?.dueDate;
    _selectedCategory = widget.taskToEdit?.category ?? widget.initialCategory ?? 'Personal';

    // Asegurarse de que la categoría inicial exista en la lista de categorías, si no, usa la primera.
    // Esto es útil si las categorías predefinidas cambian.
    final List<String> availableCategories = ['Personal', 'Casa', 'Trabajo', 'Estudios'];
    if (_selectedCategory != null && !availableCategories.contains(_selectedCategory)) {
      _selectedCategory = availableCategories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
    setState(() {
      _selectedDueDate = pickedDate;
    });
  }

  void _submitTask() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final taskProv = Provider.of<TaskProvider>(context, listen: false);

      if (widget.taskToEdit == null) {
        final newTask = Task(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          category: _selectedCategory,
        );
        taskProv.addTask(newTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea añadida correctamente.')),
        );
      } else {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          category: _selectedCategory,
        );
        taskProv.updateTask(updatedTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea actualizada correctamente.')),
        );
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.taskToEdit == null ? 'Añadir Tarea' : 'Editar Tarea'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un título.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                maxLines: 3,
              ),
              DropdownButtonFormField<Priority>(
                value: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                items: Priority.values.map((Priority p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(PriorityHelper.priorityToString(p)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedPriority = newValue!;
                  });
                },
              ),
              // Aquí estaba el DropdownButtonFormField para la categoría
              // Si quieres que no se vea, asegúrate de que este bloque no esté.
              // Si lo quieres de vuelta, aquí está el código:
              // DropdownButtonFormField<String>(
              //   value: _selectedCategory,
              //   decoration: const InputDecoration(labelText: 'Categoría'),
              //   items: <String>['Personal', 'Casa', 'Trabajo', 'Estudios']
              //       .map<DropdownMenuItem<String>>((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       _selectedCategory = newValue;
              //     });
              //   },
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Por favor, selecciona una categoría.';
              //     }
              //     return null;
              //   },
              // ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDueDate == null
                          ? 'No hay fecha seleccionada'
                          : DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
                    ),
                  ),
                  IconButton(
                    onPressed: _presentDatePicker,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submitTask,
          child: Text(widget.taskToEdit == null ? 'Añadir' : 'Guardar'),
        ),
      ],
    );
  }
}