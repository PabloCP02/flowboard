import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NuevoProyectoModal extends StatefulWidget {
  @override
  _NuevoProyectoModalState createState() => _NuevoProyectoModalState();
}

class _NuevoProyectoModalState extends State<NuevoProyectoModal> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController nuevaCategoriaController =
      TextEditingController();

  List<dynamic> categorias = [];
  String? categoriaSeleccionada;
  int? usuarioId;
  String? token;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      usuarioId = prefs.getInt('usuario_id');
      token = prefs.getString('token');

      if (usuarioId != null && token != null) {
        final url = Uri.parse('http://192.168.1.40:8000/api/categorias');
        print('Intentando obtener categorías de: $url');
        
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        
        print('Respuesta categorías: ${response.statusCode}');
        print('Cuerpo categorías: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          setState(() {
            categorias = data;
          });
        } else {
          print('Error al cargar categorías: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }

  Future<void> _guardarCategoria() async {
    try {
      final nombreCategoria = nuevaCategoriaController.text.trim();
      if (nombreCategoria.isEmpty || usuarioId == null || token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa todos los campos')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.40:8000/api/categorias'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'nombre': nombreCategoria, 'IDDeUsuario': usuarioId}),
      );

      if (response.statusCode == 201) {
        nuevaCategoriaController.clear();
        _cargarCategorias();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría creada exitosamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear categoría: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error al guardar categoría: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  Future<void> _guardarProyecto() async {
    try {
      print('Iniciando _guardarProyecto');
      final nombre = nombreController.text.trim();
      final descripcion = descripcionController.text.trim();

      print('Nombre: $nombre');
      print('Descripción: $descripcion');
      print('Usuario ID: $usuarioId');
      print('Token: ${token != null ? "Presente" : "Ausente"}');
      print('Categoría seleccionada: $categoriaSeleccionada');

      if (nombre.isEmpty || usuarioId == null || token == null) {
        print('Validación fallida - campos vacíos');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor completa el nombre del proyecto')),
        );
        return;
      }

      final url = Uri.parse('http://192.168.1.40:8000/api/crear_proyecto');
      print('Intentando crear proyecto en: $url');

      final body = jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'IDDeUsuario': usuarioId,
        'IDDeCategoria':
            categoriaSeleccionada != null
                ? int.parse(categoriaSeleccionada!)
                : null,
      });
      
      print('Body del request: $body');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Proyecto creado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proyecto creado exitosamente')),
        );
        Navigator.pop(context, true); // Regresa al Home indicando que se creó uno nuevo
      } else {
        print('Error al crear proyecto: ${response.statusCode}');
        print('Detalles del error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error del servidor (${response.statusCode}). Revisa los logs del backend.'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error al guardar proyecto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Text(
              "+ Nuevo Proyecto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nuevaCategoriaController,
                    decoration: const InputDecoration(
                      labelText: "Crear nueva categoría",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _guardarCategoria,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Guardar"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Categorías",
                border: OutlineInputBorder(),
              ),
              value: categoriaSeleccionada,
              items:
                  categorias.map<DropdownMenuItem<String>>((categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria['IDDeCategoria'].toString(),
                      child: Text(categoria['nombre']),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  categoriaSeleccionada = value;
                });
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _guardarProyecto,
              child: const Text("Crear Proyecto"),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
