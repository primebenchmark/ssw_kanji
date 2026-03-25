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
    final appState = context.watch<AppState>();

    final vertPadding = double.tryParse(
          appState.configValue('kanji_item_vertical_padding', '12'),
        ) ??
        12.0;
    final kanjiFontKey = appState.configValue('kanji_font', '');
    TextStyle? kanjiStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: appState.kanjiSize,
      fontWeight: FontWeight.bold,
      color: isDark ? const Color(0xE6FFFFFF) : const Color(0xFF2C3E50),
    );
    if (kanjiFontKey.isNotEmpty) {
      try {
        kanjiStyle = GoogleFonts.getFont(kanjiFontKey, textStyle: kanjiStyle);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertPadding),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: isDark ? const Color(0x0DFFFFFF) : const Color(0x4DFFFFFF),
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
                    fontSize: appState.meaningSize,
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
    );
  }
}
