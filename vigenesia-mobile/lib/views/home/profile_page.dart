import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/home/edit_motivasi_page.dart';
import 'package:vigenesia_mobile/views/home/edit_profile_page.dart';
import 'package:vigenesia_mobile/widgets/settings_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _userData;
  int? _myUserId;

  late Future<List<dynamic>> _myMotivasi;
  late Future<List<dynamic>> _likedMotivasi;
  late Future<List<dynamic>> _savedMotivasi;

  int _postCount = 0;
  int _likeCount = 0;

  final Color primaryOrange = Color(0xFFD4840C);
  final Color fireColor = Color(0xFFD9381E);

  // Fungsi untuk mengambil inisial nama
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "?";

    // Pecah nama berdasarkan spasi
    List<String> nameParts = name.trim().split(RegExp(r'\s+'));

    if (nameParts.length > 1) {
      // Ambil huruf pertama dari kata pertama dan kedua (contoh: Full Name -> FN)
      return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
    } else {
      // Jika hanya satu kata (contoh: Name -> N)
      return nameParts[0][0].toUpperCase();
    }
  }

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('id', timeago.IdMessages());
    _loadData();
  }

  void _loadData() {
    setState(() {
      _myMotivasi = _apiService.getMyMotivasi();
      _likedMotivasi = _apiService.getLikedMotivasi();
      _savedMotivasi = _apiService
          .getSavedMotivasi(); // <-- 2. AMBIL DATA SAVED
    });
    _myMotivasi.then((data) {
      if (mounted) setState(() => _postCount = data.length);
    });
    _likedMotivasi.then((data) {
      if (mounted) setState(() => _likeCount = data.length);
    });
    _apiService.getUserProfile().then((user) {
      if (mounted) {
        setState(() {
          _userData = user;
          _myUserId = user?['id'];
        });
      }
    });
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(
              "Hapus Postingan?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text("Tindakan ini tidak dapat dibatalkan."),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(c, true),
                child: Text("Hapus", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildPostItem(dynamic m) {
    bool isRepost = m['parent_id'] != null && m['parent'] != null;
    String? isiText = m['isi_motivasi']?.toString();
    bool hasQuote = isiText != null && isiText.trim().isNotEmpty;
    bool isMyPost = m['user_id'] == _myUserId;

    var targetData = (isRepost && !hasQuote) ? m['parent'] : m;
    String namaPenulis = targetData['user'] != null
        ? targetData['user']['nama']
        : 'Anonim';
    String namaKategori = targetData['kategori'] != null
        ? targetData['kategori']['nama_kategori']
        : 'Umum';

    DateTime createdAt = targetData['created_at'] != null
        ? DateTime.parse(targetData['created_at'])
        : DateTime.now();
    String timeAgo = timeago.format(createdAt, locale: 'id');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Repost Murni
          if (isRepost && !hasQuote)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 14, color: Colors.grey.shade600),
                  SizedBox(width: 6),
                  Text(
                    isMyPost ? "You reposted" : "${m['user']['nama']} reposted",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Bagian Atas Postingan (Teks + Menu Titik Tiga)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote Tweet Content
                    if (isRepost && hasQuote) ...[
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          children: [TextSpan(text: "${m['isi_motivasi']} ")],
                        ),
                      ),
                      SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "— ${m['user'] != null ? m['user']['nama'] : 'Anonim'}",
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

                    // Main Content (Motivasi Asli)
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
                                      ? "${m['parent']['isi_motivasi']} "
                                      : "${targetData['isi_motivasi']} ",
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
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "— ${isRepost && hasQuote ? (m['parent']['user'] != null ? m['parent']['user']['nama'] : 'Anonim') : namaPenulis}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 13,
                                  ),
                                ),
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
                  ],
                ),
              ),

              // Menu Titik Tiga (Edit/Hapus) - Hanya muncul jika ini postingan milik user login
              if (isMyPost)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: Colors.grey.shade600),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditMotivasiPage(
                            id: m['id'],
                            isiMotivasiLama: m['isi_motivasi'],
                            kategoriIdLama: m['kategori_id'],
                          ),
                        ),
                      );
                      if (res == true) _loadData();
                    } else if (value == 'delete') {
                      bool confirm = await _showDeleteDialog();
                      if (confirm) {
                        if (isRepost) {
                          await _apiService.repost(m['parent_id'], null);
                        } else {
                          await _apiService.deleteMotivasi(m['id']);
                        }
                        _loadData();
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        if (!isRepost || hasQuote)
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                ),
            ],
          ),
          SizedBox(height: 12),

          // Action Buttons (Like & Repost Dinamis)
          Row(
            children: [
              // TOMBOL LIKE
              Builder(
                builder: (context) {
                  bool isLiked = false;
                  if (_myUserId != null && m['likes'] != null) {
                    isLiked = m['likes'].any((like) => like['id'] == _myUserId);
                  }
                  return InkWell(
                    onTap: () async {
                      int motivasiId = int.parse(m['id'].toString());
                      await _apiService.toggleLike(motivasiId);
                      _loadData(); // Langsung memuat ulang profil
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
                                : Icons.local_fire_department_outlined,
                            color: isLiked ? fireColor : Colors.grey.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            m['likes'] != null ? "${m['likes'].length}" : "0",
                            style: TextStyle(
                              color: isLiked ? fireColor : Colors.grey.shade600,
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

              // TOMBOL REPOST
              Builder(
                builder: (context) {
                  // Di profil, kita sederhanakan dengan tombol Un-repost jika diklik (khusus untuk tab Posts kita)
                  return InkWell(
                    onTap: () async {
                      // Opsional: Implementasi logika popup repost jika dibutuhkan di profil.
                      // Untuk sekarang, klik akan merefresh data.
                      int motivasiId = int.parse(m['id'].toString());
                      if (isMyPost && isRepost && !hasQuote) {
                        await _apiService.repost(
                          m['parent_id'],
                          null,
                        ); // Unrepost langsung
                        _loadData();
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
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            m['reposts'] != null
                                ? "${m['reposts'].length}"
                                : "0",
                            style: TextStyle(
                              color: Colors.grey.shade600,
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
                  if (_myUserId != null && m['bookmarks'] != null) {
                    isSaved = m['bookmarks'].any((bm) => bm['id'] == _myUserId);
                  }
                  return InkWell(
                    onTap: () async {
                      int motivasiId = int.parse(m['id'].toString());
                      await _apiService.toggleSave(motivasiId);
                      _loadData(); // Refresh profil
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 4.0,
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? primaryOrange : Colors.grey.shade600,
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
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
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
            IconButton(
              icon: Icon(Icons.settings_outlined, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
                // showModalBottomSheet(
                //   context: context,
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.vertical(
                //       top: Radius.circular(20),
                //     ),
                //   ),
                // builder: (context) => SafeArea(
                //   child: Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       ListTile(
                //         leading: Icon(Icons.logout, color: Colors.red),
                //         title: Text(
                //           'Logout',
                //           style: TextStyle(
                //             color: Colors.red,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         onTap: _doLogout,
                //       ),
                //     ],
                //   ),
                // ),
                // );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // === HEADER PROFIL ===
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: EdgeInsets.only(top: 20, bottom: 0, left: 24, right: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade200,
                    child: Text(
                      _getInitials(
                        _userData?['nama'],
                      ), // Panggil fungsi inisial
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange, // Warna teks inisial
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _userData?['nama'] ?? "Loading...",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      _userData?['bio'] ?? "Belum ada bio.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  // Statistik Dinamis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "$_postCount",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Posts",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.grey.shade300,
                        margin: EdgeInsets.symmetric(horizontal: 24),
                      ),
                      Column(
                        children: [
                          Text(
                            "$_likeCount",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Likes",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(userData: _userData!),
                            ),
                          );
                          if (res == true) _loadData();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          side: BorderSide(color: primaryOrange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          "Edit Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // === TAB BAR ===
                  TabBar(
                    labelColor: primaryOrange,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: primaryOrange,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(text: "Posts"),
                      Tab(text: "Liked"),
                      Tab(text: "Saved"),
                    ],
                  ),
                ],
              ),
            ),

            // KONTEN TAB
            Expanded(
              child: TabBarView(
                children: [
                  // TAB 1: POSTS
                  FutureBuilder<List<dynamic>>(
                    future: _myMotivasi,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator(
                            color: primaryOrange,
                          ),
                        );
                      if (!snapshot.hasData || snapshot.data!.isEmpty)
                        return Center(
                          child: Text(
                            "Belum ada postingan.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );

                      return RefreshIndicator(
                        color: primaryOrange,
                        onRefresh: () async => _loadData(),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) =>
                              _buildPostItem(snapshot.data![index]),
                        ),
                      );
                    },
                  ),

                  // TAB 2: LIKED
                  FutureBuilder<List<dynamic>>(
                    future: _likedMotivasi,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator(
                            color: primaryOrange,
                          ),
                        );
                      if (!snapshot.hasData || snapshot.data!.isEmpty)
                        return Center(
                          child: Text(
                            "Belum ada postingan yang disukai.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );

                      return RefreshIndicator(
                        color: primaryOrange,
                        onRefresh: () async => _loadData(),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) =>
                              _buildPostItem(snapshot.data![index]),
                        ),
                      );
                    },
                  ),

                  // TAB 3: SAVED
                  FutureBuilder<List<dynamic>>(
                    future: _savedMotivasi,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Center(
                          child: CircularProgressIndicator(
                            color: primaryOrange,
                          ),
                        );
                      if (!snapshot.hasData || snapshot.data!.isEmpty)
                        return Center(
                          child: Text(
                            "Belum ada postingan yang disimpan.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );

                      return RefreshIndicator(
                        color: primaryOrange,
                        onRefresh: () async => _loadData(),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) =>
                              _buildPostItem(snapshot.data![index]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
