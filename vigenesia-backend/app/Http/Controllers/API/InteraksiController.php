<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Motivasi; 
use App\Models\User;

class InteraksiController extends Controller
{
    public function toggleLike(Request $request, $id) {
        $user = $request->user();
        // toggle() otomatis menambah jika belum ada, dan menghapus jika sudah ada
        $user->likes()->toggle($id);
        return response()->json(['message' => 'Status like berhasil diubah']);
    }

    public function repost(Request $request, $id) 
    {
    $userId = $request->user()->id;

    // Cek apakah user sudah pernah me-repost motivasi ini
    $existingRepost = Motivasi::where('user_id', $userId)
                                  ->where('parent_id', $id)
                                  ->first();
    // Jika sudah pernah di-repost, maka kita hapus (Un-Repost)
    if ($existingRepost) {
            $existingRepost->delete();
            return response()->json(['message' => 'Unrepost berhasil'], 200);
        }
    
    // Jika belum pernah, maka buat Repost baru
    $request->validate(['isi_motivasi' => 'nullable|string']);

    $repost = Motivasi::create([
        'user_id' => $request->user()->id,
        'parent_id' => $id,
        'isi_motivasi' => $request->isi_motivasi ?? '', // Untuk fitur Quote (tambahan teks)
        'kategori_id' => Motivasi::find($id)->kategori_id,
    ]);

    return response()->json(['message' => 'Repost berhasil', 'data' => $repost], 201);
    }
}
