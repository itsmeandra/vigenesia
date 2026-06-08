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
  final Color primaryBrown = const Color(0xFF9C4114);
  final Color bgColor = const Color(0xFFF8F8F8);
  final Color mintGreen = const Color(0xFFBFECDC);

  @override
  void initState() {
    super.initState();
    _fetchKategori();
    _isiController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _isiController.dispose();
    super.dispose();
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

    if (isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Motivasi berhasil diposting!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memposting motivasi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black, height: 1.5),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: Color(0xFF9C4114)),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
            (route) => false,
          ),
        ),
        title: Text(
          'Buat Motivasi',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.w900,
            fontSize: 22,
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
            child: GestureDetector(
              onTap: _isLoading ? null : _submitData,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryBrown,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Posting',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === AREA INPUT TEKS ===
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _isiController,
                        maxLines:
                            null, // Membiarkan teks bertambah panjang tanpa batas
                        keyboardType: TextInputType.multiline,
                        maxLength: 500,
                        buildCounter:
                            (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) => null,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: '" Motivasi apa hari ini? "',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // Indikator Karakter Custom di pojok kiri bawah
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Text(
                        "${_isiController.text.length} / 500",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
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
                        color: Colors.black87,
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
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    // Berubah warna solid jika dipilih
                                    color: isSelected
                                        ? mintGreen
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black,
                                        offset: Offset(
                                          2,
                                          2,
                                        ), // Shadow kecil untuk chips
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    kategori['nama_kategori'],
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
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
