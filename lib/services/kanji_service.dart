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

  Future<List<KanjiItem>> fetchAllItems() async {
    final data = await _client
        .from('kanji_items')
        .select()
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
}
