<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(),[
            'nama' => 'required|string|max:255',
            'profesi' => 'required|string',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 400);
        }

        $user = User::create([
            'nama' => $request->nama,
            'profesi' => $request->profesi,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role_id' => 2,
            'is_active' => 1
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'data' => $user,
            'access' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        // Cek email dan password
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'message' => 'Email atau Password salah'
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'message' => 'Login sukses',
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout sukses, token dihapus'
        ]);
    }

    public function updateProfile(Request $request)
    {
    // 1. Ambil data user yang sedang login melalui token Sanctum
    $user = $request->user();

    // 2. Validasi input dari Flutter
    $request->validate([
        'nama' => 'required|string|max:255',
        'bio'  => 'nullable|string|max:255',
    ]);

    // 3. Isi data baru ke dalam database
    $user->nama = $request->nama;
    $user->bio = $request->bio;
    $user->save();

    // 4. Kembalikan respons sukses berupa JSON ke Flutter
    return response()->json([
        'status' => 'success',
        'message' => 'Profil berhasil diperbarui',
        'data' => $user
    ], 200);
    }
}
