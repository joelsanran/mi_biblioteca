
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/book.dart';
import '../../theme/app_theme.dart';
import '../../widgets/book_cover.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  final String userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(userName)),
      body: StreamBuilder<List<Book>>(
        stream: firestoreService.getUserBooks(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const Center(
              child: Text('Este usuario no tiene libros registrados'),
            );
          }

          final leidos = books.where((b) => b.status == 'leido').toList();
          final leyendo = books.where((b) => b.status == 'leyendo').toList();
          final pendientes = books
              .where((b) => b.status == 'pendiente')
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (leidos.isNotEmpty) ...[
                _sectionTitle('Leídos', leidos.length, AppColors.success),
                ...leidos.map(_bookTile),
                const SizedBox(height: 20),
              ],
              if (leyendo.isNotEmpty) ...[
                _sectionTitle('Leyendo', leyendo.length, AppColors.warning),
                ...leyendo.map(_bookTile),
                const SizedBox(height: 20),
              ],
              if (pendientes.isNotEmpty) ...[
                _sectionTitle(
                  'Pendientes',
                  pendientes.length,
                  AppColors.pending,
                ),
                ...pendientes.map(_bookTile),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _bookTile(Book book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          BookCover(
            coverBase64: book.coverBase64,
            coverUrl: book.coverUrl,
            width: 36,
            height: 50,
            radius: 6,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${book.author} · ${book.year ?? "s/f"}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
