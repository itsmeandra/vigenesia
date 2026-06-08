import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vigenesia_mobile/services/api_service.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> motivasi;
  final int? myUserId;
  final ApiService apiService;
  final VoidCallback onActionComplete;

  const PostCard({
    Key? key,
    required this.motivasi,
    required this.myUserId,
    required this.apiService,
    required this.onActionComplete,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final Color primaryBrown = const Color(0xFF9C4114);

  //===== Fungsi Dialog Repost =====
  void _showRepostDialog(int id) {
    TextEditingController _quoteController = TextEditingController();

    // Mengganti showDialog menjadi showModalBottomSheet
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // WAJIB TRUE: Agar modal bisa bergeser naik saat keyboard muncul
      backgroundColor: Colors
          .transparent, // Dibuat transparan agar kita bisa kustomisasi border radius-nya
      builder: (context) {
        return Padding(
          // WAJIB ADA: Memberikan margin bawah sebesar ukuran keyboard yang muncul
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Agar tinggi modal menyesuaikan isi konten
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Quote Visi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _quoteController,
                  autofocus:
                      true, // Otomatis fokus dan memunculkan keyboard saat modal terbuka
                  decoration: InputDecoration(
                    hintText: "Tambahkan pemikiranmu...",
                    // Penyesuaian border gaya Brutalism
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryBrown, width: 3),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBrown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // Tambahan border hitam pada tombol
                        side: const BorderSide(color: Colors.black, width: 2),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        // Panggil API Repost
                        bool ok = await widget.apiService.repost(
                          id,
                          _quoteController.text,
                        );
                        if (ok && mounted) {
                          Navigator.pop(context); // Tutup dialog
                          widget.onActionComplete(); // Refresh data di HomePage
                        }
                      },
                      child: const Text(
                        "Repost",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRepost =
        widget.motivasi['parent_id'] != null &&
        widget.motivasi['parent'] != null;
    String? isiText = widget.motivasi['isi_motivasi']?.toString();
    bool hasQuote = isiText != null && isiText.trim().isNotEmpty;
    bool isMyPost = widget.motivasi['user_id'] == widget.myUserId;

    var targetPost = (isRepost && !hasQuote)
        ? widget.motivasi['parent']
        : widget.motivasi;

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Repost
          if (isRepost && !hasQuote)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Icon(Icons.repeat, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 6),
                  Text(
                    isMyPost
                        ? "YOU REPOSTED"
                        : "${widget.motivasi['user'] != null ? widget.motivasi['user']['nama'].toString().toUpperCase() : 'SESEORANG'} REPOSTED",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Teks Utama
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF333333),
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: isRepost && hasQuote
                      ? '"${widget.motivasi['isi_motivasi']}" '
                      : '"${targetPost['isi_motivasi']}" ',
                ),
                TextSpan(
                  text: "#$namaKategori",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBrown,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Penulis & Waktu
          Text(
            "— ${isRepost && hasQuote ? (widget.motivasi['user'] != null ? widget.motivasi['user']['nama'] : 'Anonim') : namaPenulis}  ·  $timeAgo",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF424656),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),

          // Nested Quote Tweet
          if (isRepost && hasQuote)
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // color: const Color(0xFFFAF1ED),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: "${widget.motivasi['parent']['isi_motivasi']} ",
                        ),
                        TextSpan(
                          text:
                              "#${widget.motivasi['parent']['kategori'] != null ? widget.motivasi['parent']['kategori']['nama_kategori'] : 'Pendidikan'}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBrown,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "— ${widget.motivasi['parent']['user'] != null ? widget.motivasi['parent']['user']['nama'] : 'Anonim'}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424656),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          const Divider(color: Colors.black12, thickness: 1, height: 1),
          const SizedBox(height: 12),

          // Tombol Aksi
          _buildActionButtons(widget.motivasi),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> motivasi) {
    bool isLiked =
        widget.myUserId != null &&
        motivasi['likes'] != null &&
        motivasi['likes'].any((like) => like['id'] == widget.myUserId);
    bool isSaved =
        widget.myUserId != null &&
        motivasi['bookmarks'] != null &&
        motivasi['bookmarks'].any((bm) => bm['id'] == widget.myUserId);

    // Mengecek apakah user sudah me-repost
    bool isRepostedByMe = false;
    if (widget.myUserId != null && motivasi['reposts'] != null) {
      isRepostedByMe = motivasi['reposts'].any(
        (repost) =>
            repost['user_id'] == widget.myUserId ||
            repost['id'] == widget.myUserId,
      );
    }

    return Row(
      children: [
        // Like
        InkWell(
          onTap: () async {
            await widget.apiService.toggleLike(
              int.parse(motivasi['id'].toString()),
            );
            widget.onActionComplete();
          },
          child: Row(
            children: [
              Icon(
                isLiked
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                color: isLiked ? const Color(0xFFD9381E) : Colors.grey.shade700,
                size: 22,
              ),
              const SizedBox(width: 4),
              Text(
                motivasi['likes'] != null ? "${motivasi['likes'].length}" : "0",
                style: TextStyle(
                  color: isLiked
                      ? const Color(0xFFD9381E)
                      : Colors.grey.shade700,
                  fontWeight: isLiked ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // --- LOGIKA REPOST DITAMBAHKAN DI SINI ---
        InkWell(
          onTap: () async {
            int motivasiId = int.parse(motivasi['id'].toString());

            if (isRepostedByMe) {
              // Jika sudah di-repost, batalkan repost (kirim teks null sesuai kode lama Anda)
              bool ok = await widget.apiService.repost(motivasiId, null);
              if (ok) widget.onActionComplete();
            } else {
              // Jika belum, tampilkan dialog
              _showRepostDialog(motivasiId);
            }
          },
          child: Row(
            children: [
              Icon(
                Icons.repeat,
                color: isRepostedByMe
                    ? Colors.blue.shade600
                    : Colors.grey.shade700,
                size: 22,
              ),
              const SizedBox(width: 4),
              Text(
                motivasi['reposts'] != null
                    ? "${motivasi['reposts'].length}"
                    : "0",
                style: TextStyle(
                  color: isRepostedByMe
                      ? Colors.blue.shade600
                      : Colors.grey.shade700,
                  fontWeight: isRepostedByMe
                      ? FontWeight.bold
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Save
        InkWell(
          onTap: () async {
            await widget.apiService.toggleSave(
              int.parse(motivasi['id'].toString()),
            );
            widget.onActionComplete();
          },
          child: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: Colors.amber.shade600,
            size: 24,
          ),
        ),
      ],
    );
  }
}
