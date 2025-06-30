import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override@override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final nombres = TextEditingController();
  final apellidoPaterno = TextEditingController();
  final apellidoMaterno = TextEditingController();
  final correo = TextEditingController();
  final password = TextEditingController();
  final confirmarPassword = TextEditingController();

  bool isLoading = false;

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  void showDialogMessage(String title, String message,
      {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isSuccess) {
                  Navigator.pushReplacementNamed(context, "/");
                }
              },
              child: const Text("OK"))
        ],
      ),
    );
  }

  void register() async {
    // Validaciones básicas
    if (nombres.text.isEmpty ||
        apellidoPaterno.text.isEmpty ||
        apellidoMaterno.text.isEmpty ||
        correo.text.isEmpty ||
        password.text.isEmpty ||
        confirmarPassword.text.isEmpty) {
      showError("Todos los campos son obligatorios.");
      return;
    }

    if (password.text != confirmarPassword.text) {
      showError("Las contraseñas no coinciden.");
      return;
    }

    final user = User(
      nombres: nombres.text.trim(),
      apellidoPaterno: apellidoPaterno.text.trim(),
      apellidoMaterno: apellidoMaterno.text.trim(),
      correo: correo.text.trim(),
      password: password.text.trim(),
      confirmarPassword: confirmarPassword.text.trim(),
    );

    setState(() => isLoading = true);

    final success = await AuthService().register(user);

    setState(() => isLoading = false);

    if (success) {
      showDialogMessage("Registro exitoso", "Ya puedes iniciar sesión", isSuccess: true);
    } else {
      showDialogMessage("Fallo al registrar", "No se pudo registrar el usuario.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 150),
            const SizedBox(height: 40),
            TextField(
              controller: nombres,
              decoration: const InputDecoration(
                labelText: 'Nombres',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: apellidoPaterno,
              decoration: const InputDecoration(
                labelText: 'Apellido paterno',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: apellidoMaterno,
              decoration: const InputDecoration(
                labelText: 'Apellido materno',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: correo,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmarPassword,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Registrarse'),
                  ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: '¿Ya tienes una cuenta? ',
                style: const TextStyle(color: Colors.black),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/");
                      },
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
