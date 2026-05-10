import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:vigenesia_mobile/views/auth/login_page.dart';
import 'package:vigenesia_mobile/views/home/main_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Biarkan logo tampil selama 2 detik agar terlihat profesional
    await Future.delayed(Duration(seconds: 2));

    // Cek apakah ada token di memori HP
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Jika token ada, arahkan langsung ke MainScreen. Jika tidak, ke LoginPage.
    if (token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 230,
              height: 230,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              "ViGeNesia",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4840C),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Visi Generasi Indonesia",
              style: TextStyle(fontSize: 16, color: Color(0xFF424656)),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(
              color: Color(0xFF2C3E50),
            ), // Animasi loading
          ],
        ),
      ),
    );
  }
}
