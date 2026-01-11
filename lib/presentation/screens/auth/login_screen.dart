import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(); // Nuevo
  bool _isLoading = false;
  bool _codeSent = false; // Para saber si ya enviamos el SMS
  final TextEditingController _otpController = TextEditingController(); // Código SMS

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isRegistered') == true && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  // Simular envío de SMS
  void _sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simular delay de red
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
        _codeSent = true; // Mostrar campo de código
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Código enviado: 1234 (Simulado)")),
        );
      }
    }
  }

  void _verifyAndLogin() async {
    if (_otpController.text == "1234") { // Validación simple simulada
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userDni', _dniController.text);
      await prefs.setString('userPhone', _phoneController.text);
      await prefs.setBool('isRegistered', true);

      // Valores por defecto para SOS
      await prefs.setBool('sos_enabled', true);
      await prefs.setBool('sos_auto_send', false);
      await prefs.setBool('sos_realtime', false);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código incorrecto"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera igual (resumida para ahorrar espacio visual)
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFFCF0A2C),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo.png', width: 70, height: 70),
                    const SizedBox(height: 10),
                    const Text("APU WAQAY", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const Text("Registro de Usuario", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_codeSent) ...[
                      // PASO 1: DATOS
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDeco("Nombre Completo", Icons.person),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _dniController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDeco("DNI", Icons.badge),
                        validator: (v) => v!.length != 8 ? 'DNI inválido' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDeco("Celular", Icons.phone),
                        validator: (v) => v!.length < 9 ? 'Celular inválido' : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendVerificationCode,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCF0A2C)),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("VERIFICAR NÚMERO", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ] else ...[
                      // PASO 2: CÓDIGO SMS
                      const Text("Se envió un SMS a tu número.", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, letterSpacing: 5),
                        decoration: _inputDeco("Código SMS (1234)", Icons.lock_clock),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _verifyAndLogin,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text("CONFIRMAR Y ENTRAR", style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}