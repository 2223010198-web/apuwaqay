import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? '';
      _dniController.text = prefs.getString('userDni') ?? '';
      _phoneController.text = prefs.getString('userPhone') ?? '';
      _addressController.text = prefs.getString('userAddress') ?? '';
    });
  }

  void _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userPhone', _phoneController.text);
    await prefs.setString('userAddress', _addressController.text);


    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil Actualizado")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajustes de Perfil")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nombre Completo", border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _dniController, decoration: const InputDecoration(labelText: "DNI (Lectura)", enabled: false, border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Celular", border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _addressController, decoration: const InputDecoration(labelText: "Dirección de Vivienda (Opcional)", border: OutlineInputBorder())),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _saveProfile,
            child: const Text("Guardar Datos"),
          )
        ],
      ),
    );
  }
}