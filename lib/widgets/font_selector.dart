import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class FontSelector extends StatelessWidget {
  const FontSelector({super.key});

  static const _fonts = [
    ('Noto Sans JP', 'Sans Serif'),
    ('Noto Serif JP', 'Serif'),
    ('Roboto', 'Default'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentFont = context.watch<AppState>().fontFamily;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.font_download_outlined),
      tooltip: 'Change font',
      onSelected: (font) => context.read<AppState>().setFont(font),
      itemBuilder: (context) => _fonts.map((entry) {
        final (fontFamily, label) = entry;
        return PopupMenuItem<String>(
          value: fontFamily,
          child: Row(
            children: [
              if (fontFamily == currentFont)
                Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text('$label ($fontFamily)'),
            ],
          ),
        );
      }).toList(),
    );
  }
}
