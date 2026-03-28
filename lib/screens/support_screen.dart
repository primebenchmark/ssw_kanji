import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/url_utils.dart';
import '../providers/app_state.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _launch(String url) async {
    if (!await launchUrlSafe(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appState = context.watch<AppState>();

    // Only show items whose URL is non-empty in config
    String url(String key) => appState.configValue(key, '');

    final contactItems = <Widget>[];
    if (url('contact_whatsapp_url').isNotEmpty) {
      contactItems.add(_SupportTile(
        icon: Icons.chat,
        color: const Color(0xFF25D366),
        title: 'WhatsApp',
        subtitle: 'Chat with us on WhatsApp',
        onTap: () => _launch(url('contact_whatsapp_url')),
      ));
    }
    if (url('contact_messenger_url').isNotEmpty) {
      contactItems.add(_SupportTile(
        icon: Icons.messenger_outline,
        color: const Color(0xFF006AFF),
        title: 'Messenger',
        subtitle: 'Message us on Messenger',
        onTap: () => _launch(url('contact_messenger_url')),
      ));
    }
    if (url('contact_viber_url').isNotEmpty) {
      contactItems.add(_SupportTile(
        icon: Icons.phone_in_talk_outlined,
        color: const Color(0xFF7360F2),
        title: 'Viber',
        subtitle: 'Chat with us on Viber',
        onTap: () => _launch(url('contact_viber_url')),
      ));
    }
    if (url('contact_telegram_url').isNotEmpty) {
      contactItems.add(_SupportTile(
        icon: Icons.send_outlined,
        color: const Color(0xFF229ED9),
        title: 'Telegram',
        subtitle: 'Message us on Telegram',
        onTap: () => _launch(url('contact_telegram_url')),
      ));
    }
    if (url('contact_phone').isNotEmpty) {
      contactItems.add(_SupportTile(
        icon: Icons.phone_outlined,
        color: colorScheme.primary,
        title: 'Phone Call',
        subtitle: 'Call our support line',
        onTap: () => _launch(url('contact_phone')),
      ));
    }
    if (url('contact_email').isNotEmpty) {
      contactItems.add(_SupportTile(
        icon: Icons.email_outlined,
        color: colorScheme.secondary,
        title: 'Email',
        subtitle: 'Send us an email',
        onTap: () => _launch(url('contact_email')),
      ));
    }

    final socialItems = <Widget>[];
    if (url('social_website_url').isNotEmpty) {
      socialItems.add(_SupportTile(
        icon: Icons.language,
        color: colorScheme.primary,
        title: 'Website',
        subtitle: 'Visit our website',
        onTap: () => _launch(url('social_website_url')),
      ));
    }
    if (url('social_facebook_url').isNotEmpty) {
      socialItems.add(_SupportTile(
        icon: Icons.facebook,
        color: const Color(0xFF1877F2),
        title: 'Facebook',
        subtitle: 'Follow us on Facebook',
        onTap: () => _launch(url('social_facebook_url')),
      ));
    }
    if (url('social_tiktok_url').isNotEmpty) {
      socialItems.add(_SupportTile(
        icon: Icons.music_note,
        color: const Color(0xFF000000),
        title: 'TikTok',
        subtitle: 'Follow us on TikTok',
        onTap: () => _launch(url('social_tiktok_url')),
      ));
    }
    if (url('social_instagram_url').isNotEmpty) {
      socialItems.add(_SupportTile(
        icon: Icons.camera_alt_outlined,
        color: const Color(0xFFE1306C),
        title: 'Instagram',
        subtitle: 'Follow us on Instagram',
        onTap: () => _launch(url('social_instagram_url')),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          if (contactItems.isNotEmpty) ...[
            const _SectionHeader(title: 'Contact Us'),
            ...contactItems,
          ],
          if (socialItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            const _SectionHeader(title: 'Follow Us'),
            ...socialItems,
          ],
          if (contactItems.isEmpty && socialItems.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No contact information available.')),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
