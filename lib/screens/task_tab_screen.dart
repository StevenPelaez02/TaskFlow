import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/task_item.dart';
import '../widgets/app_drawer.dart';

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
    final taskProv = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      drawer: AppDrawer(
        darkMode: widget.darkMode,
        onThemeChanged: widget.onThemeChanged,
        onLogout: () {
          // Aquí puedes cerrar sesión o navegar a login.
          Navigator.of(context).pop(); // Cierra el drawer
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Sesión cerrada')));
        },
      ),
      body: TabBarView(
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
                  ? (theme.brightness == Brightness.dark
                      ? Colors.green[900]
                      : Colors.green[50])
                  : theme.cardColor;
              final doneTextColor = (done
                      ? (theme.brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.65)
                          : Colors.green[900])
                      : (theme.textTheme.bodyMedium?.color ??
                          Colors.black));
              final doneSubtitleColor = (done
                      ? (theme.brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.green[900]?.withOpacity(0.7))
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
