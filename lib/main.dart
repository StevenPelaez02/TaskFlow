import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/task_tab_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'TaskFlow',
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
        home: TaskTabScreen(
          darkMode: _darkMode,
          onThemeChanged: (v) => setState(() => _darkMode = v),
        ),
      ),
    );
  }
}
