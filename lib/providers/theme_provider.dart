// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'appSettings';
  static const String _themeKey = 'darkMode';

  late Box _settingsBox; // Será inicializada asíncronamente

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _initHiveBox(); // Iniciar la carga de la caja de forma asíncrona
  }

  Future<void> _initHiveBox() async {
    // Si la caja ya está abierta, Hive.openBox simplemente devolverá la instancia existente.
    _settingsBox = await Hive.openBox(_themeBoxName);
    _loadThemeFromBox(); // Cargar el tema una vez que la caja esté lista
  }

  // Ahora, este método es síncrono ya que es llamado después de que _settingsBox es inicializado
  void _loadThemeFromBox() {
    // Solo cargar si la caja está abierta
    if (_settingsBox.isOpen) {
      final savedMode = _settingsBox.get(_themeKey, defaultValue: null);

      if (savedMode != null) {
        if (savedMode == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (savedMode == 'light') {
          _themeMode = ThemeMode.light;
        } else {
          _themeMode = ThemeMode.system;
        }
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners(); // Notifica a la UI que el tema ha cargado/inicializado
    }
  }

  void toggleTheme(bool isOn) {
    if (_settingsBox.isOpen) { // Asegurarse de que la caja esté abierta antes de escribir
      _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
      _settingsBox.put(_themeKey, isOn ? 'dark' : 'light');
      notifyListeners();
    }
  }

  void setSystemTheme() {
    if (_settingsBox.isOpen) { // Asegurarse de que la caja esté abierta antes de escribir
      _themeMode = ThemeMode.system;
      _settingsBox.put(_themeKey, 'system');
      notifyListeners();
    }
  }

  void updatePlatformBrightness(Brightness platformBrightness) {
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }
}