<?php

namespace App\Http\Controllers;

use App\Models\Menu;
use Illuminate\Http\Request;

class MenuController extends Controller
{
    // Ambil semua menu
    public function index()
    {
        try {
            $menus = Menu::all();
            return response()->json([
                'success' => true,
                'data' => $menus
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Terjadi kesalahan saat mengambil data menus.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Tambah menu baru
    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'description' => 'nullable|string',
                'price' => 'required|numeric|min:0',
                'image' => 'nullable|string',
            ]);

            $menu = Menu::create([
                'name' => $request->name,
                'description' => $request->description,
                'price' => $request->price,
                'image' => $request->image,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Menu berhasil ditambahkan.',
                'data' => $menu
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menambahkan menu.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Update menu berdasarkan ID
    public function update(Request $request, $id)
    {
        try {
            $menu = Menu::findOrFail($id);

            $request->validate([
                'name' => 'required|string|max:255',
                'description' => 'nullable|string',
                'price' => 'required|numeric|min:0',
                'image' => 'nullable|string',
            ]);

            $menu->update([
                'name' => $request->name,
                'description' => $request->description,
                'price' => $request->price,
                'image' => $request->image,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Menu berhasil diperbarui.',
                'data' => $menu
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui menu.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // Hapus menu berdasarkan ID
    public function destroy($id)
    {
        try {
            $menu = Menu::findOrFail($id);
            $menu->delete();

            return response()->json([
                'success' => true,
                'message' => 'Menu berhasil dihapus.'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus menu.',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}