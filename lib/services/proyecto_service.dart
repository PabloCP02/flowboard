import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProyectoService {
  final String baseURL = 'http://192.168.1.40:8000/api';

  Future<Map<String, List<dynamic>>> obtenerProyectosAgrupados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getInt('usuario_id');

      if (usuarioId == null || token == null) {
        throw Exception("Usuario no autenticado.");
      }

      final url = Uri.parse('$baseURL/usuarios/$usuarioId/proyectos');
      print('Intentando obtener proyectos de: $url');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Respuesta proyectos: ${response.statusCode}');
      print('Cuerpo proyectos: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final raw = data['proyectos'] as Map<String, dynamic>;
        final Map<String, List<dynamic>> agrupados = {};

        raw.forEach((categoria, proyectos) {
          agrupados[categoria] = List<dynamic>.from(proyectos);
        });

        return agrupados;
      } else {
        throw Exception('Error al obtener proyectos (${response.statusCode})');
      }
    } catch (e) {
      print('Error en obtenerProyectosAgrupados: $e');
      throw Exception('Error al obtener proyectos: $e');
    }
  }

  Future<bool> crearProyecto({
    required String nombre,
    required String descripcion,
    int? categoriaId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioId = prefs.getInt('usuario_id');

    if (usuarioId == null || token == null) {
      throw Exception("Usuario no autenticado.");
    }

    print('Intentando crear proyecto en: ${Uri.parse('$baseURL/crear_proyecto')}');
    print('Body del request: ${json.encode({
      'IDDeUsuario': usuarioId,
      'nombre': nombre,
      'descripcion': descripcion,
      'IDDeCategoria': categoriaId,
    })}');

    final response = await http.post(
      Uri.parse('$baseURL/crear_proyecto'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'IDDeUsuario': usuarioId,
        'nombre': nombre,
        'descripcion': descripcion,
        'IDDeCategoria': categoriaId,
      }),
    );

    print('Respuesta del servidor: ${response.statusCode}');
    print('Cuerpo de la respuesta: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Error al crear proyecto: ${response.statusCode}');
      print('Detalles del error: ${response.body}');
      return false;
    }
  }
}
