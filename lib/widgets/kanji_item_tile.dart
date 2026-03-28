import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/kanji_item.dart';
import '../providers/app_state.dart';

class KanjiItemTile extends StatelessWidget {
  final KanjiItem item;

  const KanjiItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use context.select to only rebuild when the specific values we use change,
    // not on every AppState notification (e.g. search query, expanded categories)
    final isMemorized = context.select<AppState, bool>((s) => s.isMemorized(item.id));
    final kanjiSize = context.select<AppState, double>((s) => s.kanjiSize);
    final meaningSize = context.select<AppState, double>((s) => s.meaningSize);
    final kanjiFontKey = context.select<AppState, String>(
      (s) => s.configValue('kanji_font', ''),
    );
    final vertPadding = context.select<AppState, double>(
      (s) => (double.tryParse(s.configValue('kanji_item_vertical_padding', '12')) ?? 12.0).clamp(0.0, 64.0),
    );
    final kanjiCardRadius = context.select<AppState, double>(
      (s) => (double.tryParse(s.configValue('kanji_card_border_radius', '12')) ?? 12.0).clamp(0.0, 64.0),
    );

    TextStyle? kanjiStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: kanjiSize,
      fontWeight: FontWeight.bold,
      color: isDark ? const Color(0xE6FFFFFF) : const Color(0xFF2C3E50),
    );
    if (kanjiFontKey.isNotEmpty) {
      try {
        kanjiStyle = GoogleFonts.getFont(kanjiFontKey, textStyle: kanjiStyle);
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () => context.read<AppState>().toggleMemorized(item.id),
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(kanjiCardRadius)),
        color: isMemorized
            ? const Color(0xFF2ECC71)
            : isDark ? const Color(0x0DFFFFFF) : const Color(0x4DFFFFFF),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(item.kanji, style: kanjiStyle),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.reading,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? const Color(0xFF8AAFDB)
                        : const Color(0xFF4A6FA5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.meaning,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: meaningSize,
                    color: isDark
                        ? Colors.white54
                        : const Color(0xFF5A6A7A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
