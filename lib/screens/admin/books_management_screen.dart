
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/book.dart';
import '../../theme/app_theme.dart';
import '../../widgets/book_cover.dart';

class BooksManagementScreen extends StatelessWidget {
  const BooksManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Gestión de libros')),
      body: StreamBuilder<List<Book>>(
        stream: firestoreService.getAllBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('No hay libros registrados'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(
                      coverBase64: book.coverBase64,
                      coverUrl: book.coverUrl,
                      width: 44,
                      height: 62,
                      radius: 8,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${book.author} · ${book.year ?? "s/f"}',
                              style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Dueño: ${book.ownerId}',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textLight, fontSize: 10.5)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Eliminar libro'),
                            content: Text('¿Eliminar "${book.title}"?'),
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
                          await firestoreService.deleteBook(book.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
