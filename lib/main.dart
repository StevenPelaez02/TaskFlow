// lib/main.dart
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
    // Definimos un ColorScheme con un seed color morado para el modo CLARO
    final ColorScheme lightColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, // El morado base
      brightness: Brightness.light,
    );

    // ColorScheme para el modo OSCURO, también basado en morado
    final ColorScheme darkColorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple, // Para mantener la base morada
      brightness: Brightness.dark,
    );

    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'TaskFlow',
        theme: ThemeData.light().copyWith(
          colorScheme: lightColorScheme,
          appBarTheme: AppBarTheme(
            backgroundColor: lightColorScheme.primary, // Color primario del tema
            foregroundColor: lightColorScheme.onPrimary, // Color del texto/iconos (será claro sobre morado oscuro)
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: lightColorScheme.primary,
            foregroundColor: lightColorScheme.onPrimary,
          ),
          // --- TabBarTheme para el tema CLARO ---
          tabBarTheme: TabBarThemeData(
            labelColor: Colors.white,         // Texto de la pestaña seleccionada en blanco
            unselectedLabelColor: Colors.white.withOpacity(0.7), // Texto de las no seleccionadas en blanco semitransparente
            indicatorColor: Colors.white,     // Línea indicadora en blanco
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: darkColorScheme,
          appBarTheme: AppBarTheme(
            backgroundColor: darkColorScheme.primary, // Color primario del tema oscuro
            // CAMBIO CLAVE AQUÍ: Para que el texto sea oscuro sobre el morado oscuro de la AppBar
            // Usamos un color que contraste adecuadamente pero que sea oscuro.
            // darkColorScheme.primary podría ser el morado, y necesitamos un texto oscuro.
            // Si darkColorScheme.onPrimary es blanco, lo cambiamos a un color más oscuro como Colors.black o darkColorScheme.onSurface
            foregroundColor: Colors.black, // Color para el texto del título y el icono de menú en la AppBar
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: darkColorScheme.primary,
            foregroundColor: darkColorScheme.onPrimary, // Esto puede seguir siendo blanco si el FAB es oscuro y quieres el icono claro.
          ),
          // --- TabBarTheme para el tema OSCURO ---
          tabBarTheme: TabBarThemeData(
            labelColor: Colors.black,         // Texto de la pestaña seleccionada en negro
            unselectedLabelColor: Colors.black.withOpacity(0.7), // Texto de las no seleccionadas en negro semitransparente
            indicatorColor: Colors.black,     // Línea indicadora en negro
          ),
          // Puedes personalizar más colores de la interfaz de usuario aquí
          // por ejemplo, el color de fondo general (Scaffold)
          // scaffoldBackgroundColor: darkColorScheme.background,
        ),
        themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
        home: TaskTabScreen(
          darkMode: _darkMode,
          onThemeChanged: (v) => setState(() => _darkMode = v),
        ),
      ),
    );
  }
}