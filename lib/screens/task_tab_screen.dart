import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Asegúrate de que intl esté importado si lo usas en TaskItem

import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_item.dart';
import '../widgets/app_drawer.dart';
import '../utils/priority_helper.dart';

class TaskTabScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;
  const TaskTabScreen({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<TaskTabScreen> createState() => _TaskTabScreenState();
}

class _TaskTabScreenState extends State<TaskTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Todas', 'Casa', 'Trabajo'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddTaskDialog(),
    );
  }

  List<Task> _filterTasks(List<Task> tasks, String tab) {
    if (tab == 'Todas') return tasks;
    return tasks.where((t) {
      if (tab == 'Casa') {
        return t.title.toLowerCase().contains('casa');
      } else if (tab == 'Trabajo') {
        return t.title.toLowerCase().contains('trabajo');
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark; // Detectar si estamos en modo oscuro

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<TaskProvider>(context).focusMode
            ? colorScheme.primary // Si modo enfoque, usa el color primario del tema
            : theme.appBarTheme.backgroundColor, // Si no, el color normal de la AppBar
        title: Text('Notas'),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, taskProv, child) {
              return IconButton(
                icon: Icon(
                  taskProv.focusMode ? Icons.do_not_disturb_on : Icons.do_not_disturb_off,
                  // CAMBIO CLAVE AQUÍ: Color del icono de enfoque
                  color: isDarkMode ? Colors.black : Colors.white, // Negro en modo oscuro, blanco en modo claro
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
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          // Los colores del texto de las pestañas se definen en main.dart
          // a través de TabBarThemeData.
        ),
      ),
      drawer: AppDrawer(
        darkMode: widget.darkMode,
        onThemeChanged: widget.onThemeChanged,
        onLogout: () {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Sesión cerrada')));
        },
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProv, child) {
          final focusMode = taskProv.focusMode;
          return Column(
            children: [
              if (focusMode) // Mensaje del modo enfoque con colores derivados del primary del tema
                Container(
                  width: double.infinity,
                  color: colorScheme.primary.withOpacity(0.2), // Fondo más claro
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Modo Enfoque activado — Notificaciones silenciadas',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Texto en blanco
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tabName) {
                    final filteredTasks = _filterTasks(taskProv.tasks, tabName);

                    if (filteredTasks.isEmpty) {
                      return Center(
                        child: Text('No hay tareas en "$tabName".'),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(12),
                      itemCount: filteredTasks.length,
                      itemBuilder: (ctx, i) {
                        final t = filteredTasks[i];
                        final bool done = t.isDone;

                        final cardColor = done
                            ? (isDarkMode
                                ? Colors.green.shade900
                                : (focusMode ? Colors.grey.shade200 : Colors.green.shade50))
                            : theme.cardColor;

                        final doneTextColor = (done
                                ? (isDarkMode
                                    ? Colors.white.withOpacity(0.65)
                                    : (focusMode ? Colors.grey.shade700 : Colors.green.shade900))
                                : (theme.textTheme.bodyMedium?.color ??
                                    Colors.black));

                        final doneSubtitleColor = (done
                                ? (isDarkMode
                                    ? Colors.white54
                                    : (focusMode ? Colors.grey.shade600 : Colors.green.shade900?.withOpacity(0.7)))
                                : (theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.7) ??
                                    Colors.grey));

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: TaskItem(
                            t: t,
                            done: done,
                            cardColor: cardColor ?? Colors.white,
                            doneTextColor: doneTextColor ?? Colors.green,
                            doneSubtitleColor: doneSubtitleColor ?? Colors.green,
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}