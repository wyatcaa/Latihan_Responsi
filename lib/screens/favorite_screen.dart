import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/amiibo_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import '../utils/notif_helper.dart';

class FavoriteScreen extends StatefulWidget {
  final Set<String> favoritesSet;
  final Function(String) onRemove;

  const FavoriteScreen({
    super.key,
    required this.favoritesSet,
    required this.onRemove,
  });

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<AmiiboModel> _allItems = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  // Ambil semua data Amiibo
  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final list = await ApiService.fetchAllAmiibo();
      if (!mounted) return;
      setState(() {
        _allItems = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // Hapus favorite via swipe
  Future<void> _removeFavorite(String head) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList('favorites') ?? [];

    list.remove(head);
    await sp.setStringList('favorites', list);

    widget.onRemove(head); // update dari HomeScreen juga

    NotifHelper.showNotif("Dihapus dari Favorite", "Item berhasil dihapus");

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Favorite dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favHeads = widget.favoritesSet;

    // Ambil hanya item yang merupakan favorite
    final favItems = _allItems.where((e) => favHeads.contains(e.head)).toList();

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text("Favorites")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Favorites")),
        body: Center(child: Text("Error: $_error")),
      );
    }

    if (favItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Favorites")),
        body: Center(child: Text("Tidak ada favorite")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: favItems.length,
        itemBuilder: (context, index) {
          final item = favItems[index];

          return Dismissible(
            key: Key(item.head),
            direction: DismissDirection.horizontal,
            onDismissed: (_) async {
              if (!mounted) return;
              await _removeFavorite(item.head);
              if (!mounted) return;
              setState(() {}); // refresh list
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            // CARD untuk tampilan rapi
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 40),
                  ),
                ),
                title: Text(
                  item.name,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item.gameSeries,
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade700),
                ),

                // **Klik item untuk masuk DETAIL**
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(
                        item: item,
                        isFavoriteInit: true,
                        onFavChanged: (newVal) async {
                          if (!newVal) {
                            await _removeFavorite(item.head);
                          }
                          if (!mounted) return;
                          setState(() {});
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
