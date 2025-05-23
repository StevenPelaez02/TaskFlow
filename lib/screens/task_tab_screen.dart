// lib/screens/task_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Importar DateFormat si se usa directamente aquí
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_item.dart'; // Asegúrate de que TaskItem esté importado
import '../widgets/app_drawer.dart'; // Asegúrate de que AppDrawer esté importado
import '../utils/priority_helper.dart'; // Asegúrate de que PriorityHelper esté importado

class TaskTabScreen extends StatefulWidget {
  const TaskTabScreen({super.key});

  @override
  State<TaskTabScreen> createState() => _TaskTabScreenState();
}

class _TaskTabScreenState extends State<TaskTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Todas', 'Casa', 'Trabajo', 'Estudios', 'Personal'];

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
    final String currentTabCategory = _tabs[_tabController.index];
    final String assignedCategory = (currentTabCategory == 'Todas') ? 'Personal' : currentTabCategory;

    showDialog(
      context: context,
      builder: (ctx) => AddTaskDialog(
        initialCategory: assignedCategory,
      ),
    );
  }

  List<Task> _filterTasks(List<Task> tasks, String tabCategory) {
    if (tabCategory == 'Todas') {
      return tasks;
    }
    return tasks.where((task) => task.category == tabCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final taskProv = Provider.of<TaskProvider>(context);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final tasks = taskProv.tasks;
    final focusMode = taskProv.focusMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: const Text('TaskFlow'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              focusMode ? Icons.self_improvement : Icons.sunny,
              color: theme.appBarTheme.foregroundColor,
            ),
            tooltip: 'Modo Enfoque',
            onPressed: () {
              taskProv.toggleFocusMode();
              final snackMsg = taskProv.focusMode
                  ? 'Modo Enfoque activado.'
                  : 'Modo Enfoque desactivado.';
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(snackMsg),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      drawer: AppDrawer(
        onLogout: () async {
          await authProv.logout();
          Navigator.of(context).pop();
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          final filteredTasks = _filterTasks(tasks, tab);
          return filteredTasks.isEmpty
              ? const Center(child: Text('No hay tareas en esta categoría.'))
              : ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final t = filteredTasks[index];
              final done = t.isDone;

              // Asegurarse de que cardColor nunca sea nulo al pasarlo a TaskItem
              final Color cardColor = done
                  ? (theme.brightness == Brightness.dark
                  ? (Colors.green[900] ?? Colors.green.shade800) // Proporcionar un fallback no nulo
                  : (Colors.green[50] ?? Colors.green.shade100))
                  : (theme.cardColor ?? Colors.white); // Proporcionar un fallback no nulo

              final Color doneTextColor = (done
                  ? (theme.brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.65)
                  : (Colors.green[900] ?? Colors.green.shade800))
                  : (theme.textTheme.bodyMedium?.color ?? Colors.black));

              final Color doneSubtitleColor = (done
                  ? (theme.brightness == Brightness.dark
                  ? Colors.white54
                  : (Colors.green[900]?.withOpacity(0.7) ?? Colors.green.shade800.withOpacity(0.7)))
                  : (theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ??
                  Colors.grey));

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: TaskItem(
                  t: t,
                  done: done,
                  cardColor: cardColor, // Ya es Color, no Color?
                  doneTextColor: doneTextColor,
                  doneSubtitleColor: doneSubtitleColor,
                ),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}