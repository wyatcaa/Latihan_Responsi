import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/amiibo_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'favorite_screen.dart';
import '../utils/notif_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<AmiiboModel> _items = [];
  Set<String> _favorites = {};
  bool _loading = true;
  String _error = '';
  String _searchQuery = "";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    NotifHelper.requestPermissionIfNeeded();
    _loadFavorites().then((_) => _fetchData());
  }

  Future<void> _loadFavorites() async {
    final sp = await SharedPreferences.getInstance();
    final favList = sp.getStringList('favorites') ?? [];
    setState(() => _favorites = favList.toSet());
  }

  Future<void> _saveFavorites() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList('favorites', _favorites.toList());
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final list = await ApiService.fetchAllAmiibo();
      setState(() {
        _items = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _toggleFavorite(AmiiboModel item) {
    final isFav = _favorites.contains(item.head);

    setState(() {
      if (isFav) {
        _favorites.remove(item.head);
        NotifHelper.showNotif("Dihapus dari Favorite", "${item.name} telah dihapus");
      } else {
        _favorites.add(item.head);
        NotifHelper.showNotif("Ditambahkan ke Favorite", "${item.name} berhasil ditambahkan");
      }
    });

    _saveFavorites();
  }

  void _navigateToDetail(AmiiboModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          item: item,
          isFavoriteInit: _favorites.contains(item.head),
          onFavChanged: (bool newVal) {
            setState(() {
              if (newVal) {
                _favorites.add(item.head);
              } else {
                _favorites.remove(item.head);
              }
            });
            _saveFavorites();
          },
        ),
      ),
    );
  }

  void _resetSearch() {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchQuery = "";
      _searchController.clear();
    });
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error.isNotEmpty) return Center(child: Text("Error: $_error"));

    final filteredItems = _searchQuery.isEmpty
        ? _items
        : _items.where((item) {
            return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          final isFavorite = _favorites.contains(item.head);

          return Card(
            elevation: 4,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 15),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                _resetSearch(); // auto reset search
                _navigateToDetail(item);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, size: 50),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(item.gameSeries,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700)),
                        ],
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                        size: 30,
                      ),
                      onPressed: () => _toggleFavorite(item),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      GestureDetector(
        onTap: _resetSearch,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Amiibo List"),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Cari berdasarkan nama...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                  },
                ),
              ),
            ),
          ),
          body: _buildList(),
        ),
      ),

      FavoriteScreen(
        favoritesSet: _favorites,
        onRemove: (String head) {
          setState(() {
            _favorites.remove(head);
            _saveFavorites();
          });
        },
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorite'),
        ],
        onTap: (i) {
          _resetSearch(); // reset saat ganti tab
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}
