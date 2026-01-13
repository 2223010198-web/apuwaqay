import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditSosScreen extends StatefulWidget {
  const EditSosScreen({super.key});

  @override
  State<EditSosScreen> createState() => _EditSosScreenState();
}

class _EditSosScreenState extends State<EditSosScreen> {
  final _contact1Controller = TextEditingController();
  final _contact2Controller = TextEditingController();

  bool _autoSend = false;
  bool _realTime = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contact1Controller.text = prefs.getString('sos_contact_1') ?? '';
      _contact2Controller.text = prefs.getString('sos_contact_2') ?? '';
      _autoSend = prefs.getBool('sos_auto_send') ?? false;
      _realTime = prefs.getBool('sos_realtime') ?? false;
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sos_contact_1', _contact1Controller.text);
    await prefs.setString('sos_contact_2', _contact2Controller.text);
    await prefs.setBool('sos_auto_send', _autoSend);
    await prefs.setBool('sos_realtime', _realTime);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Configuración SOS Guardada")));
      Navigator.pop(context, true); // Retorna true para refrescar la vista anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar SOS"), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Destinatario Principal
          const Card(
            child: ListTile(
              leading: Icon(Icons.shield, color: Colors.indigo),
              title: Text("Destinatario Principal"),
              subtitle: Text("INDECI (Central de Emergencias)"),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Contactos Extra
          const Text("Contactos Adicionales (SMS)", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _contact1Controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Contacto 1 (Celular)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_add)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _contact2Controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: "Contacto 2 (Celular)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_add)),
          ),

          const Divider(height: 40),

          // 3. Configuraciones Avanzadas
          SwitchListTile(
            title: const Text("Envío Automático"),
            subtitle: const Text("Enviar ubicación automáticamente si hay PELIGRO de Huayco"),
            value: _autoSend,
            onChanged: (v) => setState(() => _autoSend = v),
          ),
          SwitchListTile(
            title: const Text("Ubicación en Tiempo Real"),
            subtitle: const Text("Compartir tracking en vivo en lugar de ubicación fija"),
            value: _realTime,
            onChanged: (v) => setState(() => _realTime = v),
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCF0A2C),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: const Text("GUARDAR CAMBIOS", style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }
}