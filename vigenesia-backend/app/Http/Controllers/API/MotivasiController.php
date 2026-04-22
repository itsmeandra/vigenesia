<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class MotivasiController extends Controller
{
    // Menampilkan semua data motivasi (Beranda)
    public function index()
    {
        $motivasi = Motivasi::with('user')->orderBy('id', 'desc')->get();
        return response()->json(['data' => $motivasi]);
    }

    // Menyimpan motivasi baru
    public function store(Request $request)
    {
        $request->validate([
            'isi_motivasi' => 'required|string'
        ]);

        $motivasi = Motivasi::create([
            'isi_motivasi' => $request->isi_motivasi,
            'iduser' => $request->user()->id,   // Mengambil ID dari user yang sedang login
        ]);

        return response()->json([
            'message' => 'Motivasi berhasil ditambahkan',
            'data' => $motivasi
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    // Mengedit motivasi
    public function update(Request $request, string $id)
    {
        $motivasi = Motivasi::find($id);

        if (!$motivasi) {
            return response()->json(['message' => 'Data tidak ditemukan'], 404);
        }

        // Cek apakah yang edit adalah pemilik motivasi
        if ($motivasi->iduser != $request->user()->id) {
            return response()->json(['message' => 'Anda tidak berhak mengedit motivasi ini'], 403);
        }

        $motivasi->isi_motivasi = $request->isi_motivasi;
        $motivasi->save();

        return response()->json([
            'message' => 'Motivasi berhasil diupdate',
            'data' => $motivasi
        ]);
    }

    // Menghapus motivasi
    public function destroy(Request $request, string $id)
    {
        $motivasi = Motivasi::find($id);

        if (!$motivasi) {
            return response()->json(['message' => 'Data tidak ditemukan'], 404);
        }

        if ($motivasi->iduser != $request->user()->id()) {
            return response()->json(['message' => 'Anda tidak berhak menghaapus motivasi'], 403);
        }

        $motivasi->delete();

        return response()->json(['message' => 'Motivasi berhasil dihapus']);
    }
}
