// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthProvider extends ChangeNotifier {
  static const String _authBoxName = 'authSettings';
  static const String _usersKey = 'registeredUsers'; // Clave para el mapa de usuarios
  static const String _currentUserEmailKey = 'currentUserEmail'; // Clave para el email del usuario logueado

  late Box _authBox;
  String? _currentUserEmail; // Almacena el email del usuario actualmente logueado

  bool get isLoggedIn => _currentUserEmail != null;
  String? get currentUserEmail => _currentUserEmail;

  AuthProvider() {
    _initAuthBox();
  }

  Future<void> _initAuthBox() async {
    _authBox = await Hive.openBox(_authBoxName);
    _currentUserEmail = _authBox.get(_currentUserEmailKey); // Carga el último usuario logueado
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final Map<dynamic, dynamic>? registeredUsers = _authBox.get(_usersKey);

    if (registeredUsers != null && registeredUsers[email] == password) {
      _currentUserEmail = email;
      await _authBox.put(_currentUserEmailKey, email); // Guarda el email del usuario logueado
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    // Cargar usuarios existentes o crear un mapa vacío
    Map<dynamic, dynamic> registeredUsers = _authBox.get(_usersKey) ?? {};

    // Verificar si el email ya está registrado
    if (registeredUsers.containsKey(email)) {
      return false; // Email ya existe
    }

    // Registrar nuevo usuario
    registeredUsers[email] = password;
    await _authBox.put(_usersKey, registeredUsers);

    // Iniciar sesión automáticamente después del registro
    _currentUserEmail = email;
    await _authBox.put(_currentUserEmailKey, email); // Guarda el email del usuario logueado
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _currentUserEmail = null;
    await _authBox.delete(_currentUserEmailKey); // Elimina el email del usuario logueado
    notifyListeners();
    // No cerramos la caja de tareas aquí, la cerraremos en TaskProvider.
  }
}