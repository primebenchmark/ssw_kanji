import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/kanji_item.dart';

class KanjiService {
  final SupabaseClient _client;

  KanjiService(this._client);

  Future<List<Category>> fetchCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .order('sort_order');
    return data.map((e) => Category.fromJson(e)).toList();
  }

  Future<Map<int, int>> fetchItemCounts() async {
    final data = await _client.from('kanji_items').select('category_id');
    final counts = <int, int>{};
    for (final row in data) {
      final id = row['category_id'] as int;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }

  Future<List<KanjiItem>> fetchItemsByCategory(int categoryId) async {
    final data = await _client
        .from('kanji_items')
        .select()
        .eq('category_id', categoryId)
        .order('sort_order');
    return data.map((e) => KanjiItem.fromJson(e)).toList();
  }

  Future<Map<String, String>> fetchAppConfig() async {
    try {
      final data = await _client.from('app_config').select('key, value');
      return {
        for (final e in data)
          e['key'] as String: e['value'] as String? ?? ''
      };
    } catch (_) {
      return {};
    }
  }

  Future<void> updateConfigValue(String key, String value) async {
    await _client
        .from('app_config')
        .upsert({'key': key, 'value': value}, onConflict: 'key');
  }

  /// Returns all kanji items joined with their category name, ordered by
  /// category sort_order then item sort_order.
  Future<List<Map<String, dynamic>>> fetchAllKanjiItemsForExport() async {
    final data = await _client
        .from('kanji_items')
        .select('id, category_id, categories(name), kanji, reading, meaning, sort_order')
        .order('sort_order');
    return List<Map<String, dynamic>>.from(data);
  }

  /// Inserts rows into kanji_items in batches. Each map must have at minimum:
  /// category_id (int), kanji, reading, meaning. sort_order is optional.
  Future<int> bulkInsertKanjiItems(
    List<Map<String, dynamic>> rows, {
    int batchSize = 200,
  }) async {
    int inserted = 0;
    for (int i = 0; i < rows.length; i += batchSize) {
      final batch = rows.sublist(
        i,
        (i + batchSize).clamp(0, rows.length),
      );
      await _client.from('kanji_items').insert(batch);
      inserted += batch.length;
    }
    return inserted;
  }
}
