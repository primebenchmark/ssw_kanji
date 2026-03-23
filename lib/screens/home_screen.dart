import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_state.dart';
import '../services/kanji_service.dart';
import '../widgets/category_card.dart';
import '../widgets/font_selector.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/theme_toggle.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final service = KanjiService(Supabase.instance.client);
    context.read<AppState>().loadData(service);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SSW Kanji',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: const [
          FontSelector(),
          ThemeToggle(),
          SizedBox(width: 4),
        ],
      ),
      body: _buildBody(appState),
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
        const KanjiSearchBar(),
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
                  itemCount: visibleCategories.length,
                  itemBuilder: (context, index) {
                    return CategoryCard(category: visibleCategories[index]);
                  },
                ),
        ),
      ],
    );
  }
}
