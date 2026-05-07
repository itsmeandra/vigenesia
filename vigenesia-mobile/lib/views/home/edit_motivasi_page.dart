import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';

class EditMotivasiPage extends StatefulWidget {
  final int id;
  final String isiMotivasiLama;
  final int? kategoriIdLama;

  // Constructor untuk menerima data yang akan diedit
  EditMotivasiPage({
    required this.id,
    required this.isiMotivasiLama,
    this.kategoriIdLama,
  });

  @override
  _EditMotivasiPageState createState() => _EditMotivasiPageState();
}

class _EditMotivasiPageState extends State<EditMotivasiPage> {
  late TextEditingController _isiController;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<dynamic> _kategoriList = [];
  int? _selectedKategori;

  @override
  void initState() {
    super.initState();
    _isiController = TextEditingController(text: widget.isiMotivasiLama);
    _selectedKategori = widget.kategoriIdLama;
    _fetchKategori();
  }

  void _fetchKategori() async {
    var data = await _apiService.getKategori();
    setState(() {
      _kategoriList = data;
    });
  }

  void _submitUpdate() async {
    if (_isiController.text.trim().isEmpty || _selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isi motivasi tidak boleh kosong!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Memanggil API Update
    bool isSuccess = await _apiService.updateMotivasi(
      widget.id,
      _isiController.text,
      _selectedKategori!,
    );

    setState(() => _isLoading = false);

    if (isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Motivasi berhasil diubah!')));
      Navigator.pop(context, true); // Kembali dan beri sinyal refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah. Mungkin ini bukan motivasi Anda.'),
        ),
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
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Pilih Kategori',
                border: OutlineInputBorder(),
              ),
              value: _selectedKategori,
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem<int>(
                  value: int.parse(kategori['id'].toString()),
                  child: Text(kategori['nama_kategori'].toString()),
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
