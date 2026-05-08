import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/views/auth/register_page.dart';
// import 'package:vigenesia_mobile/views/home/home_page.dart';
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

  void _doLogin() async {
    setState(() {
      _isLoading = true; // Munculkan loading
    });

    bool isSuccess = await _apiService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false; // Matikan loading
    });

    if (isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Berhasil!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      // Jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email atau Password salah!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ViGeNesia",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Visi Generasi Indonesia",
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 40),

              // Input Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),

              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: true, // Sembunyikan teks (titik-titik)
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 24),

              // Login
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _doLogin,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("LOGIN", style: TextStyle(fontSize: 18)),
                ),
              ),
              SizedBox(height: 16),
              
              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum punya akun?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text("Daftar di sini"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
