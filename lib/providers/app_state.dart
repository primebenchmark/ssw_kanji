import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/kanji_item.dart';
import '../services/kanji_service.dart';

class AppState extends ChangeNotifier {
  List<Category> _categories = [];
  List<KanjiItem> _allItems = [];
  Map<int, List<KanjiItem>> _itemsByCategory = {};
  Map<String, String> _appConfig = {};

  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Noto Serif JP';
  String _searchQuery = '';
  final Set<int> _expandedCategories = {};
  bool _isLoading = true;
  String? _error;

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Category> get categories => _categories;

  String configValue(String key, String defaultValue) {
    final v = _appConfig[key];
    return (v != null && v.isNotEmpty) ? v : defaultValue;
  }

  bool isCategoryExpanded(int id) => _expandedCategories.contains(id);

  List<KanjiItem> itemsForCategory(int categoryId) {
    final items = _itemsByCategory[categoryId] ?? [];
    if (_searchQuery.isEmpty) return items;
    return items.where((i) => i.matchesSearch(_searchQuery)).toList();
  }

  int itemCountForCategory(int categoryId) {
    return _itemsByCategory[categoryId]?.length ?? 0;
  }

  bool categoryHasResults(int categoryId) {
    if (_searchQuery.isEmpty) return true;
    final items = _itemsByCategory[categoryId] ?? [];
    return items.any((i) => i.matchesSearch(_searchQuery));
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _savePreferences();
    notifyListeners();
  }

  void setFont(String font) {
    _fontFamily = font;
    _savePreferences();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      for (final cat in _categories) {
        _expandedCategories.add(cat.id);
      }
    } else {
      _expandedCategories.clear();
    }
    notifyListeners();
  }

  void toggleCategory(int id) {
    if (_expandedCategories.contains(id)) {
      _expandedCategories.remove(id);
    } else {
      _expandedCategories.add(id);
    }
    notifyListeners();
  }

  Future<void> loadData(KanjiService service) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await service.fetchCategories();
      _allItems = await service.fetchAllItems();
      _appConfig = await service.fetchAppConfig();
      _itemsByCategory = {};
      for (final item in _allItems) {
        _itemsByCategory.putIfAbsent(item.categoryId, () => []).add(item);
      }
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> updateConfig(KanjiService service, String key, String value) async {
    await service.updateConfigValue(key, value);
    _appConfig[key] = value;
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _fontFamily = prefs.getString('fontFamily') ?? 'Noto Serif JP';
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
    await prefs.setString('fontFamily', _fontFamily);
  }
}
