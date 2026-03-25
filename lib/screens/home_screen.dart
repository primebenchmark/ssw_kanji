import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_state.dart';
import '../services/kanji_service.dart';
import '../widgets/category_card.dart';
import '../widgets/search_bar_widget.dart';
import 'settings_screen.dart';
import 'support_screen.dart';

// Cached decorations to avoid per-rebuild allocations
const _kHeaderBorderRadius = BorderRadius.all(Radius.circular(16));
const _kDarkHeaderDecoration = BoxDecoration(
  borderRadius: _kHeaderBorderRadius,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x14FFFFFF), Color(0x0AFFFFFF)],
  ),
  border: Border.fromBorderSide(BorderSide(color: Color(0x1FFFFFFF))),
);
const _kLightHeaderDecoration = BoxDecoration(
  borderRadius: _kHeaderBorderRadius,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xA6FFFFFF), Color(0x59FFFFFF)],
  ),
  border: Border.fromBorderSide(BorderSide(color: Color(0xCCFFFFFF))),
);
const _kDarkGlossDecoration = BoxDecoration(
  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
  ),
);
const _kLightGlossDecoration = BoxDecoration(
  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
  ),
);
final _kHeaderBlurFilter = ImageFilter.blur(sigmaX: 12, sigmaY: 12);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  double? _pendingScrollOffset;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      final service = KanjiService(Supabase.instance.client);
      appState.loadData(service).then((_) {
        if (!mounted) return;
        final offset = appState.lastScrollOffset;
        appState.restoreLastCategory();
        if (offset > 0) {
          setState(() => _pendingScrollOffset = offset);
        }
      });
    });
  }

  void _onScroll() {
    context.read<AppState>().saveScrollOffset(_scrollController.offset);
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
    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 8,
        ),
        child: ClipRRect(
          borderRadius: _kHeaderBorderRadius,
          child: BackdropFilter(
            filter: _kHeaderBlurFilter,
            child: Container(
              decoration: isDark
                  ? _kDarkHeaderDecoration
                  : _kLightHeaderDecoration,
              child: Stack(
                children: [
                  // Glossy highlight
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 30,
                    child: DecoratedBox(
                      decoration: isDark
                          ? _kDarkGlossDecoration
                          : _kLightGlossDecoration,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 4,
                      top: 12,
                      bottom: 12,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _isSearching
                          ? Row(
                              key: const ValueKey('search'),
                              children: [
                                Expanded(
                                  child: KanjiSearchBar(
                                    focusNode: _searchFocusNode,
                                    onClose: () {
                                      setState(() => _isSearching = false);
                                      context.read<AppState>().setSearchQuery('');
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              key: const ValueKey('header'),
                              children: [
                                Expanded(
                                  child: _HeaderTitleArea(
                                    appState: appState,
                                    isDark: isDark,
                                  ),
                                ),
                                _AppBarIconButton(
                                  icon: Icons.search,
                                  label: 'Search',
                                  onPressed: () {
                                    setState(() => _isSearching = true);
                                    WidgetsBinding.instance.addPostFrameCallback(
                                      (_) => _searchFocusNode.requestFocus(),
                                    );
                                  },
                                ),
                                const SizedBox(width: 2),
                                _AppBarIconButton(
                                  icon: Icons.ios_share_outlined,
                                  label: 'Share',
                                  onPressed: () => _share(context),
                                ),
                                const SizedBox(width: 2),
                                _AppBarIconButton(
                                  icon: Icons.phone_outlined,
                                  label: 'Support',
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SupportScreen(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                _AppBarIconButton(
                                  icon: Icons.settings_outlined,
                                  label: 'Setting',
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
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

    // Once the restored category finishes loading, jump to the saved scroll offset.
    final pendingOffset = _pendingScrollOffset;
    final lastCatId = appState.lastCategoryId;
    if (pendingOffset != null &&
        (lastCatId == null || !appState.isCategoryLoading(lastCatId))) {
      _pendingScrollOffset = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            pendingOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
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
    final footerLinkUrl = appState.configValue('footer_link_url', '');
    final text = Padding(
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
    if (footerLinkUrl.isEmpty) return text;
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(footerLinkUrl),
        mode: LaunchMode.externalApplication,
      ),
      child: text,
    );
  }

  Widget _buildBody(AppState appState) {
    if (appState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appState.error != null) {
      return RefreshIndicator(
        onRefresh: () async {
          final service = KanjiService(Supabase.instance.client);
          await appState.loadData(service);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
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
            ),
          ),
        ),
      );
    }

    final visibleCategories = appState.searchQuery.isEmpty
        ? appState.categories
        : appState.categories
              .where((c) => appState.categoryHasResults(c.id))
              .toList();

    Future<void> onRefresh() async {
      final service = KanjiService(Supabase.instance.client);
      await appState.loadData(service);
    }

    if (visibleCategories.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Text(
                'No results found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 24),
        itemCount: visibleCategories.length + 1,
        itemBuilder: (context, index) {
          if (index == visibleCategories.length) {
            return _buildFooter(context, appState);
          }
          final cat = visibleCategories[index];
          return CategoryCard(
            key: ValueKey(cat.id),
            category: cat,
          );
        },
      ),
    );
  }
}

class _HeaderTitleArea extends StatelessWidget {
  const _HeaderTitleArea({required this.appState, required this.isDark});

  final AppState appState;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final headerLinkUrl = appState.configValue('header_link_url', '');
    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appState.configValue('app_name', 'SSW Kanji'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF2C3E50),
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          appState.configValue('app_by_text', 'Prime Benchmark Private Limited'),
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white54 : const Color(0xFF5A6A7A),
            fontWeight: FontWeight.w400,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );

    if (headerLinkUrl.isEmpty) return column;

    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(headerLinkUrl),
        mode: LaunchMode.externalApplication,
      ),
      child: column,
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
        padding: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 1),
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
