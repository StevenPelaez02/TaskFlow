// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 60, color: Colors.white),
                SizedBox(height: 10),
                Text('Mi Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  authProv.currentUserEmail ?? 'No logueado',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text('Modo oscuro'),
            trailing: Switch(
              value: themeProv.themeMode == ThemeMode.dark,
              onChanged: themeProv.toggleTheme,
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