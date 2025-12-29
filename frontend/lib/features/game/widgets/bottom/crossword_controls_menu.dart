import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;
import 'package:croiz/services/providers.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    Key? key,
  }) : super(key: key);

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
    // Horizontal margins to keep the menu inset from screen edges
    const horizontalMargin = 24.0;
    final menuWidth = (mq.width - horizontalMargin * 2).clamp(260.0, mq.width);
    // Make the menu taller by default so it occupies more vertical space
    final menuHeight = (mq.height * 0.85).clamp(220.0, mq.height * 0.98);

    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha((0.45 * 255).round()),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalMargin,
                ),
                child: Material(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!.menu,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                tooltip: MaterialLocalizations.of(
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
                            padding: const EdgeInsets.all(8),
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.home,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(AppLocalizations.of(context)!.home),
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.keyboardSizeLabel,
                                ),
                                subtitle: Text(kbSizeLabel(context, ref)),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(left: 8),
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
                                              gameKeyboardSizeProvider
                                                  .notifier,
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.selectLanguage,
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: DropdownButton<String>(
                                    value: ref
                                        .watch(localeProvider)
                                        .languageCode,
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.keyboardStyle,
                                ),
                                value: isAzerty,
                                    onChanged: (v) {
                                  if (onToggleKeyboard != null) {
                                    onToggleKeyboard!(v);
                                  } else {
                                    ref
                                        .read(
                                          gameKeyboardLayoutProvider
                                              .notifier,
                                        )
                                        .setIsAzerty(isAzerty: v);
                                  }
                                },
                                subtitle: Text(
                                  isAzerty
                                      ? AppLocalizations.of(context)!.azerty
                                      : AppLocalizations.of(context)!.qwerty,
                                ),
                              ),
                              const Divider(),

                              // Mute sounds toggle
                              SwitchListTile(
                                secondary: Icon(
                                  Icons.volume_off,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.muteSounds,
                                ),
                                value: isMuted,
                                onChanged: (v) {
                                  if (onToggleMute != null) {
                                    onToggleMute!(v);
                                  } else {
                                    ref
                                        .read(
                                          gameAudioMutedProvider.notifier,
                                        )
                                        .setMuted(muted: v);
                                  }
                                },
                              ),
                              const Divider(),

                              // Theme toggle
                              SwitchListTile(
                                secondary: Icon(
                                  Icons.brightness_6,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.darkTheme,
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(AppLocalizations.of(context)!.help),
                                onTap: onClose,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.info_outline,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.about,
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
