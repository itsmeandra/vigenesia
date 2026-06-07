import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/views/auth/register_page.dart';
import 'package:vigenesia_mobile/views/home/main_screen.dart';
import '../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isObscurePassword = true;

  // Warna-warna yang disesuaikan dari desain
  final Color _bgColor = const Color(0xFFFBFBFB);
  final Color _peachColor = const Color(0xFFFFE6D9);
  final Color _brownColor = const Color(0xFF9C4114);
  final Color _yellowCircle = const Color(0xFFC0AD5D);
  final Color _greenSquare = const Color(0xFFA5E1CB);

  void _doLogin() async {
    // Validasi sederhana sebelum hit API
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan Password tidak boleh kosong!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool isSuccess = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (isSuccess && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login Berhasil!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau Password salah!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // Latar Belakang: Lingkaran Kuning (Kanan Atas)
          Positioned(
            top: 40,
            right: -20,
            child: _buildDecorativeShape(
              color: _yellowCircle,
              isCircle: true,
              size: 120,
            ),
          ),

          // Latar Belakang: Kotak Hijau Miring (Kiri Bawah)
          Positioned(
            bottom: 40,
            left: -10,
            child: Transform.rotate(
              angle: -0.2,
              child: _buildDecorativeShape(
                color: _greenSquare,
                isCircle: false,
                size: 80,
              ),
            ),
          ),

          // Konten Utama
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4), // Hard shadow khas Brutalism
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- HEADER SECTION (Peach) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      decoration: BoxDecoration(
                        color: _peachColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(13),
                        ),
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 3),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Logo
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Vigenesia",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: _brownColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Visi Generasi Indonesia",
                            style: TextStyle(
                              color: Color(0xFF5A4A42),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- FORM SECTION (White) ---
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Email",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildCustomTextField(
                            controller: _emailController,
                            hint: "nama@email.com",
                            icon: Icons.mail_outline,
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            "Password",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildCustomTextField(
                            controller: _passwordController,
                            hint: "********",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 24),

                          // Tombol Login
                          _buildLoginButton(),
                          const SizedBox(height: 24),

                          // Register Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Belum punya akun? ",
                                style: TextStyle(color: Color(0xFF4B5563)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Daftar di sini",
                                  style: TextStyle(
                                    color: _brownColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  // Komponen Ekstraktif untuk TextField Brutalism
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscurePassword : false,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: Icon(icon, color: Colors.black54),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscurePassword ? Icons.visibility_off : Icons.visibility,
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

  // Komponen Ekstraktif untuk Tombol Login
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _doLogin,
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
              offset: Offset(4, 4), // Shadow pekat tombol
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
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }

  // Komponen Ekstraktif untuk Ornamen Latar Belakang
  Widget _buildDecorativeShape({
    required Color color,
    required bool isCircle,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
    );
  }
}
