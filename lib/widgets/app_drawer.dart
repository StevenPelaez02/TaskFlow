import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text('Mi Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('usuario@correo.com', style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Modo oscuro'),
            trailing: Switch(
              value: darkMode,
              onChanged: onThemeChanged,
            ),
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text('Salir', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
