import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modals/nuevo_proyecto_modal.dart';
import '../services/proyecto_service.dart';
import 'insertImage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nombreUsuario = '';
  int? usuarioId;
  Map<String, List<dynamic>> proyectosAgrupados = {}; // clave: categoría

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYProyectos();
  }

  Future<void> _cargarUsuarioYProyectos() async {
    final prefs = await SharedPreferences.getInstance();
    final nombre = prefs.getString('nombres') ?? 'Bienvenid@';
    print('Proyectos agrupados: $proyectosAgrupados');

    setState(() {
      nombreUsuario = nombre;
      print('Proyectos agrupados: $proyectosAgrupados');
    });

    try {
      final proyectos = await ProyectoService().obtenerProyectosAgrupados();
      setState(() {
        proyectosAgrupados = proyectos;
      });
    } catch (e) {
      debugPrint("Error al cargar proyectos: $e");
    }
  }

  void _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
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
                DropdownMenuItem(value: 'logout', child: Text('Cerrar sesión')),
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
            Expanded(
              child: ListView(
                children:
                    proyectosAgrupados.entries.map((entry) {
                      final categoria = entry.key;
                      final proyectos = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoria,
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'Comfortaa',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                proyectos.map((proyecto) {
                                  return _buildProyectoCard(proyecto);
                                }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                final resultado = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => NuevoProyectoModal(),
                );

                // Si el modal devolvió true (es decir, se creó un nuevo proyecto)
                if (resultado == true) {
                  await _cargarUsuarioYProyectos(); // recargar los proyectos desde el backend
                }
              },

              child: const Text("+ Nuevo"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProyectoCard(dynamic proyecto) {
    final imageUrl = proyecto['imagen'] ?? '';
    final nombre = proyecto['nombre'] ?? 'Sin nombre';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsertImage(proyecto: proyecto),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              image:
                  imageUrl.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                      : const DecorationImage(
                        image: AssetImage('assets/images/placeholder.png'),
                        fit: BoxFit.cover,
                      ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 100,
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
