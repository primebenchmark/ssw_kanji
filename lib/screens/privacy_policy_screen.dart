import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Effective Date: March 25, 2026',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            _section(
              context,
              title: '1. Information We Collect',
              body:
                  'SSW Kanji does not collect any personally identifiable information. '
                  'We do not require account registration or login.\n\n'
                  'The only data stored on your device is your app preferences (theme and font selection), '
                  'which are saved locally using shared preferences and never transmitted.\n\n'
                  'If you opt in to push notifications, a Firebase-assigned device token is registered '
                  'with Firebase Cloud Messaging solely to deliver notifications. This token is not '
                  'linked to any personal identity.',
            ),
            _section(
              context,
              title: '2. Data Storage',
              body:
                  'All preference data is stored locally on your device. '
                  'No personal data is uploaded to any server. '
                  'Kanji content is fetched from our Supabase backend solely to display '
                  'educational content and does not involve any user tracking.',
            ),
            _section(
              context,
              title: '3. Third-Party Services',
              body:
                  'This app uses the following third-party services:\n\n'
                  '• Supabase — used to fetch kanji content and remote app configuration. No personally identifiable information is sent.\n'
                  '• Google Fonts — font assets are loaded at runtime. Font requests may be logged by Google per their privacy policy.\n'
                  '• Firebase Cloud Messaging (Google) — used to deliver optional push notifications. A device token may be stored on Firebase servers.\n\n'
                  'We encourage you to review the privacy policies of these services.',
            ),
            _section(
              context,
              title: '4. Children\'s Privacy',
              body:
                  'SSW Kanji is suitable for all ages. We do not knowingly collect any information '
                  'from children under the age of 13. Since no personal data is collected at all, '
                  'this app complies with the Children\'s Online Privacy Protection Act (COPPA) '
                  'and equivalent regulations.',
            ),
            _section(
              context,
              title: '5. Permissions',
              body:
                  'This app requests the following permissions:\n\n'
                  '• Internet — to load kanji content from our server, download Google Fonts, and receive push notifications.\n'
                  '• Post Notifications (Android 13+) — to display optional kanji study reminders. You may deny this permission without affecting core app functionality.\n\n'
                  'No other device permissions (camera, microphone, location, contacts, storage) are requested.',
            ),
            _section(
              context,
              title: '6. Changes to This Policy',
              body:
                  'We may update this Privacy Policy from time to time. Any changes will be '
                  'reflected in the app with an updated effective date. Continued use of the app '
                  'after changes constitutes acceptance of the new policy.',
            ),
            _section(
              context,
              title: '7. Contact Us',
              body:
                  'If you have any questions or concerns about this Privacy Policy, please contact us at:\n\n'
                  'Prime Benchmark Private Limited\n'
                  'Website: primebenchmark.com.np\n'
                  'Email: support@primebenchmark.com.np',
            ),
            const SizedBox(height: 24),
            Text(
              '© 2026 Prime Benchmark Private Limited. All rights reserved.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, {required String title, required String body}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}
