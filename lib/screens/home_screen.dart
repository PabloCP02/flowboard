import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nuevo_proyecto_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nombreUsuario = '';

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('nombres') ?? 'Bienvenid@';
    });
  }

  void _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia token y datos guardados
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          nombreUsuario,
          style: const TextStyle(
            fontSize: 24,
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon: const Icon(Icons.account_circle, color: Colors.black),
              onChanged: (value) {
                if (value == 'logout') {
                  _cerrarSesion();
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'logout',
                  child: Text('Cerrar sesión'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Proyectos',
              style: TextStyle(fontSize: 20, fontFamily: 'Comfortaa'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildImageBox('assets/images/moodboard.jpg'),
                _buildImageBox('assets/images/moodboard.jpg'),
                _buildImageBox('assets/images/moodboard.jpg'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Referencias',
              style: TextStyle(fontSize: 20, fontFamily: 'Comfortaa'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildImageBox('assets/images/moodboard.jpg'),
                const SizedBox(width: 15),
                _buildImageBox('assets/images/moodboard.jpg'),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) =>  NuevoProyectoModal(),
                );
              },
              child: const Text("+ Nuevo"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(String imagePath) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
    );
  }
}
