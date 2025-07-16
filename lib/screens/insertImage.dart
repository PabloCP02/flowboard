import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InsertImage extends StatefulWidget {
  final Map<String, dynamic>? proyecto;
  
  const InsertImage({super.key, this.proyecto});

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

  // Lista para almacenar el contenido multimedia del proyecto
  List<Map<String, dynamic>> multimedia = [];
  bool isLoading = true;
  
  // Estado para manejar las categorías
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['Todo', 'Texto', 'Imágenes', 'Videos', 'Audio', 'Enlaces'];

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
      // Guardar la imagen en el backend
      await _guardarImagen();
    }
    // Verificar si el widget sigue activo antes de cerrar el diálogo
    if (mounted) {
      Navigator.of(context).pop();
    }
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
      // Guardar la imagen en el backend
      await _guardarImagen();
    }
    // Verificar si el widget sigue activo antes de cerrar el diálogo
    if (mounted) {
      Navigator.of(context).pop();
    }
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
      // Guardar el video en el backend
      await _guardarVideo();
    }
    // Verificar si el widget sigue activo antes de cerrar el diálogo
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  _openVideoGallery(BuildContext context) async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        imageFile = File(video.path);
      });
      // Guardar el video en el backend
      await _guardarVideo();
    }
    // Verificar si el widget sigue activo antes de cerrar el diálogo
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  _openAudioGallery(BuildContext context) async {
    final XFile? audio = await _picker.pickMedia(
      imageQuality: 100,
      requestFullMetadata: false,
    );
    if (audio != null) {
      setState(() {
        imageFile = File(audio.path);
      });
      // Guardar el audio en el backend
      await _guardarAudio();
    }
    // Verificar si el widget sigue activo antes de cerrar el diálogo
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  _openAudioRecorder(BuildContext context) async {
    // Por ahora usamos la galería para audio también
    // En el futuro se puede implementar grabación directa
    await _openAudioGallery(context);
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
              onPressed: () async {
                // Aquí puedes procesar los datos ingresados
                if (_tituloController.text.isNotEmpty &&
                    _contenidoController.text.isNotEmpty) {
                  await _guardarTexto();
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
                          _openVideoGallery(context), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.video_library), // Icono de galeria de videos
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Galería de videos"), // Texto
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
                          _openAudioGallery(context), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.audio_file), // Icono de galeria de audio
                      SizedBox(width: 8), // Espaciado entre el icono y el texto
                      Text("Galería de audio"), // Texto
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap:
                      () => _openAudioRecorder(context), // Acción al tocar el elemento
                  child: Row(
                    children: const [
                      Icon(Icons.mic), // Icono de grabación
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
              onPressed: () async {
                // Aquí puedes procesar los datos ingresados
                if (_linkController.text.isNotEmpty) {
                  await _guardarEnlace();
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

  Future<void> _guardarTexto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getInt('usuario_id');

      if (token == null || usuarioId == null || widget.proyecto == null) {
        print('Error: Token, usuario o proyecto no disponible');
        return;
      }

      final contenido = 'Título: ${_tituloController.text}\n\nContenido: ${_contenidoController.text}';

      final response = await http.post(
        Uri.parse('http://192.168.1.40:8000/api/multimedia/subir'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'IDDeProyecto': widget.proyecto!['IDDeProyecto'],
          'IDDeUsuario': usuarioId,
          'tipo': 'texto',
          'contenido': contenido,
        }),
      );

      if (response.statusCode == 201) {
        print('Texto guardado exitosamente');
        _tituloController.clear();
        _contenidoController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Texto guardado exitosamente')),
        );
        // Recargar el contenido después de guardar
        await _cargarMultimedia();
      } else {
        print('Error al guardar texto: ${response.statusCode}');
        print('Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error al guardar texto: $e');
    }
  }

  Future<void> _guardarEnlace() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getInt('usuario_id');

      if (token == null || usuarioId == null || widget.proyecto == null) {
        print('Error: Token, usuario o proyecto no disponible');
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.1.40:8000/api/multimedia/subir'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'IDDeProyecto': widget.proyecto!['IDDeProyecto'],
          'IDDeUsuario': usuarioId,
          'tipo': 'enlace',
          'contenido': _linkController.text.trim(),
        }),
      );

      if (response.statusCode == 201) {
        print('Enlace guardado exitosamente');
        _linkController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enlace guardado exitosamente')),
        );
        // Recargar el contenido después de guardar
        await _cargarMultimedia();
      } else {
        print('Error al guardar enlace: ${response.statusCode}');
        print('Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error al guardar enlace: $e');
    }
  }

  Future<void> _guardarImagen() async {
    try {
      if (imageFile == null) {
        print('Error: No hay imagen seleccionada');
        return;
      }

      print('Iniciando subida de imagen: ${imageFile!.path}');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getInt('usuario_id');

      if (token == null || usuarioId == null || widget.proyecto == null) {
        print('Error: Token, usuario o proyecto no disponible');
        print('Token: $token');
        print('Usuario ID: $usuarioId');
        print('Proyecto: ${widget.proyecto}');
        return;
      }

      print('Datos de autenticación OK');
      print('Proyecto ID: ${widget.proyecto!['IDDeProyecto']}');
      print('Usuario ID: $usuarioId');

      // Crear la solicitud multipart para subir el archivo
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.40:8000/api/multimedia/subir'),
      );

      // Agregar headers
      request.headers['Authorization'] = 'Bearer $token';
      print('Headers agregados');

      // Agregar campos
      request.fields['IDDeProyecto'] = widget.proyecto!['IDDeProyecto'].toString();
      request.fields['IDDeUsuario'] = usuarioId.toString();
      request.fields['tipo'] = 'imagen'; // Indicar explícitamente que es una imagen
      print('Campos agregados: ${request.fields}');

      // Agregar el archivo
      request.files.add(
        await http.MultipartFile.fromPath(
          'archivo',
          imageFile!.path,
        ),
      );
      print('Archivo agregado a la solicitud');

      print('Enviando solicitud...');
      // Enviar la solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Respuesta recibida: ${response.statusCode}');
      print('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Imagen guardada exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen guardada exitosamente')),
        );
        // Recargar el contenido después de guardar
        await _cargarMultimedia();
        // Solo limpiar la imagen temporal después de que todo esté bien
        setState(() {
          imageFile = null;
        });
      } else {
        print('Error al guardar imagen: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar imagen: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error al guardar imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar imagen: $e')),
      );
    }
  }

  Future<void> _guardarVideo() async {
    try {
      if (imageFile == null) {
        print('Error: No hay video seleccionado');
        return;
      }

      print('Iniciando subida de video: ${imageFile!.path}');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getInt('usuario_id');

      if (token == null || usuarioId == null || widget.proyecto == null) {
        print('Error: Token, usuario o proyecto no disponible');
        return;
      }

      // Crear la solicitud multipart para subir el archivo
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.40:8000/api/multimedia/subir'),
      );

      // Agregar headers
      request.headers['Authorization'] = 'Bearer $token';

      // Agregar campos
      request.fields['IDDeProyecto'] = widget.proyecto!['IDDeProyecto'].toString();
      request.fields['IDDeUsuario'] = usuarioId.toString();
      request.fields['tipo'] = 'video'; // Indicar explícitamente que es un video
      
      print('Campos enviados para video: ${request.fields}');

      // Agregar el archivo con nombre que indique que es video
      final fileName = imageFile!.path.split('/').last;
      final videoFileName = 'video_' + fileName;
      request.files.add(
        await http.MultipartFile.fromPath(
          'archivo',
          imageFile!.path,
          filename: videoFileName, // Forzar nombre que contenga "video"
        ),
      );

      // Enviar la solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Video guardado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video guardado exitosamente')),
        );
        // Recargar el contenido después de guardar
        await _cargarMultimedia();
        // Solo limpiar el video temporal después de que todo esté bien
        setState(() {
          imageFile = null;
        });
      } else {
        print('Error al guardar video: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar video: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error al guardar video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar video: $e')),
      );
    }
  }

  Future<void> _guardarAudio() async {
    try {
      if (imageFile == null) {
        print('Error: No hay audio seleccionado');
        return;
      }

      print('Iniciando subida de audio: ${imageFile!.path}');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final usuarioId = prefs.getInt('usuario_id');

      if (token == null || usuarioId == null || widget.proyecto == null) {
        print('Error: Token, usuario o proyecto no disponible');
        return;
      }

      // Crear la solicitud multipart para subir el archivo
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.40:8000/api/multimedia/subir'),
      );

      // Agregar headers
      request.headers['Authorization'] = 'Bearer $token';

      // Agregar campos
      request.fields['IDDeProyecto'] = widget.proyecto!['IDDeProyecto'].toString();
      request.fields['IDDeUsuario'] = usuarioId.toString();
      request.fields['tipo'] = 'audio'; // Indicar explícitamente que es un audio
      
      print('Campos enviados para audio: ${request.fields}');

      // Agregar el archivo con nombre que indique que es audio
      final fileName = imageFile!.path.split('/').last;
      final audioFileName = 'audio_' + fileName;
      request.files.add(
        await http.MultipartFile.fromPath(
          'archivo',
          imageFile!.path,
          filename: audioFileName, // Forzar nombre que contenga "audio"
        ),
      );

      // Enviar la solicitud
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Audio guardado exitosamente');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio guardado exitosamente')),
        );
        // Recargar el contenido después de guardar
        await _cargarMultimedia();
        // Solo limpiar el audio temporal después de que todo esté bien
        setState(() {
          imageFile = null;
        });
      } else {
        print('Error al guardar audio: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar audio: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error al guardar audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar audio: $e')),
      );
    }
  }

  Future<void> _cargarMultimedia() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || widget.proyecto == null) {
        print('Error: Token o proyecto no disponible');
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.40:8000/api/proyectos/${widget.proyecto!['IDDeProyecto']}/multimedia'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          multimedia = List<Map<String, dynamic>>.from(data['multimedia']);
          isLoading = false;
        });
        print('Multimedia cargada: ${multimedia.length} elementos');
        
        // Debug: imprimir todos los elementos para ver su estructura
        for (int i = 0; i < multimedia.length; i++) {
          print('Elemento $i: ${multimedia[i]}');
        }
      } else {
        print('Error al cargar multimedia: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar multimedia: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredMultimedia() {
    if (_selectedCategoryIndex == 0) {
      return multimedia; // Mostrar todo
    }
    
    final category = _categories[_selectedCategoryIndex];
    return multimedia.where((item) {
      final tipo = item['TIpo'] ?? '';
      
      // Debug: imprimir el tipo para ver qué está llegando
      print('Filtrando item: tipo = "$tipo", categoría = "$category"');
      
      switch (category) {
        case 'Texto':
          return tipo == 'texto';
        case 'Imágenes':
          // Verificar múltiples tipos de imagen
          final isImage = tipo == 'imagen' || 
                         tipo.contains('image') || 
                         tipo.contains('jpeg') || 
                         tipo.contains('png') ||
                         tipo.contains('jpg') ||
                         tipo.contains('gif') ||
                         tipo.contains('webp') ||
                         tipo.contains('octet-stream'); // Para archivos de imagen genéricos
          print('Es imagen: $isImage para tipo: $tipo');
          return isImage;
        case 'Videos':
          // Verificar múltiples tipos de video
          final isVideo = tipo == 'video' || 
                         tipo.contains('video') || 
                         tipo.contains('mp4') || 
                         tipo.contains('avi') ||
                         tipo.contains('mov') ||
                         tipo.contains('wmv') ||
                         tipo.contains('flv') ||
                         tipo.contains('webm') ||
                         tipo.contains('mkv');
          print('Es video: $isVideo para tipo: $tipo');
          return isVideo;
        case 'Audio':
          // Verificar múltiples tipos de audio
          final isAudio = tipo == 'audio' || 
                         tipo.contains('audio') || 
                         tipo.contains('mp3') || 
                         tipo.contains('wav') ||
                         tipo.contains('m4a') ||
                         tipo.contains('aac') ||
                         tipo.contains('ogg') ||
                         tipo.contains('flac');
          print('Es audio: $isAudio para tipo: $tipo');
          return isAudio;
        case 'Enlaces':
          return tipo == 'enlace';
        default:
          return true;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _cargarMultimedia();
  }

  @override
  void dispose() {
    // Limpiar la imagen temporal cuando se sale de la pantalla
    imageFile = null;
    super.dispose();
  }

  Widget _decideImageView() {
    if (imageFile == null) {
      return const Text("");
    } else {
      return Image.file(imageFile!, height: 400);
    }
  }

  Widget _mostrarCategorias() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.indigo[900] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _mostrarContenidoMultimedia() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredMultimedia = _getFilteredMultimedia();

    if (filteredMultimedia.isEmpty) {
      String mensaje = 'No hay contenido multimedia en este proyecto';
      if (_selectedCategoryIndex > 0) {
        mensaje = 'No hay ${_categories[_selectedCategoryIndex].toLowerCase()} en este proyecto';
      }
      
      return Center(
        child: Text(
          mensaje,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredMultimedia.length,
      itemBuilder: (context, index) {
        final item = filteredMultimedia[index];
        final tipo = item['TIpo'] ?? '';
        final contenido = item['Ruta'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      tipo == 'texto' ? Icons.text_fields :
                      tipo == 'enlace' ? Icons.link :
                      tipo == 'imagen' || tipo.contains('image') ? Icons.image :
                      tipo == 'video' || tipo.contains('video') ? Icons.video_library :
                      tipo == 'audio' || tipo.contains('audio') ? Icons.audiotrack :
                      Icons.insert_drive_file,
                      color: Colors.indigo[900],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tipo == 'texto' ? 'Texto' :
                      tipo == 'enlace' ? 'Enlace' :
                      tipo == 'imagen' || tipo.contains('image') ? 'Imagen' :
                      tipo == 'video' || tipo.contains('video') ? 'Video' :
                      tipo == 'audio' || tipo.contains('audio') ? 'Audio' :
                      'Archivo',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (tipo == 'texto') ...[
                  Text(
                    contenido,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else if (tipo == 'enlace') ...[
                  InkWell(
                    onTap: () {
                      // Aquí podrías abrir el enlace
                      print('Abriendo enlace: $contenido');
                    },
                    child: Text(
                      contenido,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else if (tipo == 'imagen' || tipo.contains('image') || tipo.contains('jpeg') || tipo.contains('png') || tipo.contains('octet-stream')) ...[
                  // Mostrar imagen
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        'http://192.168.1.40:8000/$contenido',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 25,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ] else if (tipo == 'video' || tipo.contains('video') || tipo.contains('mp4') || tipo.contains('avi') || tipo.contains('mov')) ...[
                  // Mostrar video
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(
                                Icons.video_library,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (tipo == 'audio' || tipo.contains('audio') || tipo.contains('mp3') || tipo.contains('wav') || tipo.contains('m4a')) ...[
                  // Mostrar audio
                  Container(
                    width: double.infinity,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.indigo[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Archivo de Audio',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.indigo[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tipo.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.indigo,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    'Archivo: ${item['Nombre'] ?? 'Sin nombre'}',
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Creado: ${DateTime.parse(item['created_at']).toString().substring(0, 19)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.proyecto != null ? "Agregar a: ${widget.proyecto!['nombre']}" : "New Project"),
        centerTitle: true, // Centra el título
        actions: [
          // Botón de actualizar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _cargarMultimedia(),
          ),
          // Opción compartir
          IconButton(
            icon: const Icon(Icons.share), // Ícono de compartir
            onPressed:
                () =>
                    _showOptionsCompartir(context), // Acción al tocar el ícono
          ),
        ],
      ),

      body: Column(
        children: [
          // Mostrar imagen seleccionada temporalmente
          if (imageFile != null)
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  child: Image.file(imageFile!, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        imageFile = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          
          // Mostrar categorías
          _mostrarCategorias(),
          
          // Mostrar contenido multimedia del proyecto
          Expanded(
            child: _mostrarContenidoMultimedia(),
          ),
        ],
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
