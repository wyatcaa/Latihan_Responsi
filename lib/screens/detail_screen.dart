import 'package:flutter/material.dart';
import '../models/amiibo_model.dart';
import '../utils/notif_helper.dart';

class DetailScreen extends StatefulWidget {
  final AmiiboModel item;
  final bool isFavoriteInit;
  final Function(bool) onFavChanged;

  const DetailScreen({
    super.key,
    required this.item,
    required this.isFavoriteInit,
    required this.onFavChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavoriteInit;
  }

  void _toggleFav() {
    setState(() => isFavorite = !isFavorite);

    if (isFavorite) {
      NotifHelper.showNotif("Ditambahkan ke Favorite",
          "${widget.item.name} berhasil ditambahkan");
    } else {
      NotifHelper.showNotif("Dihapus dari Favorite",
          "${widget.item.name} telah dihapus");
    }

    widget.onFavChanged(isFavorite);
  }

  Widget _infoRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 140,
              child: Text(
                left,
                style: const TextStyle(fontSize: 15),
              )),
          Expanded(
            child: Text(
              right,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _releaseRow(String region, String? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(region,
                style:
                    TextStyle(fontSize: 15, color: Colors.grey.shade700)),
          ),
          Expanded(
            child: Text(date ?? "-",
                style:
                    TextStyle(fontSize: 15, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Amiibo Details"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFav,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD ATAS SEPERTI DI GAMBAR
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(
                      item.image,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.contain, // <- BIKIN GAMBAR TIDAK TERPOTONG
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 220,
                        child: Icon(Icons.image, size: 80),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white,
                      child: Center(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              item.name,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _infoRow("Amiibo Series", item.amiiboSeries),
            _infoRow("Character", item.character),
            _infoRow("Game Series", item.gameSeries),
            _infoRow("Type", item.type),
            _infoRow("Head", item.head),
            _infoRow("Tail", item.tail),

            const SizedBox(height: 25),

            Text(
              "Release Dates",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 10),

            _releaseRow("Australia", item.release.au),
            _releaseRow("Europe", item.release.eu),
            _releaseRow("Japan", item.release.jp),
            _releaseRow("North America", item.release.na),
          ],
        ),
      ),
    );
  }
}
