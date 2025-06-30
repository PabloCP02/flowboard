import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InsertImage extends StatefulWidget {
  const InsertImage({super.key});

  @override
  State<InsertImage> createState() => _InsertImageState();
}

class _InsertImageState extends State<InsertImage> {
  File? imageFile;
  final ImagePicker _picker = ImagePicker();

  // final _audioRecorder = Record();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  final TextEditingController _dibujoController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  // ------------------------------------------------------
  // --------------------- Compartir ----------------------
  // ------------------------------------------------------
  Future<void> _showOptionsCompartir(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Compartir:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Segundo TextFormField para el contenido (más grande)
                TextFormField(
                  controller: _linkController, // Controlador para el contenido
                  decoration: const InputDecoration(
                    labelText: 'https://linkparacompartir.flowboard.com',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5, // Esto hace que el campo sea más grande
                  textAlign: TextAlign.center, // Centra el texto en el campo
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa un URL";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
          actions: <Widget>[
            // Botón "Compartir link" con fondo negro y letras blancas
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Fondo negro
              ),
              child: const Text(
                'Compartir',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () {
                // Acción cuando el botón es presionado
                if (_linkController.text.isNotEmpty) {
                  print("Compartir link: ${_linkController.text}");
                  Navigator.of(context).pop();
                }
              },
              // child: const Text('Compartir link'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------
  // -------------------- Abrir galeria ---------------------
  // ------------------------------------------------------
  _openGallery(BuildContext context) async {
    final XFile? picture = await _picker.pickImage(source: ImageSource.gallery);
    if (picture != null) {
      setState(() {
        imageFile = File(picture.path);
      });
    }
    Navigator.of(context).pop();
  }

  // ------------------------------------------------------
  // ------------------- Abrir camara ---------------------
  // ------------------------------------------------------
  _openCamera(BuildContext context) async {
    final XFile? picture = await _picker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      setState(() {
        imageFile = File(picture.path);
      });
    }
    Navigator.of(context).pop();
  }

  // ------------------------------------------------------
  // -------------------- Abrir video ---------------------
  // ------------------------------------------------------
  _openVideoCamera(BuildContext context) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() {
        imageFile = File(video.path);
      });
    }
    Navigator.of(context).pop();
  }

  // ------------------------------------------------------
  // ------------------- Iniciar audio --------------------
  // ------------------------------------------------------
  // _openAudioRecorder(BuildContext context) async {
  //   if (await _audioRecorder.hasPermission()) {
  //     String path = '/storage/emulated/0/Download/audio_record.m4a'; // Ruta de almacenamiento
  //     await _audioRecorder.start(
  //       path: path,
  //       encoder: AudioEncoder.aacLc,
  //       bitRate: 128000,
  //       samplingRate: 44100,
  //     );
  //     // Puedes mostrar un mensaje o UI indicando que está grabando
  //     print("Grabando audio...");
  //   }
  // }

  // ------------------------------------------------------
  // ------------------ Detener audio ---------------------
  // ------------------------------------------------------
  // _stopAudioRecording() async {
  //   final path = await _audioRecorder.stop();
  //   if (path != null) {
  //     setState(() {
  //       audioFile = File(path);
  //     });
  //     print("Audio guardado en: $path");
  //   }
  // }

