<?php

namespace App\Http\Controllers\API;
use App\Models\Kategori;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class KategoriController extends Controller
{
    public function index()
    {
        $kategori = Kategori::all();
        return response()->json(['data' => $kategori]);
    }
}
