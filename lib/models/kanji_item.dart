class KanjiItem {
  final int id;
  final int categoryId;
  final String kanji;
  final String reading;
  final String meaning;
  final int sortOrder;

  const KanjiItem({
    required this.id,
    required this.categoryId,
    required this.kanji,
    required this.reading,
    required this.meaning,
    required this.sortOrder,
  });

  factory KanjiItem.fromJson(Map<String, dynamic> json) => KanjiItem(
        id: json['id'] as int,
        categoryId: json['category_id'] as int,
        kanji: json['kanji'] as String,
        reading: json['reading'] as String,
        meaning: json['meaning'] as String,
        sortOrder: json['sort_order'] as int,
      );

  bool matchesSearch(String query) {
    final q = query.toLowerCase();
    return kanji.toLowerCase().contains(q) ||
        reading.toLowerCase().contains(q) ||
        meaning.toLowerCase().contains(q);
  }
}
