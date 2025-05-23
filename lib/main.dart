// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/task_tab_screen.dart';
import 'models/task.dart';
import 'screens/splash_screen.dart';

// Modificar main para inicializar Hive de forma asíncrona
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive.init solo necesita hacerse una vez y NO debe ser await si los providers lo hacen
  // Si Hive.init necesita path_provider, entonces sí necesita await aquí.
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Registrar los adaptadores de Task y Priority. Esto es síncrono.
  Hive.registerAdapter(PriorityAdapter());
  Hive.registerAdapter(TaskAdapter());

  // Ahora, los providers se encargarán de abrir sus respectivas cajas.
  // El FutureBuilder en MyApp solo necesita esperar que Hive.init y los adaptadores estén listos.

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Ya no necesitamos un Future explícito para Hive.openBox aquí,
  // ya que los proveedores lo manejan. El splash screen podría mostrarse
  // solo por un momento mientras Hive.init se completa.

  @override
  Widget build(BuildContext context) {
    // Si Hive.init() ya se hizo en el main, podemos quitar el FutureBuilder aquí.
    // Pero si queremos una splash screen mientras los proveedores inicializan sus cajas,
    // podemos usar un Future.delayed o un Future.wait en los _initHiveBox de los providers.
    // Por simplicidad, y para mantener la splash, haremos que el FutureBuilder espere
    // un pequeño retraso, asumiendo que los providers están cargando.

    return FutureBuilder<void>(
      // Este Future.delayed es solo para asegurar que la splash screen se vea un poco.
      // En una app real, aquí esperarías otras inicializaciones de servicios.
      future: Future.delayed(const Duration(milliseconds: 500)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Text('Error de inicialización: ${snapshot.error}'),
                ),
              ),
            );
          } else {
            // Una vez que el "retraso" y Hive.init (en main) estén listos, construimos la app.
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => TaskProvider()),
                ChangeNotifierProvider(create: (_) => ThemeProvider()),
              ],
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
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
                      tabBarTheme: TabBarThemeData(
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
                      tabBarTheme: TabBarThemeData(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.black.withOpacity(0.7),
                        indicatorColor: Colors.black,
                      ),
                    ),
                    themeMode: themeProvider.themeMode,
                    home: const TaskTabScreen(),
                  );
                },
              ),
            );
          }
        } else {
          return const SplashScreen();
        }
      },
    );
  }
}