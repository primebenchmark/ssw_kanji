import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // (fontFamily, displayName) — all support Japanese characters via Google Fonts
  static const _fonts = [
    ('Noto Sans JP', 'Noto Sans JP'),
    ('Noto Serif JP', 'Noto Serif JP'),
    ('M PLUS 1p', 'M PLUS 1p'),
    ('M PLUS Rounded 1c', 'M PLUS Rounded 1c'),
    ('Kosugi', 'Kosugi'),
    ('Kosugi Maru', 'Kosugi Maru'),
    ('Sawarabi Gothic', 'Sawarabi Gothic'),
    ('Sawarabi Mincho', 'Sawarabi Mincho'),
    ('Kaisei Decol', 'Kaisei Decol'),
    ('Kaisei HarunoUmi', 'Kaisei HarunoUmi'),
    ('Kaisei Opti', 'Kaisei Opti'),
    ('Kaisei Tokumin', 'Kaisei Tokumin'),
    ('Klee One', 'Klee One'),
    ('BIZ UDPGothic', 'BIZ UDPGothic'),
    ('BIZ UDPMincho', 'BIZ UDPMincho'),
    ('Hina Mincho', 'Hina Mincho'),
    ('Zen Kaku Gothic New', 'Zen Kaku Gothic New'),
    ('Zen Old Mincho', 'Zen Old Mincho'),
    ('Shippori Mincho', 'Shippori Mincho'),
    ('Roboto', 'Roboto (Default)'),
  ];

  static const _previewText = '漢字・かな・カナ — The quick brown fox';

  static TextStyle? _fontStyle(String fontFamily, {double? fontSize, FontWeight? fontWeight}) {
    try {
      return GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        fontWeight: fontWeight,
      );
    } catch (_) {
      return TextStyle(fontFamily: fontFamily, fontSize: fontSize, fontWeight: fontWeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark = appState.themeMode == ThemeMode.dark;
    final currentFont = appState.fontFamily;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Theme section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Appearance',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SwitchListTile(
              secondary: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    RotationTransition(turns: animation, child: child),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  key: ValueKey(isDark),
                ),
              ),
              title: const Text('Dark Mode'),
              subtitle: Text(
                isDark ? 'Dark theme enabled' : 'Light theme enabled',
              ),
              value: isDark,
              onChanged: (_) => context.read<AppState>().toggleTheme(),
            ),
          ),

          // Font section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              'Font',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Select Font',
                      prefixIcon: const Icon(Icons.font_download_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: DropdownButton<String>(
                      value: currentFont,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: _fonts.map((entry) {
                        final (fontFamily, displayName) = entry;
                        return DropdownMenuItem(
                          value: fontFamily,
                          child: Text(
                            displayName,
                            style: _fontStyle(fontFamily, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (font) {
                        if (font != null) context.read<AppState>().setFont(font);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _previewText,
                          style: _fontStyle(currentFont, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '一二三四五六七八九十百千万',
                          style: _fontStyle(currentFont, fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'あいうえお・アイウエオ',
                          style: _fontStyle(currentFont, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Other apps section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              'More from Prime Benchmark Private Limited',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/jftandskillmocktest.png',
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JFT & Skill Mock Test',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Prepare for JFT-Basic and Skill Test with our mock test. JFT-Basic, Food, Nursing(JP/NP), Agri(Crop/Live), Acco, Cons, Building Cleaning, Ground Handling',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () => launchUrl(
                            Uri.parse('https://primebenchmark.com.np/app'),
                            mode: LaunchMode.externalApplication,
                          ),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 32),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Install Now'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Legal section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              'Legal',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
