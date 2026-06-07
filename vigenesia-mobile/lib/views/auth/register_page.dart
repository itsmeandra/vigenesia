import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/auth/login_page.dart';
import 'package:vigenesia_mobile/views/home/main_screen.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _profesiController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _isObscurePassword = true;

  // Palet Warna Brutalism
  final Color _bgColor = const Color(0xFFF8F8F8);
  final Color _brownColor = const Color(0xFF9C4114);
  final Color _greenCircle = const Color(0xFFDBEFE6);
  final Color _yellowCircle = const Color(0xFFF6EACA);
  final Color _textColor = const Color(0xFF424656);

  void _doRegister() async {
    // Validasi form kosong (Profesi ditambahkan)
    if (_namaController.text.isEmpty ||
        _profesiController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom data diri wajib diisi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    bool isSuccess = await _apiService.register(
      _namaController.text,
      _profesiController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi Berhasil! Selamat Datang.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi gagal. Cek kembali data Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- CUSTOM APP BAR / HEADER ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Vigenesia",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: _brownColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 48,
                  ), // Penyeimbang agar judul tetap di tengah
                ],
              ),
            ),

            // --- MAIN CONTENT ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Container(
                  width: double.infinity,
                  // Konfigurasi border kotak utama
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  // Penting: Memotong elemen anak yang keluar dari batas border
                  clipBehavior: Clip.hardEdge,
                  child: Stack(
                    children: [
                      // Dekorasi Lingkaran Hijau (Kanan Atas)
                      Positioned(
                        top: -50,
                        right: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: _greenCircle,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                      ),

                      // Dekorasi Lingkaran Kuning (Kiri Bawah)
                      Positioned(
                        bottom: -40,
                        left: -40,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _yellowCircle,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                      ),

                      // --- ISI FORM ---
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              "Buat Akun",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Bergabunglah dengan komunitas\ninspiratif kami.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: _textColor,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Input Fields
                            _buildInputLabel("Nama Lengkap"),
                            _buildCustomTextField(
                              controller: _namaController,
                              hint: "Masukkan nama Anda",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),

                            _buildInputLabel("Profesi"),
                            _buildCustomTextField(
                              controller: _profesiController,
                              hint: "Profesi saat ini",
                              icon: Icons.work_outline,
                            ),
                            const SizedBox(height: 16),

                            _buildInputLabel("Email"),
                            _buildCustomTextField(
                              controller: _emailController,
                              hint: "contoh@email.com",
                              icon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            _buildInputLabel("Password"),
                            _buildCustomTextField(
                              controller: _passwordController,
                              hint: "Minimal 8 karakter",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 32),

                            // Tombol Daftar
                            _buildRegisterButton(),
                            const SizedBox(height: 24),

                            // Teks Login
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sudah punya akun? ",
                                  style: TextStyle(color: _textColor),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Masuk di sini",
                                    style: TextStyle(
                                      color: _brownColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Teks Label di luar TextField
  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  // Widget TextField bergaya Brutalism
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword ? _isObscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black54),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() => _isObscurePassword = !_isObscurePassword);
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 3),
        ),
      ),
    );
  }

  // Widget Tombol Daftar
  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _doRegister,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: _brownColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4), // Bayangan pekat di tombol
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Daftar Sekarang",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
