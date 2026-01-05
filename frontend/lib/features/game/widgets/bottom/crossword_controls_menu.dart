import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;
import 'package:croiz/services/providers.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:croiz/core/responsive/responsive.dart';

String kbSizeLabel(BuildContext context, WidgetRef ref) {
  final val = ref.watch(gameKeyboardSizeProvider);
  final loc = AppLocalizations.of(context)!;
  switch (val) {
    case KeyboardSize.small:
      return loc.small;
    case KeyboardSize.large:
      return loc.large;
    case KeyboardSize.medium:
      return loc.medium;
  }
}

class CrosswordControlsMenu extends ConsumerWidget {
  const CrosswordControlsMenu({
    required this.onClose,
    this.onToggleKeyboard,
    this.onToggleMute,
    this.onToggleTheme,
    this.width = 220,
    this.height = 180,
    super.key,
  });

  final VoidCallback onClose;
  final ValueChanged<bool>? onToggleKeyboard;
  final ValueChanged<bool>? onToggleMute;
  final ValueChanged<bool>? onToggleTheme;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mq = MediaQuery.of(context).size;
    final isAzerty = ref.watch(gameKeyboardLayoutProvider);
    final isMuted = ref.watch(gameAudioMutedProvider);
    final isDark = ref.watch(appIsDarkProvider);
    // Responsive horizontal margins
    final horizontalMargin = ResponsivePadding.xl;
    final menuWidth = (mq.width - horizontalMargin * 2).clamp(260.0, mq.width);
    // Make the menu taller by default so it occupies more vertical space
    final menuHeight = 85.h.clamp(220.0, mq.height * 0.98);

    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: ColoredBox(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((0.45 * 255).round()),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                child: Material(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveBorderRadius.xl,
                    ),
                  ),
                  color: Theme.of(context).cardColor,
                  child: SizedBox(
                    width: menuWidth,
                    height: menuHeight,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsivePadding.lg,
                            vertical: ResponsivePadding.lg,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.menu,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveFontSize.titleLarge,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                tooltip:
                                    MaterialLocalizations.of(
                                      context,
                                    ).closeButtonTooltip,
                                onPressed: onClose,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),

                        // Content area (expanded so menu takes more vertical space)
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.all(ResponsivePadding.md),
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.home,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.home,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodyLarge,
                                  ),
                                ),
                                onTap: () {
                                  onClose();
                                  context.go('/puzzles');
                                },
                              ),
                              const Divider(),
                              // Compact keyboard size selector using a Dropdown
                              ListTile(
                                leading: Icon(
                                  Icons.zoom_out_map,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.keyboardSizeLabel,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodyLarge,
                                  ),
                                ),
                                subtitle: Text(
                                  kbSizeLabel(context, ref),
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodySmall,
                                  ),
                                ),
                                trailing: Padding(
                                  padding: EdgeInsets.only(
                                    left: ResponsivePadding.md,
                                  ),
                                  child: DropdownButton<KeyboardSize>(
                                    value: ref.watch(gameKeyboardSizeProvider),
                                    underline: const SizedBox.shrink(),
                                    items: [
                                      DropdownMenuItem(
                                        value: KeyboardSize.small,
                                        child: Text(
                                          AppLocalizations.of(context)!.small,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: KeyboardSize.medium,
                                        child: Text(
                                          AppLocalizations.of(context)!.medium,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: KeyboardSize.large,
                                        child: Text(
                                          AppLocalizations.of(context)!.large,
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) {
                                      if (v != null) {
                                        ref
                                            .read(
                                              gameKeyboardSizeProvider.notifier,
                                            )
                                            .setSize(v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const Divider(),
                              // Language selector (persisted)
                              ListTile(
                                leading: Icon(
                                  Icons.language,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.selectLanguage,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodyLarge,
                                  ),
                                ),
                                trailing: Padding(
                                  padding: EdgeInsets.only(
                                    left: ResponsivePadding.md,
                                  ),
                                  child: DropdownButton<String>(
                                    value:
                                        ref.watch(localeProvider).languageCode,
                                    underline: const SizedBox.shrink(),
                                    items: [
                                      DropdownMenuItem(
                                        value: 'en',
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.languageEnglish,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'fr',
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.languageFrench,
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'uk',
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          )!.languageUkrainian,
                                        ),
                                      ),
                                    ],
                                    onChanged: (v) async {
                                      if (v == null) {
                                        return;
                                      }

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setString('locale', v);
                                      ref
                                          .read(localeProvider.notifier)
                                          .setLocale(Locale(v));
                                    },
                                  ),
                                ),
                              ),
                              const Divider(),
                              // Keyboard style control moved into the menu
                              SwitchListTile(
                                secondary: Icon(
                                  Icons.keyboard,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.keyboardStyle,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodyLarge,
                                  ),
                                ),
                                value: isAzerty,
                                onChanged: (v) {
                                  if (onToggleKeyboard != null) {
                                    onToggleKeyboard!(v);
                                  } else {
                                    ref
                                        .read(
                                          gameKeyboardLayoutProvider.notifier,
                                        )
                                        .setIsAzerty(isAzerty: v);
                                  }
                                },
                                subtitle: Text(
                                  isAzerty
                                      ? AppLocalizations.of(context)!.azerty
                                      : AppLocalizations.of(context)!.qwerty,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodySmall,
                                  ),
                                ),
                              ),
                              const Divider(),

                              // Mute sounds toggle
                              SwitchListTile(
                                secondary: Icon(
                                  Icons.volume_off,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.muteSounds,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodyLarge,
                                  ),
                                ),
                                value: isMuted,
                                onChanged: (v) {
                                  if (onToggleMute != null) {
                                    onToggleMute!(v);
                                  } else {
                                    ref
                                        .read(gameAudioMutedProvider.notifier)
                                        .setMuted(muted: v);
                                  }
                                },
                              ),
                              const Divider(),

                              // Theme toggle
                              SwitchListTile(
                                secondary: Icon(
                                  Icons.brightness_6,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.darkTheme,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodyLarge,
                                  ),
                                ),
                                value: isDark,
                                onChanged: (v) {
                                  if (onToggleTheme != null) {
                                    onToggleTheme!(v);
                                  } else {
                                    ref
                                        .read(appIsDarkProvider.notifier)
                                        .setIsDark(isDark: v);
                                  }
                                },
                              ),
                              const Divider(),
                              ListTile(
                                leading: Icon(
                                  Icons.help_outline,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.help,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodyLarge,
                                  ),
                                ),
                                onTap: onClose,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.info_outline,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: ResponsiveIconSize.md,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.about,
                                  style: TextStyle(
                                    fontSize: ResponsiveFontSize.bodyLarge,
                                  ),
                                ),
                                onTap: onClose,
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
