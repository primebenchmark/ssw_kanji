import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_state.dart';
import '../services/kanji_service.dart';

// Config field metadata (schema lives in code; only key+value go to DB)
class _ConfigField {
  final String key;
  final String label;
  final String type; // 'text' | 'url' | 'multiline' | 'number' | 'font'
  final String defaultValue;

  const _ConfigField({
    required this.key,
    required this.label,
    required this.type,
    required this.defaultValue,
  });
}

const _sections = <String, List<_ConfigField>>{
  'App Info': [
    _ConfigField(key: 'app_name', label: 'App Name', type: 'text', defaultValue: 'SSW Kanji'),
    _ConfigField(key: 'app_by_text', label: 'App Subtitle (e.g. "by Company Name")', type: 'text', defaultValue: 'by Prime Benchmark Private Limited'),
    _ConfigField(key: 'app_description', label: 'App Description', type: 'multiline', defaultValue: ''),
    _ConfigField(key: 'footer_text', label: 'Footer Company Name', type: 'text', defaultValue: 'Prime Benchmark Private Limited'),
    _ConfigField(key: 'share_android_url', label: 'Android Store URL', type: 'url', defaultValue: 'https://play.google.com/store/apps/details?id=com.ssw.kanji'),
    _ConfigField(key: 'share_ios_url', label: 'iOS Store URL', type: 'url', defaultValue: 'https://apps.apple.com/app/ssw-kanji'),
  ],
  'Promotion': [
    _ConfigField(key: 'more_apps_name', label: 'App Name', type: 'text', defaultValue: 'JFT & Skill Mock Test'),
    _ConfigField(key: 'more_apps_description', label: 'App Description', type: 'multiline', defaultValue: 'Prepare for JFT-Basic and Skill Test with our mock test.'),
    _ConfigField(key: 'more_apps_url', label: 'Install URL', type: 'url', defaultValue: 'https://primebenchmark.com.np/app'),
  ],
  'Contact': [
    _ConfigField(key: 'contact_whatsapp_url', label: 'WhatsApp URL (leave empty to hide)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'contact_messenger_url', label: 'Messenger URL (leave empty to hide)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'contact_viber_url', label: 'Viber URL (leave empty to hide)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'contact_telegram_url', label: 'Telegram URL (leave empty to hide)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'contact_phone', label: 'Phone tel: URI (leave empty to hide)', type: 'text', defaultValue: ''),
    _ConfigField(key: 'contact_email', label: 'Email mailto: URI (leave empty to hide)', type: 'text', defaultValue: ''),
  ],
  'Social': [
    _ConfigField(key: 'social_website_url', label: 'Website URL (leave empty to hide)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'social_facebook_url', label: 'Facebook URL (leave empty to hide)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'social_tiktok_url', label: 'TikTok URL (leave empty to hide)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'social_instagram_url', label: 'Instagram URL (leave empty to hide)', type: 'url', defaultValue: ''),
  ],
  'Legal': [
    _ConfigField(key: 'privacy_policy_url', label: 'Privacy Policy URL', type: 'url', defaultValue: ''),
  ],
  'UI': [
    _ConfigField(key: 'category_card_vertical_padding', label: 'Category Card Vertical Padding', type: 'number', defaultValue: '16'),
    _ConfigField(key: 'kanji_item_vertical_padding', label: 'Kanji Item Vertical Padding', type: 'number', defaultValue: '12'),
    _ConfigField(key: 'category_font', label: 'Category Header Font', type: 'font', defaultValue: ''),
    _ConfigField(key: 'kanji_font', label: 'Kanji Character Font', type: 'font', defaultValue: ''),
  ],
};

const _availableFonts = [
  ('', 'Default (App Font)'),
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
  ('Roboto', 'Roboto'),
];

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  static const _pin = '02DF4e9be7c8*';

  bool _authenticated = false;
  late final KanjiService _service;

  @override
  void initState() {
    super.initState();
    _service = KanjiService(Supabase.instance.client);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPinDialog());
  }

  Future<void> _showPinDialog() async {
    final controller = TextEditingController();
    String? errorText;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Admin Access'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter PIN to access the admin panel.'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: true,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                onSubmitted: (_) {
                  if (controller.text == _pin) {
                    Navigator.pop(context, true);
                  } else {
                    setDialogState(() => errorText = 'Incorrect PIN');
                    controller.clear();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text == _pin) {
                  Navigator.pop(context, true);
                } else {
                  setDialogState(() => errorText = 'Incorrect PIN');
                  controller.clear();
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() => _authenticated = true);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _AdminContent(service: _service);
  }
}

