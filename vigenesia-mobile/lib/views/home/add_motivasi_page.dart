import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';

class AddMotivasiPage extends StatefulWidget {
  @override
  _AddMotivasiPageState createState() => _AddMotivasiPageState();
}

class _AddMotivasiPageState extends State<AddMotivasiPage> {
  final TextEditingController _isiController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _submitData() async {
    // Validasi agar tidak mengirim data kosong
    if (_isiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi motivasi tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool isSuccess = await _apiService.createMotivasi(_isiController.text);

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Motivasi berhasil diposting!')),
      );
      // PENTING: Kembali ke halaman sebelumnya dan bawa sinyal "true"
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memposting motivasi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Motivasi'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _isiController,
              maxLines: 4, // Membuat kolom teks lebih luas seperti text area
              decoration: InputDecoration(
                labelText: 'Tulis motivasi Anda di sini...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitData,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('POSTING', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}