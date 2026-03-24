import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_state.dart';
import '../services/kanji_service.dart';
import '../widgets/category_card.dart';
import '../widgets/search_bar_widget.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = KanjiService(Supabase.instance.client);
      context.read<AppState>().loadData(service);
    });
  }

  String _buildShareText(AppState appState) {
    final appName = appState.configValue('app_name', 'SSW Kanji');
    final androidUrl = appState.configValue(
      'share_android_url',
      'https://play.google.com/store/apps/details?id=com.ssw.kanji',
    );
    final iosUrl = appState.configValue(
      'share_ios_url',
      'https://apps.apple.com/app/ssw-kanji',
    );
    return 'Check out $appName!\nAndroid: $androidUrl\niOS: $iosUrl';
  }

  Future<void> _share(BuildContext context) async {
    final appState = context.read<AppState>();
    final shareText = _buildShareText(appState);
    try {
      await SharePlus.instance.share(ShareParams(text: shareText));
    } catch (_) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Share ${appState.configValue('app_name', 'SSW Kanji')}'),
          content: SelectableText(shareText),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: shareText));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
              child: const Text('Copy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildFloatingHeader(AppState appState, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.04),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.65),
                        Colors.white.withValues(alpha: 0.35),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Glossy highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: _isSearching
                      ? Row(
                          children: [
                            Expanded(
                              child: KanjiSearchBar(
                                focusNode: _searchFocusNode,
                                onClose: () {
                                  setState(() => _isSearching = false);
                                  context
                                      .read<AppState>()
                                      .setSearchQuery('');
                                },
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/jftandskillmocktest.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appState.configValue(
                                        'app_name', 'SSW Kanji'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF2C3E50),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    appState.configValue(
                                      'app_by_text',
                                      'Prime Benchmark Private Limited',
                                    ),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark
                                          ? Colors.white54
                                          : const Color(0xFF5A6A7A),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            _AppBarIconButton(
                              icon: Icons.search,
                              label: 'Search',
                              onPressed: () {
                                setState(() => _isSearching = true);
                                WidgetsBinding.instance
                                    .addPostFrameCallback(
                                  (_) =>
                                      _searchFocusNode.requestFocus(),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            _AppBarIconButton(
                              icon: Icons.ios_share_outlined,
                              label: 'Share',
                              onPressed: () => _share(context),
                            ),
                            const SizedBox(width: 6),
                            _AppBarIconButton(
                              icon: Icons.phone_outlined,
                              label: 'Support',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SupportScreen()),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _AppBarIconButton(
                              icon: Icons.settings_outlined,
                              label: 'Settings',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SettingsScreen()),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          _buildFloatingHeader(appState, isDark),
          Expanded(child: _buildBody(appState)),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppState appState) {
    final year = DateTime.now().year;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        '\u00A9 $year ${appState.configValue('footer_text', 'Prime Benchmark Private Limited')} \u00B7 ${appState.configValue('app_name', 'SSW Kanji')}',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? Colors.white38
              : const Color(0xFF5A6A7A).withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildBody(AppState appState) {
    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load data',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                appState.error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  final service = KanjiService(Supabase.instance.client);
                  appState.loadData(service);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final visibleCategories = appState.searchQuery.isEmpty
        ? appState.categories
        : appState.categories
              .where((c) => appState.categoryHasResults(c.id))
              .toList();

    return visibleCategories.isEmpty
        ? Center(
            child: Text(
              'No results found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(top: 4, bottom: 24),
            itemCount: visibleCategories.length + 1,
            itemBuilder: (context, index) {
              if (index == visibleCategories.length) {
                return _buildFooter(context, appState);
              }
              return CategoryCard(category: visibleCategories[index]);
            },
          );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white70 : const Color(0xFF3A4A5A);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
