<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;
use App\Models\Multimedia;

class MultimediaController extends Controller
{
    public function subir(Request $request)
    {
        // Validar si es archivo o contenido de texto/enlace
        if ($request->hasFile('archivo')) {
            // Subir archivo (imagen, video, audio)
            $request->validate([
                'archivo' => 'required|file|max:20480', // máximo 20MB
                'IDDeProyecto' => 'required|integer|exists:proyectos,IDDeProyecto',
                'tipo' => 'required|string|in:imagen,video,audio',
            ]);

            $usuarioId = Auth::id();
            $proyectoId = $request->input('IDDeProyecto');

            $archivo = $request->file('archivo');

            $ruta = "multimedia/{$usuarioId}/{$proyectoId}";
            $nombre = time() . '_' . $archivo->getClientOriginalName();

            $rutaGuardada = $archivo->storeAs($ruta, $nombre, 'public');
            $nombreOriginal = $archivo->getClientOriginalName();
            
            // Usar el tipo enviado por Flutter (ya validado arriba)
            $tipo = $request->input('tipo');
            
            // Crear el registro en la base de datos
            Multimedia::create([
                'Nombre' => $nombre,
                'TIpo' => $tipo,
                'Ruta' => 'storage/' . $rutaGuardada, // acceso desde la web
                'IDDeProyecto' => $request->IDDeProyecto,
                'IDDeUsuario' => Auth::id(),
            ]);

            return response()->json([
                'mensaje' => 'Archivo subido correctamente.',
                'ruta' => Storage::url($rutaGuardada),
                'tipo' => $tipo
            ], 201);

        } else {
            // Guardar texto o enlace
            $request->validate([
                'IDDeProyecto' => 'required|integer|exists:proyectos,IDDeProyecto',
                'tipo' => 'required|string|in:texto,enlace',
                'contenido' => 'required|string',
            ]);

            $nombre = $request->tipo . '_' . time();
            
            // Crear el registro en la base de datos
            Multimedia::create([
                'Nombre' => $nombre,
                'TIpo' => $request->tipo,
                'Ruta' => $request->contenido, // Para texto y enlaces, guardamos el contenido directamente
                'IDDeProyecto' => $request->IDDeProyecto,
                'IDDeUsuario' => Auth::id(),
            ]);

            return response()->json([
                'mensaje' => 'Contenido guardado exitosamente',
                'tipo' => $request->tipo,
                'contenido' => $request->contenido
            ], 201);
        }
    }

    // Listar toda la multimedia de un proyecto
    public function listarPorProyecto($idProyecto)
    {
        // Verificar que el usuario esté autenticado
        if (!Auth::check()) {
            return response()->json([
                'error' => 'Usuario no autenticado'
            ], 401);
        }

        $usuarioId = Auth::id();
        
        // Obtener multimedia del proyecto que pertenece al usuario autenticado
        $multimedia = Multimedia::where('IDDeProyecto', $idProyecto)
            ->where('IDDeUsuario', $usuarioId)
            ->get();

        return response()->json([
            'proyecto_id' => $idProyecto,
            'multimedia' => $multimedia
        ]);
    }

    // Obtener una multimedia por ID de multimedia, proyecto y usuario
    public function obtenerMultimedia($idProyecto, $idMultimedia, $idUsuario)
    {
        $multimedia = Multimedia::where('IDDeMultimedia', $idMultimedia)
            ->where('IDDeProyecto', $idProyecto)
            ->where('IDDeUsuario', $idUsuario)
            ->first();

        if (!$multimedia) {
            return response()->json([
                'mensaje' => 'Multimedia no encontrada con los criterios proporcionados.'
            ], 404);
        }

        return response()->json($multimedia);
    }
} 