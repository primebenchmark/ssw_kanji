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

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leadingWidth: 155,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.configValue('app_name', 'SSW Kanji'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  appState.configValue('app_by_text', 'by Prime Benchmark Private Limited'),
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        centerTitle: false,
        title: Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.6,
            child: KanjiSearchBar(),
          ),
        ),
        actions: [
          _AppBarIconButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onPressed: () => _share(context),
          ),
          _AppBarIconButton(
            icon: Icons.support_agent_outlined,
            label: 'Support',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SupportScreen()),
            ),
          ),
          _AppBarIconButton(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(appState),
    );
  }

  Widget _buildFooter(BuildContext context, AppState appState) {
    final year = DateTime.now().year;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        '© $year ${appState.configValue('footer_text', 'Prime Benchmark Private Limited')} · ${appState.configValue('app_name', 'SSW Kanji')}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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

    return Column(
      children: [
        Expanded(
          child: visibleCategories.isEmpty
              ? Center(
                  child: Text(
                    'No results found',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: visibleCategories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == visibleCategories.length) {
                      return _buildFooter(context, appState);
                    }
                    return CategoryCard(category: visibleCategories[index]);
                  },
                ),
        ),
      ],
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
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
