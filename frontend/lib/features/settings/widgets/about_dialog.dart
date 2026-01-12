import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// About dialog showing app version, credits, and legal information
class AboutDialog extends ConsumerStatefulWidget {
  const AboutDialog({super.key});

  @override
  ConsumerState<AboutDialog> createState() => _AboutDialogState();
}

class _AboutDialogState extends ConsumerState<AboutDialog> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _packageInfo = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: ResponsiveOverlay.dialogWidth,
          maxHeight: 80.h,
        ),
        padding: EdgeInsets.all(ResponsivePadding.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: ResponsiveIconSize.lg,
                ),
                SizedBox(width: ResponsiveSpacing.sm),
                Expanded(
                  child: Text(
                    l10n?.about ?? 'About',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: ResponsiveFontSize.headlineSmall,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: ResponsiveSpacing.md),
            const Divider(),
            SizedBox(height: ResponsiveSpacing.md),

            // Content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Name & Version
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Croiz',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.xs),
                          if (_packageInfo != null)
                            Text(
                              'Version ${_packageInfo!.version} (${_packageInfo!.buildNumber})',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          else
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: ResponsiveSpacing.lg),

                    // Description
                    Text(
                      l10n?.appDescription ??
                          'A modern crossword puzzle game with AI-powered generation, multiple languages, and beautiful design.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: ResponsiveSpacing.lg),

                    // Credits
                    _buildSection(
                      context,
                      title: l10n?.credits ?? 'Credits',
                      icon: Icons.people_outline,
                      children: [
                        _buildCreditItem(
                          context,
                          'Development',
                          'Built with Flutter & Riverpod',
                        ),
                        _buildCreditItem(
                          context,
                          'Typography',
                          'Outfit & Inter fonts via Google Fonts',
                        ),
                        _buildCreditItem(
                          context,
                          'AI Generation',
                          'Powered by Google Gemini',
                        ),
                      ],
                    ),
                    SizedBox(height: ResponsiveSpacing.md),

                    // Legal
                    _buildSection(
                      context,
                      title: l10n?.legal ?? 'Legal',
                      icon: Icons.gavel_outlined,
                      children: [
                        TextButton(
                          onPressed: () {
                            // TODO: Show privacy policy
                          },
                          child: Text(l10n?.privacyPolicy ?? 'Privacy Policy'),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Show terms of service
                          },
                          child: Text(
                            l10n?.termsOfService ?? 'Terms of Service',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showLicensePage(
                              context: context,
                              applicationName: 'Croiz',
                              applicationVersion: _packageInfo?.version,
                            );
                          },
                          child: Text(
                            l10n?.openSourceLicenses ?? 'Open Source Licenses',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: ResponsiveIconSize.sm,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: ResponsiveSpacing.xs),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveSpacing.sm),
        ...children,
      ],
    );
  }

  Widget _buildCreditItem(
    BuildContext context,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
