import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/auth/login_page.dart';
import 'package:vigenesia_mobile/views/home/add_motivasi_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _motivasiList;
  int? _myUserId;
  Set<int> _repostedIds = {};

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages(
      'id',
      timeago.IdMessages(),
    ); // Tambahkan baris ini agar formatnya "5 menit yang lalu", bukan "5 minutes ago"
    _motivasiList = _apiService
        .getMotivasi(); // Memanggil API saat halaman pertama kali dibuka
    _refreshData();
    _fetchMyUserId();
    _inisialisasiAwal();
  }

  // Mengambil ID kita dulu, BARU mengambil data motivasi
  void _inisialisasiAwal() async {
    var user = await _apiService.getUserProfile();
    if (user != null && mounted) {
      setState(() {
        _myUserId = user['id'];
      });
    }
    _refreshData();
  }

  // Fungsi Logout
  void _doLogout() async {
    await _apiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Fungsi untuk refresh layar setelah like/repost/edit/hapus
  void _refreshData() async {
    // Ambil semua data dari server Laravel
    var motivasiData = await _apiService.getMotivasi();

    // Siapkan wadah kosong untuk mencatat ID yang sudah di-repost
    Set<int> daftarBiru = {};

    // Filter data dari database secara otomatis
    if (_myUserId != null) {
      for (var item in motivasiData) {
        // Jika postingan ini milik KITA, dan ini adalah hasil REPOST (punya parent_id)
        if (item['user_id'] == _myUserId && item['parent_id'] != null) {
          // Catat ID aslinya (parent_id) ke dalam wadah biru
          daftarBiru.add(int.parse(item['parent_id'].toString()));
        }
      }
    }
    setState(() {
      _repostedIds = daftarBiru;
      _motivasiList = Future.value(motivasiData);
    });
  }

  void _fetchMyUserId() async {
    var user = await _apiService.getUserProfile();
    if (user != null && mounted) {
      setState(() {
        _myUserId = user['id'];
      });
    }
  }

  // Fungsi untuk memunculkan Pop-up Repost
  void _showRepostDialog(int id) {
    TextEditingController _quoteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Repost Motivasi"),
        content: TextField(
          controller: _quoteController,
          decoration: InputDecoration(hintText: "Tambah kutipan..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool ok = await _apiService.repost(id, _quoteController.text);
              if (ok) {
                setState(() {
                  _repostedIds.add(id);
                });
                Navigator.pop(context);
                _refreshData();
              }
            },
            child: Text("Repost"),
          ),
        ],
      ),
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

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
              // Beri sedikit jeda 1 detik agar animasi putarannya terlihat natural
              await Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var motivasi = snapshot.data![index];

                // LOGIKA DETEKSI TIPE POSTINGAN
                bool isRepost =
                    motivasi['parent_id'] != null && motivasi['parent'] != null;
                String? isiText = motivasi['isi_motivasi']?.toString();
                bool hasQuote = isiText != null && isiText.trim().isNotEmpty;

                bool isMyPost = motivasi['user_id'] == _myUserId;

                var targetPost = (isRepost && !hasQuote)
                    ? motivasi['parent']
                    : motivasi;

                String namaPenulis = targetPost['user'] != null
                    ? targetPost['user']['nama']
                    : 'Anonim';
                // String namaKategori = targetPost['kategori'] != null
                //     ? targetPost['kategori']['nama_kategori']
                //     : 'Umum';

                DateTime createdAt = targetPost['created_at'] != null
                    ? DateTime.parse(targetPost['created_at'])
                    : DateTime.now();

                String timeAgo = timeago.format(createdAt, locale: 'id');

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER REPOST MURNI ("Anda me-repost")
                        if (isRepost && !hasQuote)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  isMyPost
                                      ? "Anda me-repost"
                                      : "${motivasi['user'] != null ? motivasi['user']['nama'] : 'Seseorang'} me-repost",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // HEADER QUOTE TWEET (Jika user mengisi teks tambahan)
                        if (isRepost && hasQuote)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        motivasi['user'] != null
                                            ? motivasi['user']['nama']
                                            : 'Anonim',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  motivasi['isi_motivasi'],
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),

                        // KONTEN UTAMA (Motivasi Asli)
                        Container(
                          width: double.infinity,
                          padding: isRepost && hasQuote
                              ? EdgeInsets.all(12)
                              : EdgeInsets.zero,
                          // Buat kotak bergaris HANYA JIKA ini Quote Tweet
                          decoration: isRepost && hasQuote
                              ? BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama Penulis Asli di dalam kotak Quote
                              if (isRepost && hasQuote)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        motivasi['parent']['user'] != null
                                            ? motivasi['parent']['user']['nama']
                                            : 'Anonim',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              Text(
                                isRepost && hasQuote
                                    ? motivasi['parent']['isi_motivasi']
                                    : targetPost['isi_motivasi'],
                                style: TextStyle(
                                  fontWeight: isRepost && hasQuote
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 6),

                              // Keterangan Penulis & Kategori (Sembunyikan dari dalam kotak Quote)
                              if (!isRepost || !hasQuote)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "$namaPenulis • $timeAgo",
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 12),

                        // Button Like n Repost
                        Row(
                          children: [
                            Builder(
                              builder: (context) {
                                bool isLiked = false;
                                if (_myUserId != null &&
                                    motivasi['likes'] != null) {
                                  isLiked = motivasi['likes'].any(
                                    (like) => like['id'] == _myUserId,
                                  );
                                }
                                return IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    int motivasiId = int.parse(
                                      motivasi['id'].toString(),
                                    );
                                    await _apiService.toggleLike(motivasiId);
                                    _refreshData();
                                  },
                                );
                              },
                            ),
                            Text(
                              motivasi['likes'] != null
                                  ? "${motivasi['likes'].length}"
                                  : "0",
                            ),
                            SizedBox(width: 16),
                            Builder(
                              builder: (context) {
                                bool isRepostedByMe = false;
                                if (_myUserId != null &&
                                    snapshot.data != null) {
                                  List<dynamic> allPosts = snapshot.data!;
                                  isRepostedByMe = allPosts.any(
                                    (post) =>
                                        post['parent_id'] == motivasi['id'] &&
                                        post['user_id'] == _myUserId,
                                  );
                                }
                                return IconButton(
                                  icon: Icon(
                                    Icons.repeat,
                                    color: isRepostedByMe
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    int motivasiId = int.parse(
                                      motivasi['id'].toString(),
                                    );
                                    if (isRepostedByMe) {
                                      bool ok = await _apiService.repost(
                                        motivasiId,
                                        null,
                                      );
                                      if (ok) {
                                        _refreshData();
                                      }
                                    } else {
                                      _showRepostDialog(motivasiId);
                                    }
                                  },
                                );
                              },
                            ),
                            Text(
                              motivasi['reposts'] != null
                                  ? "${motivasi['reposts'].length}"
                                  : "0",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
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
