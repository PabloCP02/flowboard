import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  // Atributo que representa el URL base del backend
  final String baseURL = 'http://192.168.100.56:8000/api';

  // Método registro de usuarios
  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse("$baseURL/register"),
      headers: {"Content-Type":"application/json"},
      body: jsonEncode(user.toJson())
    );
    return response.statusCode == 201;
  }

  // Método login del usuario
  Future<bool> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$baseURL/login'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print(data); //
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("token", data["token"]);
    await prefs.setString("nombres", data["usuario"]["nombres"]); // 👈 Aquí guardas "Pedrito"

    return true;
  }

  return false;
}

  // Método para cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }
}