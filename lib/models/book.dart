import 'package:cloud_firestore/cloud_firestore.dart';
class Book {
  final String id;
  final String title;
  final String author;
  final int? year;
  final String coverUrl;
  final String status;
  final String ownerId;
  final DateTime? createdAt; // nuevo

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.year,
    required this.coverUrl,
    required this.status,
    required this.ownerId,
    this.createdAt, // nuevo
  });

  factory Book.fromMap(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      year: data['year'],
      coverUrl: data['coverUrl'] ?? '',
      status: data['status'] ?? 'pendiente',
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(), // nuevo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'year': year,
      'coverUrl': coverUrl,
      'status': status,
      'ownerId': ownerId,
      // createdAt se agrega solo, no aquí (ver siguiente paso)
    };
  }
}