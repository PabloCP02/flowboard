import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  // Atributo que representa el URL base del backend
  final String baseURL = 'http://192.168.1.40:8000/api';

  // Método registro de usuarios
  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse("$baseURL/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(user.toJson()),
    );
    return response.statusCode == 201;
  }

  // Método login del usuario
  Future<String?> login(String correo, String password) async {
    try {
      final url = Uri.parse('$baseURL/login');
      print('Intentando conectar a: $url');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'correo': correo, 'password': password}),
      );

      print('Respuesta del servidor: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final token = data['token'];
        final usuario = data['usuario'];

        if (token != null && usuario != null && usuario['IDDeUsuario'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setInt('usuario_id', usuario['IDDeUsuario']);
          await prefs.setString(
            'nombres',
            usuario['nombres'] ?? '',
          );

          return token;
        } else {
          throw Exception(
            'Datos de usuario incompletos en la respuesta del servidor',
          );
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['mensaje'] ?? 'Error al iniciar sesión (${response.statusCode})');
      }
    } catch (e) {
      print('Error en login: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}
