import 'dart:convert';
import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/app_state.dart';
import '../services/kanji_service.dart';

// Config field metadata (schema lives in code; only key+value go to DB)
class _ConfigField {
  final String key;
  final String label;
  final String type; // 'text' | 'url' | 'image_url' | 'multiline' | 'number' | 'font' | 'slider'
  final String defaultValue;
  final double sliderMin;
  final double sliderMax;

  const _ConfigField({
    required this.key,
    required this.label,
    required this.type,
    required this.defaultValue,
    this.sliderMin = 0,
    this.sliderMax = 100,
  });
}

const _sections = <String, List<_ConfigField>>{
  'App Info': [
    _ConfigField(key: 'app_name', label: 'App Name', type: 'text', defaultValue: 'SSW Kanji'),
    _ConfigField(key: 'app_by_text', label: 'App Subtitle (e.g. "by Company Name")', type: 'text', defaultValue: 'by Prime Benchmark Private Limited'),
    _ConfigField(key: 'app_description', label: 'App Description', type: 'multiline', defaultValue: ''),
    _ConfigField(key: 'footer_text', label: 'Footer Company Name', type: 'text', defaultValue: 'Prime Benchmark Private Limited'),
    _ConfigField(key: 'footer_link_url', label: 'Footer Link URL (tap footer, leave empty to disable)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'share_android_url', label: 'Android Store URL', type: 'url', defaultValue: 'https://play.google.com/store/apps/details?id=com.ssw.kanji'),
    _ConfigField(key: 'share_ios_url', label: 'iOS Store URL', type: 'url', defaultValue: 'https://apps.apple.com/app/ssw-kanji'),
    _ConfigField(key: 'header_link_url', label: 'Header Link URL (tap left of nav bar, leave empty to disable)', type: 'url', defaultValue: ''),
    _ConfigField(key: 'header_bg_image_url', label: 'Header Background Image URL (leave empty to disable)', type: 'image_url', defaultValue: ''),
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
    _ConfigField(key: 'header_card_border_radius', label: 'Header Card Corner Radius', type: 'slider', defaultValue: '16', sliderMin: 0, sliderMax: 40),
    _ConfigField(key: 'category_card_border_radius', label: 'Category Card Corner Radius', type: 'slider', defaultValue: '16', sliderMin: 0, sliderMax: 40),
    _ConfigField(key: 'kanji_card_border_radius', label: 'Kanji & Meaning Card Corner Radius', type: 'slider', defaultValue: '12', sliderMin: 0, sliderMax: 32),
  ],
};

const _availableFonts = [
  ('', 'Default (App Font)'),
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
  final Set<String> _previewOpen = {};

  bool _notifImagePreviewOpen = false;

  final _notifTitleController = TextEditingController();
  final _notifBodyController = TextEditingController();
  final _notifImageController = TextEditingController();
  bool _sendingNotif = false;

  // Daily kanji notification state
  bool _dailyNotifEnabled = false;
  TimeOfDay _dailyNotifTime = const TimeOfDay(hour: 7, minute: 0);
  bool _savingDailyNotif = false;
  bool _savedDailyNotif = false;

  int get _promoCount => int.tryParse(_controllers['more_apps_count']?.text ?? '') ?? 1;

  void _ensurePromoControllers(AppState appState) {
    if (!_controllers.containsKey('more_apps_count')) {
      _controllers['more_apps_count'] = TextEditingController(
        text: appState.configValue('more_apps_count', '1'),
      );
    }
    final count = int.tryParse(appState.configValue('more_apps_count', '1')) ?? 1;
    for (int i = 1; i <= count; i++) {
      for (final suffix in ['logo_url', 'name', 'description', 'url']) {
        final key = 'more_apps_${i}_$suffix';
        if (!_controllers.containsKey(key)) {
          _controllers[key] = TextEditingController(
            text: appState.configValue(key, ''),
          );
        }
      }
    }
  }

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
    _ensurePromoControllers(appState);

    // Initialize daily kanji notification settings from app_config
    final enabledStr = appState.configValue('daily_notif_enabled', 'false');
    final timeStr = appState.configValue('daily_notif_time', '07:00');
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '7') ?? 7;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    _dailyNotifEnabled = enabledStr == 'true';
    _dailyNotifTime = TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _notifTitleController.dispose();
    _notifBodyController.dispose();
    _notifImageController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final title = _notifTitleController.text.trim();
    final body = _notifBodyController.text.trim();
    final image = _notifImageController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and body are required')),
      );
      return;
    }

    setState(() => _sendingNotif = true);
    try {
      final payload = <String, String>{'title': title, 'body': body};
      if (image.isNotEmpty) payload['image'] = image;

      final result = await Supabase.instance.client.functions.invoke(
        'send-notification',
        body: payload,
      );

      if (!mounted) return;

      final data = result.data as Map<String, dynamic>?;
      final sent = data?['sent'] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification sent to $sent device(s)'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      _notifTitleController.clear();
      _notifBodyController.clear();
      _notifImageController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sendingNotif = false);
    }
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildNotificationPanel(context),
          _buildDailyKanjiPanel(context),
          _CsvUploadPanel(service: widget.service),
          _CsvExportPanel(service: widget.service),
          _buildPromotionSection(context),
          for (final section in sectionEntries)
            Column(
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
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationPanel(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'Push Notifications',
            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _notifTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Notification Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notifBodyController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notification Body',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notifImageController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.image_outlined),
                    hintText: 'https://example.com/image.jpg',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 32,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(
                        () => _notifImagePreviewOpen = !_notifImagePreviewOpen,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        _notifImagePreviewOpen ? Icons.visibility_off : Icons.visibility,
                        size: 16,
                      ),
                      label: Text(_notifImagePreviewOpen ? 'Hide' : 'Preview'),
                    ),
                  ),
                ),
                if (_notifImagePreviewOpen) ...[
                  const SizedBox(height: 8),
                  _ImagePreview(url: _notifImageController.text),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _sendingNotif ? null : _sendNotification,
                  icon: _sendingNotif
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send),
                  label: Text(_sendingNotif ? 'Sending...' : 'Send Notification'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveDailyKanjiSettings() async {
    setState(() {
      _savingDailyNotif = true;
      _savedDailyNotif = false;
    });
    try {
      final appState = context.read<AppState>();
      final timeStr =
          '${_dailyNotifTime.hour.toString().padLeft(2, '0')}:${_dailyNotifTime.minute.toString().padLeft(2, '0')}';
      await appState.updateConfig(widget.service, 'daily_notif_enabled', _dailyNotifEnabled ? 'true' : 'false');
      await appState.updateConfig(widget.service, 'daily_notif_time', timeStr);
      if (mounted) {
        setState(() {
          _savingDailyNotif = false;
          _savedDailyNotif = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _savedDailyNotif = false);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _savingDailyNotif = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  Widget _buildDailyKanjiPanel(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final timeLabel =
        '${_dailyNotifTime.hour.toString().padLeft(2, '0')}:${_dailyNotifTime.minute.toString().padLeft(2, '0')} UTC';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'Daily Kanji Notification',
            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Daily Kanji'),
                  subtitle: const Text('Send a random kanji with reading & meaning each day'),
                  value: _dailyNotifEnabled,
                  onChanged: (v) => setState(() => _dailyNotifEnabled = v),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Send Time (UTC)', style: textTheme.bodyMedium),
                          Text(timeLabel, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _dailyNotifTime,
                          helpText: 'Select send time (UTC)',
                        );
                        if (picked != null) setState(() => _dailyNotifTime = picked);
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _savingDailyNotif ? null : _saveDailyKanjiSettings,
                  icon: _savingDailyNotif
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(_savedDailyNotif ? Icons.check : Icons.save_outlined),
                  label: Text(_savingDailyNotif
                      ? 'Saving...'
                      : _savedDailyNotif
                          ? 'Saved'
                          : 'Save Settings'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final appState = context.read<AppState>();
    final count = _promoCount;

    // Ensure controllers exist for current count
    for (int i = 1; i <= count; i++) {
      for (final suffix in ['logo_url', 'name', 'description', 'url']) {
        final key = 'more_apps_${i}_$suffix';
        if (!_controllers.containsKey(key)) {
          _controllers[key] = TextEditingController(
            text: appState.configValue(key, ''),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'Promotion',
            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Count field
                _buildFieldEditor(
                  context,
                  const _ConfigField(
                    key: 'more_apps_count',
                    label: 'Number of Promotional Apps',
                    type: 'number',
                    defaultValue: '1',
                  ),
                ),
                // Per-app fields
                for (int i = 1; i <= count; i++) ...[
                  const Divider(height: 32),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'App $i',
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.secondary),
                    ),
                  ),
                  _buildFieldEditor(context, _ConfigField(key: 'more_apps_${i}_logo_url', label: 'Logo URL', type: 'image_url', defaultValue: '')),
                  const Divider(height: 28),
                  _buildFieldEditor(context, _ConfigField(key: 'more_apps_${i}_name', label: 'App Name', type: 'text', defaultValue: '')),
                  const Divider(height: 28),
                  _buildFieldEditor(context, _ConfigField(key: 'more_apps_${i}_description', label: 'App Description', type: 'multiline', defaultValue: '')),
                  const Divider(height: 28),
                  _buildFieldEditor(context, _ConfigField(key: 'more_apps_${i}_url', label: 'Install URL', type: 'url', defaultValue: '')),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldEditor(BuildContext context, _ConfigField field) {
    final isSaving = _saving.contains(field.key);
    final isSaved = _saved.contains(field.key);
    final isImageUrl = field.type == 'image_url';
    final isPreviewOpen = _previewOpen.contains(field.key);
    final controller = _controllers[field.key]!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (field.type == 'slider')
          _buildSliderField(context, field)
        else if (field.type == 'font')
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
        if (field.type != 'slider') ...[
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isImageUrl) ...[
              SizedBox(
                height: 32,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() {
                    if (isPreviewOpen) {
                      _previewOpen.remove(field.key);
                    } else {
                      _previewOpen.add(field.key);
                    }
                  }),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    isPreviewOpen ? Icons.visibility_off : Icons.visibility,
                    size: 16,
                  ),
                  label: Text(isPreviewOpen ? 'Hide' : 'Preview'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            SizedBox(
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
                        backgroundColor: isSaved ? colorScheme.secondaryContainer : null,
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
          ],
        ),
        if (isImageUrl && isPreviewOpen) ...[
          const SizedBox(height: 8),
          _ImagePreview(url: controller.text),
        ],
        ],
      ],
    );
  }

  Widget _buildSliderField(BuildContext context, _ConfigField field) {
    final isSaving = _saving.contains(field.key);
    final isSaved = _saved.contains(field.key);
    final controller = _controllers[field.key]!;
    final colorScheme = Theme.of(context).colorScheme;
    final value = (double.tryParse(controller.text) ?? double.tryParse(field.defaultValue) ?? 0)
        .clamp(field.sliderMin, field.sliderMax);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(field.label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              value.toStringAsFixed(0),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        Slider(
          value: value,
          min: field.sliderMin,
          max: field.sliderMax,
          divisions: (field.sliderMax - field.sliderMin).toInt(),
          onChanged: (v) => setState(() => controller.text = v.toStringAsFixed(0)),
          onChangeEnd: (v) => _save(field.key, v.toStringAsFixed(0)),
        ),
        if (isSaving)
          const Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (isSaved)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text('Saved', style: TextStyle(fontSize: 12, color: colorScheme.primary)),
              ],
            ),
          ),
      ],
    );
  }

  Icon _iconForType(String type) {
    return switch (type) {
      'url' || 'image_url' => const Icon(Icons.link),
      'number' => const Icon(Icons.straighten),
      'multiline' => const Icon(Icons.notes),
      _ => const Icon(Icons.text_fields),
    };
  }
}

// ─── Image preview widget ─────────────────────────────────────────────────────

class _ImagePreview extends StatelessWidget {
  final String url;
  const _ImagePreview({required this.url});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (url.trim().isEmpty) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          'No URL entered',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url.trim(),
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 120,
            alignment: Alignment.center,
            color: colorScheme.surfaceContainerHighest,
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, _) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined, color: colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Text(
                'Could not load image',
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CSV Upload panel ─────────────────────────────────────────────────────────

class _CsvUploadPanel extends StatefulWidget {
  final KanjiService service;
  const _CsvUploadPanel({required this.service});

  @override
  State<_CsvUploadPanel> createState() => _CsvUploadPanelState();
}

class _CsvUploadPanelState extends State<_CsvUploadPanel> {
  List<Map<String, dynamic>>? _parsed;
  String? _fileName;
  String? _parseError;
  bool _uploading = false;
  String? _resultMessage;
  bool _resultIsError = false;

  static const _expectedHeaders = ['category_id', 'kanji', 'reading', 'meaning'];

  Future<void> _pickAndParse() async {
    setState(() {
      _parsed = null;
      _fileName = null;
      _parseError = null;
      _resultMessage = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) {
      setState(() => _parseError = 'Could not read file bytes.');
      return;
    }

    final content = utf8.decode(bytes, allowMalformed: true);
    final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();

    if (lines.isEmpty) {
      setState(() => _parseError = 'File is empty.');
      return;
    }

    // Detect if first line is a header
    final firstCols = _splitCsvLine(lines.first).map((c) => c.toLowerCase().trim()).toList();
    final hasHeader = _expectedHeaders.every((h) => firstCols.contains(h));
    final dataLines = hasHeader ? lines.skip(1).toList() : lines;

    // Determine column indices
    final int ciCategoryId = hasHeader ? firstCols.indexOf('category_id') : 0;
    final int ciKanji      = hasHeader ? firstCols.indexOf('kanji')       : 1;
    final int ciReading    = hasHeader ? firstCols.indexOf('reading')     : 2;
    final int ciMeaning    = hasHeader ? firstCols.indexOf('meaning')     : 3;
    final int ciSortOrder  = hasHeader ? firstCols.indexOf('sort_order')  : 4;

    final rows = <Map<String, dynamic>>[];
    final errors = <String>[];

    for (int i = 0; i < dataLines.length; i++) {
      final lineNum = hasHeader ? i + 2 : i + 1;
      final cols = _splitCsvLine(dataLines[i]);

      if (cols.length < 4) {
        errors.add('Line $lineNum: expected at least 4 columns, got ${cols.length}');
        continue;
      }

      final categoryId = int.tryParse(cols[ciCategoryId].trim());
      if (categoryId == null) {
        errors.add('Line $lineNum: category_id "${cols[ciCategoryId]}" is not a valid integer');
        continue;
      }

      final row = <String, dynamic>{
        'category_id': categoryId,
        'kanji': cols[ciKanji].trim(),
        'reading': cols[ciReading].trim(),
        'meaning': cols[ciMeaning].trim(),
      };

      if (ciSortOrder >= 0 && ciSortOrder < cols.length) {
        final so = int.tryParse(cols[ciSortOrder].trim());
        if (so != null) row['sort_order'] = so;
      }

      rows.add(row);
    }

    if (errors.isNotEmpty && rows.isEmpty) {
      setState(() => _parseError = errors.take(5).join('\n'));
      return;
    }

    setState(() {
      _parsed = rows;
      _fileName = file.name;
      if (errors.isNotEmpty) {
        _parseError = 'Skipped ${errors.length} invalid row(s). First error: ${errors.first}';
      }
    });
  }

  // Minimal CSV line splitter supporting double-quoted fields.
  static List<String> _splitCsvLine(String line) {
    final fields = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buf.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (ch == ',' && !inQuotes) {
        fields.add(buf.toString());
        buf.clear();
      } else {
        buf.write(ch);
      }
    }
    fields.add(buf.toString());
    return fields;
  }

  Future<void> _upload() async {
    final rows = _parsed;
    if (rows == null || rows.isEmpty) return;

    setState(() {
      _uploading = true;
      _resultMessage = null;
    });

    try {
      final count = await widget.service.bulkInsertKanjiItems(rows);
      if (mounted) {
        setState(() {
          _resultMessage = 'Successfully inserted $count row(s).';
          _resultIsError = false;
          _parsed = null;
          _fileName = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultMessage = 'Upload failed: $e';
          _resultIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'CSV Data Import',
            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Upload a CSV file to insert kanji items into the database.\n'
                  'Required columns: category_id, kanji, reading, meaning\n'
                  'Optional column: sort_order\n'
                  'A header row is auto-detected; column order follows the header.',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _pickAndParse,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_fileName != null ? _fileName! : 'Pick CSV File'),
                ),
                if (_parseError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _parseError!,
                    style: textTheme.bodySmall?.copyWith(
                      color: _parsed != null ? colorScheme.tertiary : colorScheme.error,
                    ),
                  ),
                ],
                if (_parsed != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    '${_parsed!.length} row(s) ready to insert.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _uploading ? null : _upload,
                    icon: _uploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_uploading ? 'Uploading…' : 'Upload to Supabase'),
                  ),
                ],
                if (_resultMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _resultMessage!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: _resultIsError ? colorScheme.error : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── CSV Export panel ─────────────────────────────────────────────────────────

class _CsvExportPanel extends StatefulWidget {
  final KanjiService service;
  const _CsvExportPanel({required this.service});

  @override
  State<_CsvExportPanel> createState() => _CsvExportPanelState();
}

class _CsvExportPanelState extends State<_CsvExportPanel> {
  bool _exporting = false;
  String? _resultMessage;
  bool _resultIsError = false;

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static String _buildCsv(List<Map<String, dynamic>> rows) {
    final buf = StringBuffer();
    buf.writeln('id,category_id,category_name,kanji,reading,meaning,sort_order');
    for (final row in rows) {
      final categoryName = (row['categories'] as Map<String, dynamic>?)?['name'] ?? '';
      buf.writeln([
        row['id']?.toString() ?? '',
        row['category_id']?.toString() ?? '',
        _escapeCsv(categoryName.toString()),
        _escapeCsv(row['kanji']?.toString() ?? ''),
        _escapeCsv(row['reading']?.toString() ?? ''),
        _escapeCsv(row['meaning']?.toString() ?? ''),
        row['sort_order']?.toString() ?? '',
      ].join(','));
    }
    return buf.toString();
  }

  Future<void> _export() async {
    setState(() {
      _exporting = true;
      _resultMessage = null;
    });

    try {
      final rows = await widget.service.fetchAllKanjiItemsForExport();
      final csv = _buildCsv(rows);
      final bytes = utf8.encode(csv);
      final fileName = 'kanji_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      final dir = await getTemporaryDirectory();
      final file = io.File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
          subject: 'Kanji Data Export',
        ),
      );

      if (mounted) {
        setState(() {
          _resultMessage = 'Exported ${rows.length} row(s).';
          _resultIsError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _resultMessage = 'Export failed: $e';
          _resultIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'CSV Data Export',
            style: textTheme.labelLarge?.copyWith(color: colorScheme.primary),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Download all kanji items as a CSV file.\n'
                  'Columns: id, category_id, category_name, kanji, reading, meaning, sort_order',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _exporting ? null : _export,
                  icon: _exporting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download),
                  label: Text(_exporting ? 'Exporting…' : 'Export as CSV'),
                ),
                if (_resultMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _resultMessage!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: _resultIsError ? colorScheme.error : colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
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
