import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';

class EditMotivasiPage extends StatefulWidget {
  final int id;
  final String isiMotivasiLama;

  // Constructor untuk menerima data yang akan diedit
  EditMotivasiPage({required this.id, required this.isiMotivasiLama});

  @override
  _EditMotivasiPageState createState() => _EditMotivasiPageState();
}

class _EditMotivasiPageState extends State<EditMotivasiPage> {
  late TextEditingController _isiController;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mengisi kolom teks dengan motivasi yang lama
    _isiController = TextEditingController(text: widget.isiMotivasiLama);
  }

  void _submitUpdate() async {
    if (_isiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Isi motivasi tidak boleh kosong!')));
      return;
    }

    setState(() => _isLoading = true);
    
    // Memanggil API Update
    bool isSuccess = await _apiService.updateMotivasi(widget.id, _isiController.text);
    
    setState(() => _isLoading = false);

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Motivasi berhasil diubah!')));
      Navigator.pop(context, true); // Kembali dan beri sinyal refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah. Mungkin ini bukan motivasi Anda.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Motivasi')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _isiController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Edit motivasi Anda...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitUpdate,
              child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('SIMPAN PERUBAHAN', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}