<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Motivasi;
use Illuminate\Http\Request;

class MotivasiController extends Controller
{
    // Menampilkan semua data motivasi (Beranda)
    public function index()
    {
        $motivasi = Motivasi::with(['user', 'kategori', 'likes', 'parent', 'parent.user', 'reposts'])
        ->orderBy('id', 'desc')
        ->get();
        return response()->json(['data' => $motivasi]);
    }

    public function userMotivasi(Request $request)
    {
    // Mengambil motivasi yang user_id nya sesuai dengan ID user yang sedang login
    $motivasi = Motivasi::with(['user', 'kategori', 'likes', 'parent', 'parent.user', 'reposts'])
                ->where('user_id', $request->user()->id)
                ->orderBy('id', 'desc')
                ->get();

    return response()->json(['data' => $motivasi]);
    }

    // Menyimpan motivasi baru
    public function store(Request $request)
    {
        $request->validate([
            'isi_motivasi' => 'required|string',
            'kategori_id' => 'required|integer|exists:kategoris,id'
        ]);

        $motivasi = Motivasi::create([
            'isi_motivasi' => $request->isi_motivasi,
            'user_id' => $request->user()->id,   // Mengambil ID dari user yang sedang login
            'kategori_id' => $request->kategori_id,
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
        if ($motivasi->user_id != $request->user()->id) {
            return response()->json(['message' => 'Anda tidak berhak mengedit motivasi ini'], 403);
        }

        $motivasi->isi_motivasi = $request->isi_motivasi;
        $motivasi->kategori_id = $request->kategori_id;
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

        if ($motivasi->user_id != $request->user()->id) {
            return response()->json(['message' => 'Anda tidak berhak menghaapus motivasi'], 403);
        }

        $motivasi->delete();

        return response()->json(['message' => 'Motivasi berhasil dihapus']);
    }
}
