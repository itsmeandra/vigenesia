import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/home/edit_motivasi_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  late Future<List<dynamic>> _myMotivasi;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final user = await _apiService.getUserProfile();
    setState(() {
      _userData = user;
      _myMotivasi = _apiService.getMyMotivasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER PROFIL
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userData?['nama'] ?? "Loading...", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(_userData?['profesi'] ?? "...", style: TextStyle(color: Colors.grey.shade700)),
                    Text(_userData?['email'] ?? "...", style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
                ),
              ],
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Motivasi Saya", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // LIST MOTIVASI SAYA
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _myMotivasi,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("Belum ada motivasi."));

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var m = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(m['isi_motivasi']),
                        subtitle: Text("Kategori: ${m['kategori']?['nama_kategori'] ?? 'Umum'}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => EditMotivasiPage(id: m['id'], isiMotivasiLama: m['isi_motivasi'], kategoriIdLama: m['kategori_id'])));
                                if (res == true) _loadData();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool confirm = await _showDeleteDialog();
                                if (confirm) {
                                  await _apiService.deleteMotivasi(m['id']);
                                  _loadData();
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
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("Hapus?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text("Hapus")),
        ],
      ),
    );
  }
}