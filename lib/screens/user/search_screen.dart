import 'package:flutter/material.dart';
import '../../models/search_result.dart';
import '../../models/book.dart';
import '../../services/open_library_service.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.userId});

  final String userId;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _openLibraryService = OpenLibraryService();
  final _firestoreService = FirestoreService();
  final _searchCtrl = TextEditingController();

  List<SearchResult> _results = [];
  bool _loading = false;
  bool _hasSearched = false;
  String? _error;
  final Set<String> _addingTitles = {};

  Future<void> _search() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _hasSearched = true;
    });

    try {
      final results = await _openLibraryService.searchBooks(query);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = 'No se pudo buscar. Revisa tu conexión.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _addToLibrary(SearchResult result) async {
    setState(() => _addingTitles.add(result.title));

    final book = Book(
      id: '',
      title: result.title,
      author: result.author,
      year: result.year,
      coverUrl: result.coverUrl,
      status: 'pendiente',
      ownerId: widget.userId,
    );

    try {
      await _firestoreService.addBook(book);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${result.title}" agregado a tu biblioteca'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _addingTitles.remove(result.title));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar libros')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Título, autor...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _results = [];
                            _hasSearched = false;
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _search(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 48, color: AppColors.textLight.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textLight)),
            ],
          ),
        ),
      );
    }
    if (_hasSearched && _results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.textLight.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              const Text('No se encontraron libros',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Intenta con otro título o autor',
                  style: TextStyle(color: AppColors.textLight, fontSize: 13)),
            ],
          ),
        ),
      );
    }
    if (!_hasSearched) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.travel_explore, size: 56, color: AppColors.primary.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              const Text('Encuentra tu próxima lectura',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('Busca por título o autor usando Open Library',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textLight, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _results.length,
      itemBuilder: (context, index) => _resultCard(_results[index]),
    );
  }

  Widget _resultCard(SearchResult result) {
    final isAdding = _addingTitles.contains(result.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: result.coverUrl.isNotEmpty
                ? Image.network(
                    result.coverUrl,
                    width: 56,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _coverPlaceholder(),
                  )
                : _coverPlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.author} · ${result.year ?? "s/f"}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textLight, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isAdding
              ? const SizedBox(
                  width: 36, height: 36,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Material(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _addToLibrary(result),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.add, color: Colors.white, size: 22),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 56,
      height: 78,
      color: AppColors.background,
      child: const Icon(Icons.menu_book, color: AppColors.textLight, size: 24),
    );
  }
}