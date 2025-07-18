import 'package:flutter/material.dart';
import 'insertimage.dart';

class NuevoProyectoModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom:
            MediaQuery.of(
              context,
            ).viewInsets.bottom, // Ajusta el modal al teclado
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize
                .min, // Hace que el modal solo ocupe el espacio necesario
        children: [
          SizedBox(height: 10),
          Text(
            "+ Nuevo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          TextField(
            decoration: InputDecoration(
              labelText: "Nombre",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Crear nueva categoría",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InsertImage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Crear'),
              ),
            ],
          ),
          SizedBox(height: 10),
          DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: "Categorías",
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(child: Text("Categoría 1"), value: "1"),
              DropdownMenuItem(child: Text("Categoría 2"), value: "2"),
            ],
            onChanged: (value) {},
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
