import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _booksRef =>
      _db.collection('books');

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _db.collection('users');

  // CREATE
  Future<void> addBook(Book book) async {
    final data = book.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    await _booksRef.add(data);
  }

  // READ (en tiempo real, solo los libros del usuario, ordenados por fecha)
  Stream<List<Book>> getUserBooks(String userId) {
    return _booksRef
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Book.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // UPDATE
  Future<void> updateBook(Book book) async {
    await _booksRef.doc(book.id).update(book.toMap());
  }

  // DELETE
  Future<void> deleteBook(String bookId) async {
    await _booksRef.doc(bookId).delete();
  }

  // Para el admin: todos los libros de todos los usuarios
  Stream<List<Book>> getAllBooks() {
    return _booksRef.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Book.fromMap(doc.id, doc.data())).toList(),
    );
  }

  // Todos los usuarios registrados (para el admin)
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _usersRef.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => {...doc.data(), 'uid': doc.id}).toList(),
    );
  }

  // Cambiar el rol de un usuario
  Future<void> updateUserRole(String uid, String newRole) async {
    await _usersRef.doc(uid).update({'role': newRole});
  }

  // Eliminar el registro de un usuario en Firestore
  // Nota: esto NO elimina su cuenta de Firebase Authentication.
  Future<void> deleteUserRecord(String uid) async {
    await _usersRef.doc(uid).delete();
  }

  // Contadores para el dashboard
  Future<int> countUsers() async {
    final snapshot = await _usersRef.count().get();
    return snapshot.count ?? 0;
  }

  Future<int> countBooks() async {
    final snapshot = await _booksRef.count().get();
    return snapshot.count ?? 0;
  }

  // Estadísticas de libros del usuario
  Future<Map<String, int>> getUserBookStats(String userId) async {
    final snapshot = await _booksRef.where('ownerId', isEqualTo: userId).get();

    final books = snapshot.docs.map(
      (d) => d.data()['status'] as String? ?? 'pendiente',
    );

    return {
      'leido': books.where((s) => s == 'leido').length,
      'leyendo': books.where((s) => s == 'leyendo').length,
      'pendiente': books.where((s) => s == 'pendiente').length,
    };
  }
}
