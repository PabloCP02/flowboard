<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Proyecto;
use App\Models\Categoria;

class ProyectoController extends Controller
{
    // Método que falta - crear_proyecto
    public function crear_proyecto(Request $request)
    {
        try {
            $request->validate([
                'nombre' => 'required|string|max:255',
                'descripcion' => 'nullable|string',
                'IDDeUsuario' => 'required|integer',
                'IDDeCategoria' => 'required|integer|exists:categorias,IDDeCategoria',
            ]);

            $proyecto = Proyecto::create([
                'IDDeUsuario' => $request->IDDeUsuario,
                'nombre' => $request->nombre,
                'descripcion' => $request->descripcion,
                'IDDeStatus' => 1,
                'IDDeCategoria' => $request->IDDeCategoria,
            ]);

            return response()->json([
                'mensaje' => 'Proyecto creado exitosamente',
                'proyecto' => $proyecto
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Error al crear proyecto: ' . $e->getMessage()
            ], 500);
        }
    }

    // Crear proyecto
    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:255',
            'descripcion' => 'nullable|string',
        ]);

        $proyecto = Proyecto::create([
            'IDDeUsuario' => auth()->id(), 
            'nombre' => $request->nombre,
            'descripcion' => $request->descripcion,
            'IDDeStatus' => 1,
            'IDDeCategoria' => $request->categoria,
        ]);

        return response()->json($proyecto, 201);
    }

    // Archivar proyecto
    public function archivar($id)
    {
        $proyecto = Proyecto::findOrFail($id);
        $proyecto->IDDeStatus = 2;
        $proyecto->save();

        return response()->json(['mensaje' => 'Proyecto archivado correctamente']);
    }

    // Desarchivar
    public function desarchivar($id)
    {
        $proyecto = Proyecto::findOrFail($id);
        $proyecto->status = 1;
        $proyecto->save();

        return response()->json(['mensaje' => 'Proyecto desarchivado correctamente']);
    }

    public function actualizarCategoria(Request $request, $id)
    {
        $request->validate([
            'IDDeCategoria' => 'required|integer|exists:categorias,IDDeCategoria',
        ]);

        $proyecto = Proyecto::findOrFail($id);
        $proyecto->IDDeCategoria = $request->IDDeCategoria;
        $proyecto->save();

        return response()->json([
            'mensaje' => 'Categoría del proyecto actualizada correctamente',
            'proyecto' => $proyecto
        ]);
    }

    public function listarProyectosPorUsuario($idUsuario)
    {
        $proyectos = Proyecto::with('categoria') // Asegura que se cargue la relación
            ->where('IDDeUsuario', $idUsuario)
            ->get();

        if ($proyectos->isEmpty()) {
            return response()->json([
                'mensaje' => 'Este usuario no tiene proyectos registrados.'
            ], 404);
        }

        // Agrupar por nombre de categoría
        $proyectosAgrupados = $proyectos->groupBy(function ($proyecto) {
            return $proyecto->categoria->nombre ?? 'Sin categoría';
        });

        return response()->json([
            'usuario_id' => $idUsuario,
            'proyectos' => $proyectosAgrupados
        ]);
    }
} 