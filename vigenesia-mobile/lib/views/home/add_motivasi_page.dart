// import 'package:flutter/material.dart';
// import 'package:vigenesia_mobile/services/api_service.dart';

// class AddMotivasiPage extends StatefulWidget {
//   @override
//   _AddMotivasiPageState createState() => _AddMotivasiPageState();
// }

// class _AddMotivasiPageState extends State<AddMotivasiPage> {
//   final TextEditingController _isiController = TextEditingController();
//   final ApiService _apiService = ApiService();
//   bool _isLoading = false;

//   List<dynamic> _kategoriList = [];
//   int? _selectedKategori;

//   @override
//   void initState() {
//     super.initState();
//     _fetchKategori();
//   }

//   void _fetchKategori() async {
//     var data = await _apiService.getKategori();
//     setState(() {
//       _kategoriList = data;
//     });
//   }

//   void _submitData() async {
//     // Validasi agar tidak mengirim data kosong
//     if (_isiController.text.trim().isEmpty || _selectedKategori == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Isi motivasi dan Kategori tidak boleh kosong!'),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     bool isSuccess = await _apiService.createMotivasi(
//       _isiController.text,
//       _selectedKategori!,
//     );

//     setState(() {
//       _isLoading = false;
//     });

//     if (isSuccess) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Motivasi berhasil diposting!')));
//       // PENTING: Kembali ke halaman sebelumnya dan bawa sinyal "true"
//       Navigator.pop(context, true);
//     } else {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Gagal memposting motivasi.')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Post Motivasi'), centerTitle: true,),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             DropdownButtonFormField<int>(
//               decoration: InputDecoration(
//                 labelText: 'Pilih Kategori',
//                 border: OutlineInputBorder(),
//               ),
//               value: _selectedKategori,
//               items: _kategoriList.map((kategori) {
//                 return DropdownMenuItem<int>(
//                   value: kategori['id'],
//                   child: Text(kategori['nama_kategori']),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedKategori = value;
//                 });
//               },
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _isiController,
//               maxLines: 4, // Membuat kolom teks lebih luas seperti text area
//               decoration: InputDecoration(
//                 labelText: 'Tulis motivasi Anda...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _submitData,
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(vertical: 15),
//               ),
//               child: _isLoading
//                   ? CircularProgressIndicator(color: Colors.white)
//                   : Text('POSTING', style: TextStyle(fontSize: 16)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/home/main_screen.dart';

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

  // Warna Tema
  final Color primaryOrange = Color(0xFFD4840C);
  final Color primaryBlue = Color(0xFF0050CB);

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
    if (_isiController.text.trim().isEmpty || _selectedKategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Isi motivasi dan Kategori tidak boleh kosong!'),
          backgroundColor: Colors.red,
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memposting motivasi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang abu-abu sangat muda
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
          ),
        ),
        title: Text(
          'Vigenesia',
          style: TextStyle(
            color: primaryOrange,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          // Tombol Posting di kanan atas
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Melengkung mulus
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Posting',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === AREA INPUT TEKS ===
              Expanded(
                child: TextField(
                  controller: _isiController,
                  maxLines:
                      null, // Membiarkan teks bertambah panjang tanpa batas
                  keyboardType: TextInputType.multiline,
                  autofocus:
                      true, // Otomatis memunculkan keyboard saat halaman dibuka
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    hintText: '" Motivasi apa hari ini? "',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                    ),
                    border: InputBorder.none, // Menghilangkan garis form bawaan
                  ),
                ),
              ),

              SizedBox(height: 16),

              // === AREA KATEGORI ===
              Container(
                padding: EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori Topik:',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Deretan Tombol Kategori (Chips)
                    _kategoriList.isEmpty
                        ? SizedBox(
                            height: 40,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Wrap(
                            spacing: 8.0, // Jarak menyamping
                            runSpacing:
                                10.0, // Jarak atas-bawah jika teks panjang
                            children: _kategoriList.map((kategori) {
                              int katId = int.parse(kategori['id'].toString());
                              bool isSelected = _selectedKategori == katId;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedKategori = katId;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    // Berubah warna solid jika dipilih
                                    color: isSelected
                                        ? primaryBlue
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryBlue
                                          : primaryBlue.withOpacity(0.4),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    kategori['nama_kategori'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : primaryBlue,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
              // Tambahan padding bawah agar tidak tertutup indikator home iPhone / Keyboard
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
