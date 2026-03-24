import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/app_state.dart';
import 'kanji_item_tile.dart';

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appState = context.watch<AppState>();
    final isExpanded = appState.isCategoryExpanded(category.id);
    final items = appState.itemsForCategory(category.id);
    final totalCount = appState.itemCountForCategory(category.id);

    final vertPadding = double.tryParse(
          appState.configValue('category_card_vertical_padding', '16'),
        ) ??
        16.0;
    final categoryFontKey = appState.configValue('category_font', '');
    TextStyle? categoryNameStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    );
    if (categoryFontKey.isNotEmpty) {
      try {
        categoryNameStyle = GoogleFonts.getFont(
          categoryFontKey,
          textStyle: categoryNameStyle,
        );
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surfaceContainer,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => appState.toggleCategory(category.id),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: vertPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      style: categoryNameStyle,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return _buildGrid(items, 2);
                  }
                  return _buildList(items);
                },
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List items) {
    return Column(
      children: items.map((item) => KanjiItemTile(item: item)).toList(),
    );
  }

  Widget _buildGrid(List items, int columns) {
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += columns) {
      final rowItems = items.skip(i).take(columns).toList();
      rows.add(
        Row(
          children: [
            for (var j = 0; j < columns; j++)
              Expanded(
                child: j < rowItems.length
                    ? KanjiItemTile(item: rowItems[j])
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}
