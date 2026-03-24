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
    final colorScheme = theme.colorScheme;
    final appState = context.watch<AppState>();

    final vertPadding = double.tryParse(
          appState.configValue('kanji_item_vertical_padding', '12'),
        ) ??
        12.0;
    final kanjiFontKey = appState.configValue('kanji_font', '');
    TextStyle? kanjiStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );
    if (kanjiFontKey.isNotEmpty) {
      try {
        kanjiStyle = GoogleFonts.getFont(kanjiFontKey, textStyle: kanjiStyle);
      } catch (_) {}
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: vertPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              item.kanji,
              style: kanjiStyle,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.reading,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.meaning,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
