import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/kanji_item.dart';
import '../services/kanji_service.dart';

class AppState extends ChangeNotifier {
  List<Category> _categories = [];
  Map<int, int> _itemCounts = {};
  Map<int, List<KanjiItem>> _itemsByCategory = {};
  final Set<int> _loadedCategories = {};
  final Set<int> _loadingCategories = {};
  Map<String, String> _appConfig = {};
  KanjiService? _service;

  ThemeMode _themeMode = ThemeMode.light;
  String _fontFamily = 'Noto Serif JP';
  double _kanjiSize = 32.0;
  double _meaningSize = 12.0;
  String _searchQuery = '';
  final Set<int> _expandedCategories = {};
  bool _isLoading = true;
  String? _error;

  int? _lastCategoryId;
  double _lastScrollOffset = 0.0;

  // Throttle preferences saves to avoid disk I/O spam during slider drags
  Timer? _saveTimer;

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get kanjiSize => _kanjiSize;
  double get meaningSize => _meaningSize;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Category> get categories => _categories;
  bool get isDark => _themeMode == ThemeMode.dark;
  int? get lastCategoryId => _lastCategoryId;
  double get lastScrollOffset => _lastScrollOffset;

  String configValue(String key, String defaultValue) {
    final v = _appConfig[key];
    return (v != null && v.isNotEmpty) ? v : defaultValue;
  }

  bool isCategoryExpanded(int id) => _expandedCategories.contains(id);
  bool isCategoryLoading(int id) => _loadingCategories.contains(id);

  List<KanjiItem> itemsForCategory(int categoryId) {
    final items = _itemsByCategory[categoryId] ?? [];
    if (_searchQuery.isEmpty) return items;
    return items.where((i) => i.matchesSearch(_searchQuery)).toList();
  }

  int itemCountForCategory(int categoryId) {
    // Use loaded items if available, fall back to pre-fetched counts
    return _itemsByCategory[categoryId]?.length ?? _itemCounts[categoryId] ?? 0;
  }

  bool categoryHasResults(int categoryId) {
    if (_searchQuery.isEmpty) return true;
    // If not yet loaded, optimistically show category (items may match once loaded)
    if (!_loadedCategories.contains(categoryId)) return true;
    final items = _itemsByCategory[categoryId] ?? [];
    return items.any((i) => i.matchesSearch(_searchQuery));
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _scheduleSave();
    notifyListeners();
  }

  void setFont(String font) {
    _fontFamily = font;
    _scheduleSave();
    notifyListeners();
  }

  void setKanjiSize(double size) {
    _kanjiSize = size;
    _scheduleSave();
    notifyListeners();
  }

  void setMeaningSize(double size) {
    _meaningSize = size;
    _scheduleSave();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      for (final cat in _categories) {
        _expandedCategories.add(cat.id);
        _loadCategoryItems(cat.id);
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
      _loadCategoryItems(id);
      _lastCategoryId = id;
      _scheduleSave();
    }
    notifyListeners();
  }

  void saveScrollOffset(double offset) {
    _lastScrollOffset = offset;
    _scheduleSave();
  }

  /// Expands and loads the last studied category after app data is loaded.
  void restoreLastCategory() {
    final id = _lastCategoryId;
    if (id != null && _categories.any((c) => c.id == id)) {
      _expandedCategories.add(id);
      _loadCategoryItems(id);
      notifyListeners();
    }
  }

  void _loadCategoryItems(int categoryId) {
    if (_loadedCategories.contains(categoryId)) return;
    if (_loadingCategories.contains(categoryId)) return;
    final service = _service;
    if (service == null) return;

    _loadingCategories.add(categoryId);
    notifyListeners();

    service.fetchItemsByCategory(categoryId).then((items) {
      _itemsByCategory[categoryId] = items;
      _loadedCategories.add(categoryId);
      _loadingCategories.remove(categoryId);
      notifyListeners();
    }).catchError((_) {
      _loadingCategories.remove(categoryId);
      notifyListeners();
    });
  }

  Future<void> loadData(KanjiService service) async {
    _isLoading = true;
    _error = null;
    _loadedCategories.clear();
    _loadingCategories.clear();
    _itemsByCategory = {};
    notifyListeners();

    try {
      _service = service;
      final results = await Future.wait([
        service.fetchCategories(),
        service.fetchItemCounts(),
        service.fetchAppConfig(),
      ]);
      _categories = results[0] as List<Category>;
      _itemCounts = results[1] as Map<int, int>;
      _appConfig = results[2] as Map<String, String>;
      _isLoading = false;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('SocketException') ||
          msg.contains('Failed host lookup') ||
          msg.contains('ClientException')) {
        _error = 'No internet connection. Please check your network and try again.';
      } else {
        _error = 'Failed to load data. Please try again.';
      }
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
    _kanjiSize = prefs.getDouble('kanjiSize') ?? 32.0;
    _meaningSize = prefs.getDouble('meaningSize') ?? 12.0;
    _lastCategoryId = prefs.getInt('lastCategoryId');
    _lastScrollOffset = prefs.getDouble('lastScrollOffset') ?? 0.0;
    notifyListeners();
  }

  /// Throttled save: coalesces rapid changes (e.g. slider drags) into one write
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _savePreferences);
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', _themeMode == ThemeMode.dark);
    await prefs.setString('fontFamily', _fontFamily);
    await prefs.setDouble('kanjiSize', _kanjiSize);
    await prefs.setDouble('meaningSize', _meaningSize);
    final categoryId = _lastCategoryId;
    if (categoryId != null) {
      await prefs.setInt('lastCategoryId', categoryId);
    } else {
      await prefs.remove('lastCategoryId');
    }
    await prefs.setDouble('lastScrollOffset', _lastScrollOffset);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    // Ensure final state is persisted
    _savePreferences();
    super.dispose();
  }
}
