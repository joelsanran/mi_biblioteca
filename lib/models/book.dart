import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final int? year;
  final String coverUrl;
  final String coverBase64;
  final String status; // 'pendiente', 'leyendo', 'leido'
  final String ownerId;
  final DateTime? createdAt;
  final int? rating; // 1 a 5, solo si está leído
  final String review; // opinión, solo si está leído
  final int? currentPage; // solo si está leyendo

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.year,
    required this.coverUrl,
    this.coverBase64 = '',
    required this.status,
    required this.ownerId,
    this.createdAt,
    this.rating,
    this.review = '',
    this.currentPage,
  });

  factory Book.fromMap(String id, Map<String, dynamic> data) {
    return Book(
      id: id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      year: data['year'],
      coverUrl: data['coverUrl'] ?? '',
      coverBase64: data['coverBase64'] ?? '',
      status: data['status'] ?? 'pendiente',
      ownerId: data['ownerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      rating: (data['rating'] as num?)?.toInt(),
      review: data['review'] ?? '',
      currentPage: (data['currentPage'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'year': year,
      'coverUrl': coverUrl,
      'coverBase64': coverBase64,
      'status': status,
      'ownerId': ownerId,
      'rating': rating,
      'review': review,
      'currentPage': currentPage,
    };
  }
}