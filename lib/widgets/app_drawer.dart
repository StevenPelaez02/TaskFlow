// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar Provider
import '../providers/theme_provider.dart'; // Importar ThemeProvider

class AppDrawer extends StatelessWidget {
  // ELIMINAR estas propiedades si están presentes:
  // final bool darkMode;
  // final ValueChanged<bool> onThemeChanged;

  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    // ELIMINAR estas líneas del constructor si están presentes:
    // required this.darkMode,
    // required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener una referencia al ThemeProvider directamente aquí
    final themeProv = Provider.of<ThemeProvider>(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, // Usar el color primario del tema
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 60, color: Colors.white), // Icono blanco para contraste
                SizedBox(height: 10),
                Text('Mi Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('usuario@correo.com', style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Modo oscuro'),
            trailing: Switch(
              // Usar el estado de themeProv directamente
              value: themeProv.themeMode == ThemeMode.dark,
              // Usar el método de themeProv para cambiar el tema
              onChanged: themeProv.toggleTheme,
            ),
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Salir', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
          SizedBox(height: 8), // Un pequeño espacio al final
        ],
      ),
    );
  }
}