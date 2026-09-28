class SearchResult {
  final String title;
  final String author;
  final int? year;
  final String coverUrl;

  SearchResult({
    required this.title,
    required this.author,
    this.year,
    required this.coverUrl,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final authors = json['author_name'] as List?;
    final coverId = json['cover_i'];

    return SearchResult(
      title: json['title'] ?? 'Sin título',
      author: authors != null && authors.isNotEmpty
          ? authors.first
          : 'Autor desconocido',
      year: json['first_publish_year'],
      coverUrl: coverId != null
          ? 'https://covers.openlibrary.org/b/id/$coverId-M.jpg'
          : '',
    );
  }
}
