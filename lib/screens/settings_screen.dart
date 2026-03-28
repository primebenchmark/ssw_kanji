import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/url_utils.dart';
import '../providers/app_state.dart';
import 'admin_panel_screen.dart';
import 'privacy_policy_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _adminTapCount = 0;

  void _onAdminTap() {
    setState(() => _adminTapCount++);
    if (_adminTapCount >= 10) {
      _adminTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminPanelScreen()),
      );
    }
  }

  // (fontFamily, displayName) — all support Japanese characters via Google Fonts
  static const _fonts = [
    ('Noto Sans JP', 'Noto Sans JP'),
    ('Noto Serif JP', 'Noto Serif JP'),
    ('M PLUS 1p', 'M PLUS 1p'),
    ('M PLUS Rounded 1c', 'M PLUS Rounded 1c'),
    ('M PLUS 1', 'M PLUS 1'),
    ('M PLUS 2', 'M PLUS 2'),
    ('M PLUS 1 Code', 'M PLUS 1 Code'),
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
    ('BIZ UDGothic', 'BIZ UDGothic'),
    ('BIZ UDMincho', 'BIZ UDMincho'),
    ('Hina Mincho', 'Hina Mincho'),
    ('Zen Kaku Gothic New', 'Zen Kaku Gothic New'),
    ('Zen Kaku Gothic Antique', 'Zen Kaku Gothic Antique'),
    ('Zen Old Mincho', 'Zen Old Mincho'),
    ('Zen Maru Gothic', 'Zen Maru Gothic'),
    ('Zen Antique', 'Zen Antique'),
    ('Zen Antique Soft', 'Zen Antique Soft'),
    ('Zen Loop', 'Zen Loop'),
    ('Shippori Mincho', 'Shippori Mincho'),
    ('Shippori Mincho B1', 'Shippori Mincho B1'),
    ('Shippori Antique', 'Shippori Antique'),
    ('Shippori Antique B1', 'Shippori Antique B1'),
    ('Dela Gothic One', 'Dela Gothic One'),
    ('DotGothic16', 'DotGothic16'),
    ('Murecho', 'Murecho'),
    ('RocknRoll One', 'RocknRoll One'),
    ('Reggae One', 'Reggae One'),
    ('New Tegomin', 'New Tegomin'),
    ('Yusei Magic', 'Yusei Magic'),
    ('Stick', 'Stick'),
    ('Train One', 'Train One'),
    ('Potta One', 'Potta One'),
    ('Rampart One', 'Rampart One'),
    ('Hachi Maru Pop', 'Hachi Maru Pop'),
    ('Yomogi', 'Yomogi'),
    ('Yuji Boku', 'Yuji Boku'),
    ('Yuji Mai', 'Yuji Mai'),
    ('Yuji Syuku', 'Yuji Syuku'),
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
    final savedFont = appState.fontFamily;
    final validFontValues = _fonts.map((e) => e.$1).toSet();
    final currentFont = validFontValues.contains(savedFont) ? savedFont : _fonts.first.$1;
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
          // Theme toggle
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
                    FadeTransition(opacity: animation, child: child),
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
          for (int i = 1; i <= (int.tryParse(appState.configValue('more_apps_count', '1')) ?? 1).clamp(0, 20); i++)
            _PromoAppCard(
              logoUrl: appState.configValue('more_apps_${i}_logo_url', ''),
              name: appState.configValue('more_apps_${i}_name', ''),
              description: appState.configValue('more_apps_${i}_description', ''),
              installUrl: appState.configValue('more_apps_${i}_url', ''),
            ),

          // Size sliders
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  _SizeSliderRow(
                    icon: Icons.format_size,
                    label: 'Kanji Size',
                    value: appState.kanjiSize,
                    min: 20.0,
                    max: 60.0,
                    onChanged: (v) => context.read<AppState>().setKanjiSize(v),
                  ),
                  const Divider(height: 24),
                  _SizeSliderRow(
                    icon: Icons.text_fields,
                    label: 'Meaning Size',
                    value: appState.meaningSize,
                    min: 8.0,
                    max: 24.0,
                    onChanged: (v) => context.read<AppState>().setMeaningSize(v),
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

          // Data section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              'Data',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.delete_sweep_outlined),
              title: const Text('Clear App Data'),
              subtitle: const Text('Reset all local settings and preferences'),
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    final controller = TextEditingController();
                    return StatefulBuilder(
                      builder: (ctx, setState) => AlertDialog(
                        title: const Text('Clear App Data'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'This will reset all local settings and preferences on this device, including theme, font, sizes, and memorised items. This cannot be undone.',
                            ),
                            const SizedBox(height: 16),
                            const Text('Type DELETE to confirm:'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: 'DELETE',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: controller.text == 'DELETE'
                                ? () => Navigator.pop(ctx, true)
                                : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              foregroundColor: colorScheme.onError,
                              disabledBackgroundColor:
                                  colorScheme.error.withValues(alpha: 0.38),
                              disabledForegroundColor:
                                  colorScheme.onError.withValues(alpha: 0.38),
                            ),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                );
                if (confirmed == true && context.mounted) {
                  await context.read<AppState>().clearAllData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('App data cleared')),
                    );
                  }
                }
              },
            ),
          ),

          // Admin section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Text(
              'Admin',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Admin Panel'),
              subtitle: const Text('Manage app content and appearance'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _onAdminTap,
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PromoAppCard extends StatelessWidget {
  final String logoUrl;
  final String name;
  final String description;
  final String installUrl;

  const _PromoAppCard({
    required this.logoUrl,
    required this.name,
    required this.description,
    required this.installUrl,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (name.isEmpty && installUrl.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholderIcon(colorScheme),
                    )
                  : _placeholderIcon(colorScheme),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                  if (installUrl.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => launchUrlSafe(installUrl),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Install Now'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon(ColorScheme colorScheme) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.apps, color: colorScheme.onSurfaceVariant, size: 28),
    );
  }
}

class _SizeSliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SizeSliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(label, style: textTheme.bodyLarge),
            const Spacer(),
            Text(
              value.round().toString(),
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
