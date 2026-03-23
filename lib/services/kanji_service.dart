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
}
