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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Warna background layar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bisa diganti dengan Image.asset('path/ke/logo.png') nanti jika punya logo
            Icon(Icons.lightbulb_outline, size: 100, color: Colors.white), 
            SizedBox(height: 20),
            Text(
              "ViGeNesia",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "Visi Generasi Indonesia",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(color: Colors.white), // Animasi loading
          ],
        ),
      ),
    );
  }
}