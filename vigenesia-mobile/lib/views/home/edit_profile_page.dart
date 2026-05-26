import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  EditProfilePage({required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ApiService _apiService = ApiService();
  late TextEditingController _namaController;
  late TextEditingController _bioController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.userData['nama']);
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);

    bool success = await _apiService.updateProfile(
      _namaController.text,
      _bioController.text,
    );

    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan profil.')));
    }
  }

  // Fungsi pembuat inisial untuk pratinjau di halaman edit
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "?";
    List<String> nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    } else {
      return nameParts[0][0].toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Edit Profil",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE68900),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Simpan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Pratinjau Avatar Inisial
            CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE68900).withOpacity(0.15),
              child: Text(
                _getInitials(_namaController.text),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE68900),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Form Nama
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // SetState ini berguna agar inisial di atas berubah otomatis saat kita mengetik nama baru!
                setState(() {});
              },
            ),
            SizedBox(height: 20),

            // Form Bio
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
