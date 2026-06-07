import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/home/profile_page.dart';
import 'package:vigenesia_mobile/widgets/settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _motivasiList;
  int? _myUserId;
  Set<int> _repostedIds = {};

  // Konstanta Warna Tema
  final Color primaryOrange = Color(0xFFD4840C); // Warna Vigenesia
  final Color fireColor = Color(0xFFD9381E); // Warna Api Like
  String? _myName;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _motivasiList = _apiService.getMotivasi();
    _refreshData();
    _fetchMyUserId();
    _inisialisasiAwal();
  }

  void _inisialisasiAwal() async {
    var user = await _apiService.getUserProfile();
    if (user != null && mounted) {
      setState(() {
        _myUserId = user['id'];
        _myName = user['nama'];
      });
    }
    _refreshData();
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "?";
    List<String> nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    } else {
      return nameParts[0][0].toUpperCase();
    }
  }

  void _refreshData() async {
    var motivasiData = await _apiService.getMotivasi();
    Set<int> daftarBiru = {};
    if (_myUserId != null) {
      for (var item in motivasiData) {
        if (item['user_id'] == _myUserId && item['parent_id'] != null) {
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

  void _showRepostDialog(int id) {
    TextEditingController _quoteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quote Tweet"),
        content: TextField(
          controller: _quoteController,
          decoration: InputDecoration(
            hintText: "Tambahkan pemikiranmu...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              bool ok = await _apiService.repost(id, _quoteController.text);
              if (ok) {
                setState(() => _repostedIds.add(id));
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
      backgroundColor: Color(0xFFF8F9FA), // Latar belakang sangat abu muda
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Garis bayangan tipis di bawah AppBar
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Text(
                _getInitials(_myName),
                style: TextStyle(
                  color: primaryOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
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
        centerTitle: true,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.settings_outlined, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _motivasiList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryOrange),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan saat memuat data.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Belum ada motivasi. Jadilah yang pertama!'),
            );
          }

          return RefreshIndicator(
            color: primaryOrange,
            onRefresh: () async {
              _refreshData();
              await Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var motivasi = snapshot.data![index];

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
                String namaKategori = targetPost['kategori'] != null
                    ? targetPost['kategori']['nama_kategori']
                    : 'Umum';

                DateTime createdAt = targetPost['created_at'] != null
                    ? DateTime.parse(targetPost['created_at'])
                    : DateTime.now();
                String timeAgo = timeago.format(createdAt, locale: 'id');

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === HEADER: You reposted ===
                      if (isRepost && !hasQuote)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.repeat,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 6),
                              Text(
                                isMyPost
                                    ? "You reposted"
                                    : "${motivasi['user'] != null ? motivasi['user']['nama'] : 'Seseorang'} reposted",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // === KONTEN UTAMA & QUOTE TWEET ===
                      if (isRepost && hasQuote) ...[
                        // Jika ada Quote, tampilkan teks quote terlebih dahulu
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(text: '"${motivasi['isi_motivasi']}"'),
                              // (Opsional) Jika quote punya hashtag kategori sendiri
                            ],
                          ),
                        ),
                        SizedBox(height: 6),
                        // Nama Penulis Quote
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "— ${motivasi['user'] != null ? motivasi['user']['nama'] : 'Anonim'}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: " · $timeAgo",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],

                      // === KOTAK POSTINGAN ASLI ===
                      Container(
                        width: double.infinity,
                        padding: isRepost && hasQuote
                            ? EdgeInsets.all(14)
                            : EdgeInsets.zero,
                        decoration: isRepost && hasQuote
                            ? BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Isi Motivasi + Hashtag Kategori
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: isRepost && hasQuote
                                        ? '"${motivasi['parent']['isi_motivasi']}" '
                                        : '"${targetPost['isi_motivasi']}" ',
                                  ),
                                  TextSpan(
                                    text: "#$namaKategori",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),

                            // Penulis Asli
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "— ${isRepost && hasQuote ? (motivasi['parent']['user'] != null ? motivasi['parent']['user']['nama'] : 'Anonim') : namaPenulis}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 13,
                                    ),
                                  ),
                                  // Waktu hanya tampil di sini jika bukan Quote Tweet
                                  if (!isRepost || !hasQuote)
                                    TextSpan(
                                      text: " · $timeAgo",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 14),

                      // === ACTION BUTTONS (Like & Repost) ===
                      Row(
                        children: [
                          // Tombol Like
                          Builder(
                            builder: (context) {
                              bool isLiked = false;
                              if (_myUserId != null &&
                                  motivasi['likes'] != null) {
                                isLiked = motivasi['likes'].any(
                                  (like) => like['id'] == _myUserId,
                                );
                              }
                              return InkWell(
                                onTap: () async {
                                  int motivasiId = int.parse(
                                    motivasi['id'].toString(),
                                  );
                                  await _apiService.toggleLike(motivasiId);
                                  _refreshData();
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked
                                            ? Icons.local_fire_department
                                            : Icons
                                                  .local_fire_department_outlined,
                                        color: isLiked
                                            ? fireColor
                                            : Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        motivasi['likes'] != null
                                            ? "${motivasi['likes'].length}"
                                            : "0",
                                        style: TextStyle(
                                          color: isLiked
                                              ? fireColor
                                              : Colors.grey.shade600,
                                          fontWeight: isLiked
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 24),

                          // Tombol Repost
                          Builder(
                            builder: (context) {
                              bool isRepostedByMe = false;
                              if (_myUserId != null && snapshot.data != null) {
                                List<dynamic> allPosts = snapshot.data!;
                                isRepostedByMe = allPosts.any(
                                  (post) =>
                                      post['parent_id'] == motivasi['id'] &&
                                      post['user_id'] == _myUserId,
                                );
                              }
                              return InkWell(
                                onTap: () async {
                                  int motivasiId = int.parse(
                                    motivasi['id'].toString(),
                                  );
                                  if (isRepostedByMe) {
                                    bool ok = await _apiService.repost(
                                      motivasiId,
                                      null,
                                    );
                                    if (ok) _refreshData();
                                  } else {
                                    _showRepostDialog(motivasiId);
                                  }
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 4.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.repeat,
                                        color: isRepostedByMe
                                            ? Colors.blue.shade600
                                            : Colors.grey.shade600,
                                        size: 20,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        motivasi['reposts'] != null
                                            ? "${motivasi['reposts'].length}"
                                            : "0",
                                        style: TextStyle(
                                          color: isRepostedByMe
                                              ? Colors.blue.shade600
                                              : Colors.grey.shade600,
                                          fontWeight: isRepostedByMe
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          Spacer(),
                          
                          // Tombol Saved
                          Builder(
                            builder: (context) {
                              bool isSaved = false;
                              // Mengecek apakah ada id user kita di dalam daftar bookmarks
                              if (_myUserId != null &&
                                  motivasi['bookmarks'] != null) {
                                isSaved = motivasi['bookmarks'].any(
                                  (bm) => bm['id'] == _myUserId,
                                );
                              }
                              return InkWell(
                                onTap: () async {
                                  int motivasiId = int.parse(
                                    motivasi['id'].toString(),
                                  );
                                  await _apiService.toggleSave(motivasiId);
                                  _refreshData(); // Refresh beranda
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                    vertical: 4.0,
                                  ),
                                  child: Icon(
                                    isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isSaved
                                        ? primaryOrange
                                        : Colors.grey.shade600,
                                    size: 22,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