// ─── Authenticated admin content ────────────────────────────────────────────

class _AdminContent extends StatefulWidget {
  final KanjiService service;
  const _AdminContent({required this.service});

  @override
  State<_AdminContent> createState() => _AdminContentState();
}

class _AdminContentState extends State<_AdminContent> {
  // controllers keyed by config key
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> _saving = {};
  final Set<String> _saved = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = context.read<AppState>();
    for (final fields in _sections.values) {
      for (final field in fields) {
        if (!_controllers.containsKey(field.key)) {
          _controllers[field.key] = TextEditingController(
            text: appState.configValue(field.key, field.defaultValue),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(String key, String value) async {
    setState(() {
      _saving.add(key);
      _saved.remove(key);
    });
    try {
      await context.read<AppState>().updateConfig(widget.service, key, value);
      if (mounted) {
        setState(() {
          _saving.remove(key);
          _saved.add(key);
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _saved.remove(key));
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving.remove(key));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final sectionEntries = _sections.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sectionEntries.length,
        itemBuilder: (context, si) {
          final section = sectionEntries[si];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Text(
                  section.key,
                  style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      for (int fi = 0; fi < section.value.length; fi++) ...[
                        if (fi > 0) const Divider(height: 28),
                        _buildFieldEditor(context, section.value[fi]),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFieldEditor(BuildContext context, _ConfigField field) {
    final isSaving = _saving.contains(field.key);
    final isSaved = _saved.contains(field.key);
    final controller = _controllers[field.key]!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.type == 'font')
          _FontDropdown(
            label: field.label,
            value: controller.text,
            onChanged: (v) => setState(() => controller.text = v),
          )
        else
          TextFormField(
            controller: controller,
            maxLines: field.type == 'multiline' ? 3 : 1,
            keyboardType: field.type == 'number'
                ? TextInputType.number
                : TextInputType.text,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              prefixIcon: _iconForType(field.type),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 32,
            child: isSaving
                ? const SizedBox(
                    width: 32,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : FilledButton.tonal(
                    onPressed: () => _save(field.key, controller.text),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: isSaved
                          ? colorScheme.secondaryContainer
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSaved) ...[
                          Icon(Icons.check, size: 16, color: colorScheme.onSecondaryContainer),
                          const SizedBox(width: 4),
                        ],
                        Text(isSaved ? 'Saved' : 'Save'),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Icon _iconForType(String type) {
    return switch (type) {
      'url' => const Icon(Icons.link),
      'number' => const Icon(Icons.straighten),
      'multiline' => const Icon(Icons.notes),
      _ => const Icon(Icons.text_fields),
    };
  }
}

// ─── Font dropdown ────────────────────────────────────────────────────────────

class _FontDropdown extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _FontDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  static TextStyle? _fontStyle(String fontFamily) {
    if (fontFamily.isEmpty) return null;
    try {
      return GoogleFonts.getFont(fontFamily, fontSize: 14);
    } catch (_) {
      return TextStyle(fontFamily: fontFamily, fontSize: 14);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.font_download_outlined),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButton<String>(
        value: _availableFonts.any((e) => e.$1 == value) ? value : '',
        isExpanded: true,
        underline: const SizedBox.shrink(),
        items: _availableFonts.map((entry) {
          final (fontKey, displayName) = entry;
          return DropdownMenuItem(
            value: fontKey,
            child: Text(
              displayName,
              style: _fontStyle(fontKey),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