  // ------------------------------------------------------
  // ------------- Desplegar opciones agregar--------------
  // ------------------------------------------------------
  Future<void> _showOptions(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agregar:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Opción de agregar texto
                GestureDetector(
                  onTap:
                      () => _showOptionsText(
                        context,
                      ), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.text_fields), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Texto"), // Texto
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Opción de agregar imagen
                GestureDetector(
                  onTap:
                      () => _showChoiceDialog(
                        context,
                      ), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.photo_library), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Imagen"), // Imagen
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Opción de agregar audio
                GestureDetector(
                  onTap:
                      () => _showOptionsAudio(
                        context,
                      ), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.music_note), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Audio"), // Audio
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Opción de agregar video
                GestureDetector(
                  onTap:
                      () => _showOptionsVideo(
                        context,
                      ), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.video_call), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Video"), // Video
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Opción de agregar dibujo
                GestureDetector(
                  onTap:
                      () => _showOptionsDraw(
                        context,
                      ), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.draw), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Dibujo"), // Dibujo
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Opción de agregar URL
                GestureDetector(
                  onTap:
                      () => _showOptionsLink(
                        context,
                      ), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.link), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Enlace"), // URL
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------
  // ------------------------ Text ------------------------
  // ------------------------------------------------------
  Future<void> _showOptionsText(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agregar texto:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Primer TextFormField para el título
                TextFormField(
                  controller: _tituloController, // Controlador para el título
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa un título";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Segundo TextFormField para el contenido (más grande)
                TextFormField(
                  controller:
                      _contenidoController, // Controlador para el contenido
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5, // Esto hace que el campo sea más grande
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa un contenido";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
          actions: <Widget>[
            // Puedes agregar aquí los botones si lo necesitas
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aquí puedes procesar los datos ingresados
                if (_tituloController.text.isNotEmpty &&
                    _contenidoController.text.isNotEmpty) {
                  // Procesar el texto
                  print("Título: ${_tituloController.text}");
                  print("Contenido: ${_contenidoController.text}");
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------
  // ------------------- Camara/Galeria -------------------
  // ------------------------------------------------------
  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cargar imagen desde:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap:
                      () =>
                          _openGallery(context), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.photo_library), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Galería"), // Texto
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap:
                      () => _openCamera(context), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.camera_alt_outlined), // Icono de la cámara
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Cámara"), // Texto
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------
  // ------------------- Video/Galeria -------------------
  // ------------------------------------------------------
  Future<void> _showOptionsVideo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cargar video desde:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap:
                      () =>
                          _openGallery(context), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.photo_library), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Galería"), // Texto
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap:
                      () => _openVideoCamera(
                        context,
                      ), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.camera), // Icono de la cámara
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Video cámara"), // Texto
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------
  // ------------------- Audio/Galeria -------------------
  // ------------------------------------------------------
  Future<void> _showOptionsAudio(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cargar audio desde:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  onTap:
                      () =>
                          _openGallery(context), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.photo_library), // Icono de galeria
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Galería"), // Texto
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap:
                      () => _openCamera(context), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.music_note), // Icono de la cámara
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Grabar audio"), // Texto
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------
  // ------------------------ Draw ------------------------
  // ------------------------------------------------------
  Future<void> _showOptionsDraw(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agregar dibujo:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Segundo TextFormField para el contenido (más grande)
                TextFormField(
                  controller:
                      _dibujoController, // Controlador para el contenido
                  decoration: const InputDecoration(
                    labelText: 'Dibujo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 10, // Esto hace que el campo sea más grande
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa un dibujo";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
          actions: <Widget>[
            // Puedes agregar aquí los botones si lo necesitas
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aquí puedes procesar los datos ingresados
                if (_dibujoController.text.isNotEmpty) {
                  // Procesar el dibujo
                  print("Título: ${_dibujoController.text}");
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------
  // ------------------------ Link ------------------------
  // ------------------------------------------------------
  Future<void> _showOptionsLink(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Agregar URL:"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Segundo TextFormField para el contenido (más grande)
                TextFormField(
                  controller: _linkController, // Controlador para el contenido
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5, // Esto hace que el campo sea más grande
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Por favor ingresa un URL";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
          actions: <Widget>[
            // Puedes agregar aquí los botones si lo necesitas
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aquí puedes procesar los datos ingresados
                if (_linkController.text.isNotEmpty) {
                  // Procesar el dibujo
                  print("Título: ${_linkController.text}");
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return const Text("");
    } else {
      return Image.file(imageFile!, height: 400);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Project"),
        centerTitle: true, // Centra el título
        actions: [
          // Opción compartir
          IconButton(
            icon: const Icon(Icons.share), // Ícono de compartir
            onPressed:
                () =>
                    _showOptionsCompartir(context), // Acción al tocar el ícono
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _decideImageView(),
            //   ElevatedButton(
            //     onPressed: () => _showChoiceDialog(context),
            //     child: const Text("Selecciona la imagen"),
            //   ),
          ],
        ),
      ),
      // Pie de página - Menú de opciones
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: SizedBox(
          height: 80, // Aumentar la altura del BottomAppBar
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _showOptions(context),
                child: _footerItem(Icons.add_circle, "Agregar"),
              ),
              _footerItem(Icons.open_with, "Mover"),
              _footerItem(Icons.copy, "Copiar"),
              _footerItem(Icons.paste, "Pegar"),
              _footerItem(Icons.delete, "Eliminar"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: Colors.indigo[900],
          ), // Reducir tamaño del icono
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
