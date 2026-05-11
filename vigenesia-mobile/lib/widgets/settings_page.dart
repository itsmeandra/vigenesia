import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/auth/login_page.dart';

class SettingsPage extends StatelessWidget {
  final ApiService _apiService = ApiService();

  void _doLogout(BuildContext context) async {
    await _apiService.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentlyDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pengaturan', 
          style: TextStyle(fontWeight: FontWeight.bold, color: isCurrentlyDark ? Colors.white : Colors.black87)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isCurrentlyDark ? Colors.white : Colors.black87),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "Akun",
            style: TextStyle(color: Color(0xFFE68900), fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 10),

          // LOGOUT
          Container(
            decoration: BoxDecoration(
              color: isCurrentlyDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isCurrentlyDark ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: ListTile(
              leading: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.logout, color: Colors.red)
              ),
              title: Text('Keluar Aplikasi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: Text("Keluar Aplikasi?", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: Text("Anda yakin ingin keluar dari Vigenesia?"),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(c, false), 
                        child: Text("Batal", style: TextStyle(color: Colors.grey))
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
                        onPressed: () => Navigator.pop(c, true), 
                        child: Text("Keluar", style: TextStyle(color: Colors.white))
                      ),
                    ],
                  )
                ) ?? false;
                
                if (confirm) _doLogout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}