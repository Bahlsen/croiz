import 'dart:io';

import 'package:croiz/l10n/app_localizations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackService {
  static const String _supportEmail = 'support@croiz.app';

  /// Gathers device and app info, then launches the email client with a pre-filled template.
  static Future<void> sendFeedback(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final subject = l10n?.reportProblemSubject ?? 'Problem Report - Croiz';

    // Show a loading indicator using a snackbar or just wait (it's usually fast)
    // For better UX, we could show a toast, but keeping it simple for now.

    try {
      final body = await _buildEmailBody(context);
      final uri = Uri(
        scheme: 'mailto',
        path: _supportEmail,
        query: _encodeQueryParameters({'subject': subject, 'body': body}),
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not launch email client (mailto). Not configured?',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching feedback: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  static Future<String> _buildEmailBody(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final packageInfo = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();

    var deviceModel = 'Unknown';
    var osVersion = 'Unknown';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion =
            'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceModel = '${iosInfo.name} (${iosInfo.systemName})';
        osVersion = iosInfo.systemVersion;
      }
    } catch (e) {
      debugPrint('Failed to get device info: $e');
    }

    // Template
    return '''
${l10n?.reportProblemBody ?? '[Describe your problem here]'}

--------------------------------
Diagnostic Info (Do not edit):
App: ${packageInfo.appName} v${packageInfo.version} (${packageInfo.buildNumber})
Device: $deviceModel
OS: $osVersion
Locale: $locale
''';
  }

  static String? _encodeQueryParameters(Map<String, String> params) => params
      .entries
      .map(
        (e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
      )
      .join('&');
}
