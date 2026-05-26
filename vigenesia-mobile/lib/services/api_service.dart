import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio();

  // PENTING: Gunakan 10.0.2.2 jika pakai Emulator Android.
  // Jika pakai HP asli, gunakan IP WiFi laptop kamu (misal: 192.168.1.x)
  final String baseUrl = 'https://isochimal-daniela-turbidly.ngrok-free.dev/api';

  // Fungsi Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        // Jika sukses, ambil token dari JSON response Laravel
        String token = response.data['access_token'];

        // Simpan token ke memori lokal HP menggunakan SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return true; // Login berhasil
      }
      return false;
    } catch (e) {
      print('Error Login: $e');
      return false; // Login gagal
    }
  }

  Future<bool> register(
    String nama,
    String profesi,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {
          'nama': nama,
          'profesi': profesi,
          'email': email,
          'password': password,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );

      // Status 201 Created berarti data berhasil disimpan
      if (response.statusCode == 201) {
        String token = response.data['access'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return true;
      }
      return false;
    } catch (e) {
      print('Error Register: $e');
      return false;
    }
  }

  // Fungsi Logout (Menghapus token dari lokal)
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Fungsi untuk mengambil daftar motivasi
  Future<List<dynamic>> getMotivasi() async {
    try {
      // Mengambil token yang tersimpan saat login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await _dio.get(
        '$baseUrl/motivasi',
        options: Options(
          headers: {
            'Accept': 'application/json',
            // Jika rute GET /motivasi di Laravel kamu masukkan ke dalam auth:sanctum, aktifkan baris ini:
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response
            .data['data']; // 'data' sesuai dengan format JSON dari Laravel
      }
      return [];
    } catch (e) {
      print('Error Get Motivasi: $e');
      return [];
    }
  }

  // Fungsi untuk menambah motivasi baru
  Future<bool> createMotivasi(String isiMotivasi, int kategoriId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Ambil token yang tersimpan

      final response = await _dio.post(
        '$baseUrl/motivasi',
        data: {'isi_motivasi': isiMotivasi, 'kategori_id': kategoriId},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization':
                'Bearer $token', // Token otorisasi disisipkan di sini
          },
        ),
      );

      // Laravel membalas status 201 Created jika berhasil menambah data
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error Create Motivasi: $e');
      return false;
    }
  }

  // Fungsi untuk mengubah/mengedit motivasi (PUT)
  Future<bool> updateMotivasi(
    int id,
    String isiMotivasi,
    int kategoriId,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await _dio.put(
        '$baseUrl/motivasi/$id',
        data: {'isi_motivasi': isiMotivasi, 'kategori_id': kategoriId},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      // Menangkap error 403 jika user mengedit motivasi orang lain
      print('Error Update Motivasi: ${e.response?.statusCode}');
      return false;
    }
  }

  // Fungsi untuk menghapus motivasi (DELETE)
  Future<bool> deleteMotivasi(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await _dio.delete(
        '$baseUrl/motivasi/$id',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      // print('=== ERROR DELETE ===');
      // print('Status Code: ${e.response?.statusCode}');
      // print('Pesan Server: ${e.response?.data}');
      // return false;

      print('Error Delete Motivasi: ${e.response?.statusCode}');
      return false;
    }
  }

  // Fungsi ini untuk mengambil list Kategori
  Future<List<dynamic>> getKategori() async {
    try {
      final response = await _dio.get('$baseUrl/kategori');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      print('Error Get Kategori: $e');
      return [];
    }
  }

  // Fungsi ambil data profil user yang sedang login
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await _dio.get(
        '$baseUrl/user',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fungsi ambil motivasi milik saya sendiri
  Future<List<dynamic>> getMyMotivasi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await _dio.get(
        '$baseUrl/my-motivasi',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      print('Error My Motivasi: $e');
      return [];
    }
  }

  // Fungsi Like/Unlike
  Future<void> toggleLike(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      await _dio.post(
        '$baseUrl/motivasi/$id/like',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      // Tips: tambahkan print untuk debug error 500
      if (e is DioException) {
        print('Pesan: ${e.response?.data}');
      }
      rethrow; // atau handle sesuai kebutuhan
    }
  }

  // Fungsi Repost
  Future<bool> repost(int id, String? quote) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await _dio.post(
        '$baseUrl/motivasi/$id/repost',
        data: {'isi_motivasi': quote},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Fungsi ambil motivasi yang saya LIKE
  Future<List<dynamic>> getLikedMotivasi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await _dio.get(
        '$baseUrl/liked-motivasi',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateProfile(String nama, String bio) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      final response = await _dio.post(
        '$baseUrl/user/update',
        data: {"nama": nama, "bio": bio},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException) {
        print("ERROR DARI LARAVEL: ${e.response?.data}");
        print("STATUS CODE: ${e.response?.statusCode}");
      } else {
        print("ERROR FLUTTER: $e");
      }
      return false;
    }
  }
}
