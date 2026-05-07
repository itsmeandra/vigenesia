<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\MotivasiController;
use App\Http\Controllers\API\KategoriController;

// ROUTE PUBLIC (Tidak perlu login / token)
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Menampilkan daftar motivasi bisa dibuat publik atau dilindungi (disini kita buat publik)
Route::get('/motivasi', [MotivasiController::class, 'index']);

// ROUTE PROTECTED (Harus login dan menyertakan Bearer Token)
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth route
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user(); // Mendapatkan profil user yang sedang login
    });

    // Motivasi route (Hanya untuk tambah, ubah, hapus)
    Route::post('/motivasi', [MotivasiController::class, 'store']);
    Route::put('/motivasi/{id}', [MotivasiController::class, 'update']);
    Route::delete('/motivasi/{id}', [MotivasiController::class, 'destroy']);
});

Route::get('/kategori', [KategoriController::class, 'index']);