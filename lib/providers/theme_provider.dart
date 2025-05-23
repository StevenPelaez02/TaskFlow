import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) return false;
    return _themeMode == ThemeMode.dark;
  }

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  // Nuevo método para sincronizar con el brillo del sistema
  void updatePlatformBrightness(Brightness platformBrightness) {
    if (_themeMode == ThemeMode.system) {
      if (platformBrightness == Brightness.dark) {
        // No cambiamos _themeMode porque es system, pero podemos notificar si quieres
        notifyListeners();
      } else if (platformBrightness == Brightness.light) {
        notifyListeners();
      }
    }
  }
}
