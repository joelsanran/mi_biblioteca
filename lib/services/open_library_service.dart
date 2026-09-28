import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';

class OpenLibraryService {
  Future<List<SearchResult>> searchBooks(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      'https://openlibrary.org/search.json?q=${Uri.encodeQueryComponent(query)}&limit=20',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error al buscar libros (código ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = data['docs'] as List? ?? [];

    return docs
        .map((doc) => SearchResult.fromJson(doc as Map<String, dynamic>))
        .toList();
  }
}
