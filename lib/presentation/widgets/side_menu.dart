import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app_routes.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String _userName = "Usuario";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Usuario";
    });
  }

  @override
  Widget build(BuildContext context) {

    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFCF0A2C)),
            accountName: Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            accountEmail: const Text("Usuario Verificado"),
            currentAccountPicture: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, size: 40, color: Colors.black54)),
          ),
/*
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blueGrey),
            title: const Text("Inicio"),
            // Si estamos en Home, marcamos el item como seleccionado
            selected: currentRoute == AppRoutes.home,
            onTap: () {
              // Ir al inicio y borrar historial de navegación
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
            },
          ),

          ListTile(
            leading: const Icon(Icons.history, color: Colors.blueAccent),
            title: const Text("Historial de Eventos"),
            selected: currentRoute == AppRoutes.history,
            onTap: () {
              Navigator.pop(context); // Cierra el menú
              if (currentRoute != AppRoutes.history) {
                Navigator.pushNamed(context, AppRoutes.history);
              }
            },
          ),
*/
          ListTile(
            leading: const Icon(Icons.sos, color: Colors.red),
            title: const Text("Editar SOS"),
            selected: currentRoute == AppRoutes.editSos,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != AppRoutes.editSos) {
                Navigator.pushNamed(context, AppRoutes.editSos);
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Ajustes"),
            selected: currentRoute == AppRoutes.settings,
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != AppRoutes.settings) {
                Navigator.pushNamed(context, AppRoutes.settings);
              }
            },
          ),
        ],
      ),
    );
  }
}