import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/kanji_item.dart';
import '../providers/app_state.dart';
import 'kanji_item_tile.dart';

// Cached static values to avoid per-rebuild allocations
const _kBorderRadius16 = BorderRadius.all(Radius.circular(16));
const _kBorderRadius8 = BorderRadius.all(Radius.circular(8));
const _kBorderRadiusTop16 = BorderRadius.vertical(top: Radius.circular(16));

// Lightweight glassmorphism: semi-transparent fills instead of BackdropFilter
const _kDarkCardDecoration = BoxDecoration(
  borderRadius: _kBorderRadius16,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x28374A5F), Color(0x1A2A3D52)],
  ),
  border: Border.fromBorderSide(BorderSide(color: Color(0x1FFFFFFF))),
);

const _kLightCardDecoration = BoxDecoration(
  borderRadius: _kBorderRadius16,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xB8FFFFFF), Color(0x80FFFFFF)],
  ),
  border: Border.fromBorderSide(BorderSide(color: Color(0xCCFFFFFF))),
);

const _kDarkHighlightDecoration = BoxDecoration(
  borderRadius: _kBorderRadiusTop16,
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x14FFFFFF), Color(0x00FFFFFF)],
  ),
);

const _kLightHighlightDecoration = BoxDecoration(
  borderRadius: _kBorderRadiusTop16,
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x66FFFFFF), Color(0x00FFFFFF)],
  ),
);

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use context.select so this card only rebuilds when its own data changes,
    // not on every AppState notification (memorized items, search query, etc.)
    final isExpanded = context.select<AppState, bool>((s) => s.isCategoryExpanded(category.id));
    final totalCount = context.select<AppState, int>((s) => s.itemCountForCategory(category.id));
    final isLoading = context.select<AppState, bool>((s) => s.isCategoryLoading(category.id));
    final vertPaddingStr = context.select<AppState, String>((s) => s.configValue('category_card_vertical_padding', '16'));
    final cardRadiusStr = context.select<AppState, String>((s) => s.configValue('category_card_border_radius', '16'));
    final categoryFontKey = context.select<AppState, String>((s) => s.configValue('category_font', ''));

    final vertPadding = (double.tryParse(vertPaddingStr) ?? 16.0).clamp(0.0, 64.0);
    final cardRadius = (double.tryParse(cardRadiusStr) ?? 16.0).clamp(0.0, 64.0);
    final borderRadius16 = BorderRadius.all(Radius.circular(cardRadius));
    final borderRadiusTop16 = BorderRadius.vertical(top: Radius.circular(cardRadius));
    final cardDecoration = (isDark ? _kDarkCardDecoration : _kLightCardDecoration)
        .copyWith(borderRadius: borderRadius16);
    final highlightDecoration = (isDark ? _kDarkHighlightDecoration : _kLightHighlightDecoration)
        .copyWith(borderRadius: borderRadiusTop16);
    final baseStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: isDark ? const Color(0xE6FFFFFF) : const Color(0xFF2C3E50),
    );
    TextStyle? categoryNameStyle = baseStyle;
    if (categoryFontKey.isNotEmpty) {
      try {
        categoryNameStyle = GoogleFonts.getFont(categoryFontKey, textStyle: baseStyle);
      } catch (_) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: cardDecoration,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 40,
                child: ClipRRect(
                  borderRadius: borderRadiusTop16,
                  child: DecoratedBox(
                    decoration: highlightDecoration,
                  ),
                ),
              ),
              Column(
                children: [
                  InkWell(
                    borderRadius: borderRadius16,
                    onTap: () => context.read<AppState>().toggleCategory(category.id),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: vertPadding),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: categoryNameStyle,
                            ),
                          ),
                          if (totalCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF4A6280)
                                    : const Color(0xFFABBDD0),
                                borderRadius: _kBorderRadius8,
                              ),
                              child: Text(
                                '$totalCount',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF3A5068),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          const SizedBox(width: 10),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.expand_more,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF5A6A7A),
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // AnimatedSize is much lighter than AnimatedCrossFade:
                  // it only keeps one child and smoothly animates the clip.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.hardEdge,
                    child: isExpanded
                        ? isLoading
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: isDark
                                          ? Colors.white54
                                          : const Color(0xFF5A6A7A),
                                    ),
                                  ),
                                ),
                              )
                            : _ExpandedContent(
                                key: ValueKey('expanded_${category.id}'),
                                category: category,
                              )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extracted expanded content to avoid rebuilding item lists
/// when the card header changes.
class _ExpandedContent extends StatelessWidget {
  final Category category;

  const _ExpandedContent({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    // Rebuilds only when items for this category change (load or search filter)
    final items = context.select<AppState, List<KanjiItem>>(
      (s) => s.itemsForCategory(category.id),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildGrid(items, 2);
          }
          return _buildList(items);
        },
      ),
    );
  }

  Widget _buildList(List items) {
    return Column(
      children: [
        for (final item in items)
          KanjiItemTile(key: ValueKey(item.id), item: item),
      ],
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
                    ? KanjiItemTile(key: ValueKey(rowItems[j].id), item: rowItems[j])
                    : const SizedBox.shrink(),
              ),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}
