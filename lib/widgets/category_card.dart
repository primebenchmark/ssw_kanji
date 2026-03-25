import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/app_state.dart';
import 'kanji_item_tile.dart';

// Cached static values to avoid per-rebuild allocations
const _kBorderRadius16 = BorderRadius.all(Radius.circular(16));
const _kBorderRadius8 = BorderRadius.all(Radius.circular(8));
const _kBorderRadiusTop16 = BorderRadius.vertical(top: Radius.circular(16));

const _kDarkGradientColors = [Color(0x14FFFFFF), Color(0x0AFFFFFF)]; // 0.08, 0.04 alpha
const _kLightGradientColors = [Color(0xA6FFFFFF), Color(0x59FFFFFF)]; // 0.65, 0.35 alpha
const _kDarkBorderColor = Color(0x1FFFFFFF); // 0.12 alpha
const _kLightBorderColor = Color(0xCCFFFFFF); // 0.8 alpha
const _kDarkHighlightColor = Color(0x14FFFFFF); // 0.08 alpha
const _kLightHighlightColor = Color(0x66FFFFFF); // 0.4 alpha
const _kTransparent = Color(0x00FFFFFF);

const _kDarkCardDecoration = BoxDecoration(
  borderRadius: _kBorderRadius16,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _kDarkGradientColors,
  ),
  border: Border.fromBorderSide(BorderSide(color: _kDarkBorderColor)),
);

const _kLightCardDecoration = BoxDecoration(
  borderRadius: _kBorderRadius16,
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: _kLightGradientColors,
  ),
  border: Border.fromBorderSide(BorderSide(color: _kLightBorderColor)),
);

const _kDarkHighlightDecoration = BoxDecoration(
  borderRadius: _kBorderRadiusTop16,
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_kDarkHighlightColor, _kTransparent],
  ),
);

const _kLightHighlightDecoration = BoxDecoration(
  borderRadius: _kBorderRadiusTop16,
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_kLightHighlightColor, _kTransparent],
  ),
);

final _kBlurFilter = ImageFilter.blur(sigmaX: 12, sigmaY: 12);

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final isExpanded = appState.isCategoryExpanded(category.id);
    final items = appState.itemsForCategory(category.id);
    final totalCount = appState.itemCountForCategory(category.id);
    final isDark = theme.brightness == Brightness.dark;

    final vertPadding = double.tryParse(
          appState.configValue('category_card_vertical_padding', '16'),
        ) ??
        16.0;
    final categoryFontKey = appState.configValue('category_font', '');
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
      child: ClipRRect(
        borderRadius: _kBorderRadius16,
        child: BackdropFilter(
          filter: _kBlurFilter,
          child: Container(
            decoration: isDark ? _kDarkCardDecoration : _kLightCardDecoration,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: DecoratedBox(
                    decoration: isDark ? _kDarkHighlightDecoration : _kLightHighlightDecoration,
                  ),
                ),
                Column(
                  children: [
                    InkWell(
                      borderRadius: _kBorderRadius16,
                      onTap: () => appState.toggleCategory(category.id),
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
              ],
            ),
          ),
        ),
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
