import 'package:url_launcher/url_launcher.dart';

/// Allowed URI schemes for launching external URLs.
const _allowedSchemes = {'http', 'https', 'mailto', 'tel', 'sms'};

/// Validates the URL scheme before launching. Prevents launching
/// dangerous schemes (e.g. javascript:, file:, intent:) that could
/// be injected via remotely-configurable app_config values.
Future<bool> launchUrlSafe(String url, {LaunchMode mode = LaunchMode.externalApplication}) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !_allowedSchemes.contains(uri.scheme.toLowerCase())) {
    return false;
  }
  return launchUrl(uri, mode: mode);
}
