import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/auth/login_page.dart';
import 'package:vigenesia_mobile/views/home/add_motivasi_page.dart';
import 'package:vigenesia_mobile/views/home/edit_motivasi_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _motivasiList;

  @override
  void initState() {
    super.initState();
    // Memanggil API saat halaman pertama kali dibuka
    _motivasiList = _apiService.getMotivasi();
  }

  // Fungsi Logout
  void _doLogout() async {
    await _apiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beranda ViGeNesia'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _doLogout, // Panggil fungsi logout saat ditekan
          ),
        ],
      ),
      // FutureBuilder sangat bagus untuk menangani data dari API (loading, error, success)
      body: FutureBuilder<List<dynamic>>(
        future: _motivasiList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            ); // Tampilan loading
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan saat memuat data.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Belum ada motivasi. Jadilah yang pertama!'),
            );
          }

          // Jika data berhasil diambil, tampilkan dalam bentuk ListView
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var motivasi = snapshot.data![index];
              // Pastikan nama variabel sesuai dengan nama field yang dikirim API Laravel (misal: 'nama' dari relasi user)
              String namaPenulis = motivasi['user'] != null
                  ? motivasi['user']['nama']
                  : 'Anonim';

              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    motivasi['isi_motivasi'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Oleh: $namaPenulis",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMotivasiPage(
                                id: motivasi['id'],
                                isiMotivasiLama: motivasi['isi_motivasi'],
                              ),
                            ),
                          );
                          // Refresh data jika berhasil diedit
                          if (result == true) {
                            setState(() {
                              _motivasiList = _apiService.getMotivasi();
                            });
                          }
                        },
                      ),

                      // Tombol Hapus
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          // Dialog Konfirmasi Hapus
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Hapus Motivasi?'),
                              content: Text(
                                'Anda yakin ingin menghapus data ini?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    'Hapus',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          // Jika user klik "Hapus"
                          if (confirm == true) {
                            bool isDeleted = await _apiService.deleteMotivasi(
                              int.parse(
                                motivasi['id'].toString(),
                              ),
                            );
                            if (isDeleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Berhasil dihapus!')),
                              );
                              setState(() {
                                _motivasiList = _apiService
                                    .getMotivasi(); // Refresh data
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal. Anda hanya bisa menghapus motivasi milik sendiri.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Tombol untuk menambah motivasi baru (akan kita fungsikan nanti)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Menunggu hasil dari halaman AddMotivasiPage
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMotivasiPage()),
          );

          // Jika result bernilai 'true' (artinya berhasil post), maka refresh data!
          if (result == true) {
            setState(() {
              _motivasiList = _apiService.getMotivasi();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
