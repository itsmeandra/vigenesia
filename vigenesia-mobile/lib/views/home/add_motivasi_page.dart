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

  List<dynamic> _kategoriList = [];
  int? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  void _fetchKategori() async {
    var data = await _apiService.getKategori();
    setState(() {
      _kategoriList = data;
    });
  }

  void _submitData() async {
    // Validasi agar tidak mengirim data kosong
    if (_isiController.text.trim().isEmpty || _selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Isi motivasi dan Kategori tidak boleh kosong!'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool isSuccess = await _apiService.createMotivasi(
      _isiController.text,
      _selectedKategori!,
    );

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Motivasi berhasil diposting!')));
      // PENTING: Kembali ke halaman sebelumnya dan bawa sinyal "true"
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memposting motivasi.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Motivasi')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Pilih Kategori',
                border: OutlineInputBorder(),
              ),
              value: _selectedKategori,
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem<int>(
                  value: kategori['id'],
                  child: Text(kategori['nama_kategori']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKategori = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _isiController,
              maxLines: 4, // Membuat kolom teks lebih luas seperti text area
              decoration: InputDecoration(
                labelText: 'Tulis motivasi Anda...',
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
