import 'package:flutter/material.dart';
import 'package:vigenesia_mobile/services/api_service.dart';
import 'package:vigenesia_mobile/views/home/post_card.dart';
import 'package:vigenesia_mobile/widgets/settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _motivasiList;
  int? _myUserId;

  final Color primaryBrown = const Color(0xFF9C4114);
  final Color bgColor = const Color(0xFFF8F8F8);

  @override
  void initState() {
    super.initState();
    _motivasiList = _apiService.getMotivasi();
    _inisialisasiAwal();
  }

  void _inisialisasiAwal() async {
    var user = await _apiService.getUserProfile();
    if (user != null && mounted) {
      setState(() {
        _myUserId = user['id'];
      });
    }
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _motivasiList = _apiService.getMotivasi();
    });
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
          icon: const Icon(Icons.hub_outlined, color: Colors.black, size: 26),
          onPressed: () {}, // Tambahkan navigasi jika diperlukan
        ),
        title: Text(
          'Vigenesia',
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 0.5,
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
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9C4114)),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Terjadi kesalahan saat memuat data.'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada motivasi. Jadilah yang pertama!'),
            );
          }

          return RefreshIndicator(
            color: primaryBrown,
            onRefresh: () async {
              _refreshData();
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: snapshot.data!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                var motivasi = snapshot.data![index];

                // --- PANGGIL WIDGET POSTCARD DI SINI ---
                return PostCard(
                  motivasi: motivasi,
                  myUserId: _myUserId,
                  apiService: _apiService,
                  onActionComplete: _refreshData,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
