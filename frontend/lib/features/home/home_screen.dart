import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:croiz/services/providers.dart';
import 'package:croiz/core/responsive/responsive.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    Future<void> setLocale(String code) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('locale', code);
      ref.read(localeProvider.notifier).setLocale(Locale(code));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          loc.appTitle,
          style: TextStyle(fontSize: ResponsiveFontSize.titleMedium),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: setLocale,
            icon: Icon(
              Icons.language,
              semanticLabel: loc.selectLanguage,
              size: ResponsiveIconSize.md,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Text(
                  loc.languageEnglish,
                  style: TextStyle(fontSize: ResponsiveFontSize.bodyMedium),
                ),
              ),
              PopupMenuItem(
                value: 'fr',
                child: Text(
                  loc.languageFrench,
                  style: TextStyle(fontSize: ResponsiveFontSize.bodyMedium),
                ),
              ),
              PopupMenuItem(
                value: 'uk',
                child: Text(
                  loc.languageUkrainian,
                  style: TextStyle(fontSize: ResponsiveFontSize.bodyMedium),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              loc.welcome,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveFontSize.headlineSmall,
              ),
            ),
            SizedBox(height: ResponsiveSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: ResponsiveButton.heightMedium,
                  child: ElevatedButton(
                    onPressed: () => context.go('/puzzles'),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsivePadding.lg,
                      ),
                      child: Text(
                        loc.puzzles,
                        style: TextStyle(
                          fontSize: ResponsiveFontSize.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
