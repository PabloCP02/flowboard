import 'package:flutter/material.dart';
//Importar las clases de todas las pantallas a usar
import 'screens/login_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Eliminar la etiqueta debug
      debugShowCheckedModeBanner: false,
      title: 'App de productos',
      //Personalizar el theme de las pantallas de aplicación
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        
      ),
      //Hacer uso del método de rutas para redireccionar a diferentes pantallas
      initialRoute: '/',
      routes: {'/': (context) => const LoginScreen()},
    );
  }
}
