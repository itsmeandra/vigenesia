import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio();

  // PENTING: Gunakan 10.0.2.2 jika pakai Emulator Android.
  // Jika pakai HP asli, gunakan IP WiFi laptop kamu (misal: 192.168.1.x)
  final String baseUrl = 'http://10.0.2.2:8000/api';

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

  // Fungsi untuk Logout (Menghapus token dari lokal)
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
  Future<bool> createMotivasi(String isiMotivasi) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Ambil token yang tersimpan

      final response = await _dio.post(
        '$baseUrl/motivasi',
        data: {'isi_motivasi': isiMotivasi},
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
  Future<bool> updateMotivasi(int id, String isiMotivasi) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await _dio.put(
        '$baseUrl/motivasi/$id',
        data: {'isi_motivasi': isiMotivasi},
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
}
