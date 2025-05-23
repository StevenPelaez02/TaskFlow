// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/task_tab_screen.dart';
import 'screens/auth_screen.dart';
import 'models/task.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(TaskAdapter());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) => TaskProvider(Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, previousTaskProvider) {
            return previousTaskProvider ?? TaskProvider(auth);
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final ColorScheme lightColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          );
          final ColorScheme darkColorScheme = ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          );

          return MaterialApp(
            title: 'TaskFlow',
            theme: ThemeData.light().copyWith(
              colorScheme: lightColorScheme,
              appBarTheme: AppBarTheme(
                backgroundColor: lightColorScheme.primary,
                foregroundColor: lightColorScheme.onPrimary,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: lightColorScheme.primary,
                foregroundColor: lightColorScheme.onPrimary,
              ),
              tabBarTheme: TabBarThemeData( // ¡CORRECCIÓN AQUÍ!
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                indicatorColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: darkColorScheme,
              appBarTheme: AppBarTheme(
                backgroundColor: darkColorScheme.primary,
                foregroundColor: Colors.black,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                backgroundColor: darkColorScheme.primary,
                foregroundColor: darkColorScheme.onPrimary,
              ),
              tabBarTheme: TabBarThemeData( // ¡CORRECCIÓN AQUÍ!
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black.withOpacity(0.7),
                indicatorColor: Colors.black,
              ),
            ),
            themeMode: Provider.of<ThemeProvider>(context).themeMode,
            home: authProvider.isLoggedIn
                ? Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      if (!taskProvider.isInitialized) {
                        return const SplashScreen();
                      }
                      return const TaskTabScreen();
                    },
                  )
                : const AuthScreen(),
          );
        },
      ),
    );
  }
}