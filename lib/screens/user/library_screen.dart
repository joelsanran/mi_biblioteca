import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/book.dart';
import '../../theme/app_theme.dart';
import 'book_form_screen.dart';
import '../../widgets/book_cover.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key, required this.userId});

  final String userId;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final _firestoreService = FirestoreService();
  String _filter = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi biblioteca')),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<List<Book>>(
              stream: _firestoreService.getUserBooks(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                var books = snapshot.data ?? [];
                final total = books.length;
                if (_filter != 'todos') {
                  books = books.where((b) => b.status == _filter).toList();
                }
                if (books.isEmpty) {
                  return _buildEmptyState(total);
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  itemCount: books.length,
                  itemBuilder: (context, index) => _bookTile(books[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookFormScreen(userId: widget.userId)),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Agregar', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      ('todos', 'Todos', Icons.apps),
      ('pendiente', 'Pendientes', Icons.bookmark_border),
      ('leyendo', 'Leyendo', Icons.menu_book),
      ('leido', 'Leídos', Icons.check_circle_outline),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x0D000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: filters.map((f) {
            final selected = _filter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(f.$3,
                    size: 16, color: selected ? Colors.white : AppColors.textLight),
                label: Text(f.$2),
                selected: selected,
                onSelected: (_) => setState(() => _filter = f.$1),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide.none,
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(int totalBooks) {
    final isFiltered = _filter != 'todos';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.filter_alt_off : Icons.auto_stories,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'Nada por aquí' : 'Tu biblioteca está vacía',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              isFiltered
                  ? 'No tienes libros en esta categoría'
                  : 'Busca libros y agrégalos para empezar tu colección',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookTile(Book book) {
    final statusColor = book.status == 'leido'
        ? AppColors.success
        : book.status == 'leyendo'
            ? AppColors.warning
            : AppColors.pending;
    final statusLabel = book.status == 'leido'
        ? 'Leído'
        : book.status == 'leyendo'
            ? 'Leyendo'
            : 'Pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookFormScreen(userId: widget.userId, book: book),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(coverBase64: book.coverBase64, coverUrl: book.coverUrl),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${book.author} · ${book.year ?? "s/f"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textLight, fontSize: 12.5),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (book.status == 'leido' && book.rating != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 15, color: AppColors.secondary),
                                const SizedBox(width: 2),
                                Text('${book.rating}/5',
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          if (book.status == 'leyendo' && book.currentPage != null)
                            Text('Pág. ${book.currentPage}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                  onPressed: () => _confirmDelete(book),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Book book) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar libro'),
        content: Text('¿Eliminar "${book.title}" de tu biblioteca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestoreService.deleteBook(book.id);
    }
  }
}