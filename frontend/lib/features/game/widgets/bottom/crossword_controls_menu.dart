import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;

class CrosswordControlsMenu extends StatelessWidget {
  const CrosswordControlsMenu({
    required this.onClose,
    this.onToggleKeyboard,
    this.isAzerty,
    this.onToggleMute,
    this.isMuted,
    this.onToggleTheme,
    this.isDark,
    this.width = 220,
    this.height = 180,
    Key? key,
  }) : super(key: key);

  final VoidCallback onClose;
  final ValueChanged<bool>? onToggleKeyboard;
  final bool? isAzerty;
  final ValueChanged<bool>? onToggleMute;
  final bool? isMuted;
  final ValueChanged<bool>? onToggleTheme;
  final bool? isDark;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
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
                              const Expanded(
                                child: Text(
                                  'Menu',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
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
                                title: const Text('Home'),
                                onTap: () {
                                  onClose();
                                  context.go('/puzzles');
                                },
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
                                title: const Text('Keyboard style'),
                                value: isAzerty ?? false,
                                onChanged: (v) {
                                  if (onToggleKeyboard != null) {
                                    onToggleKeyboard!(v);
                                  }
                                },
                                subtitle: Text(
                                  (isAzerty ?? false) ? 'AZERTY' : 'QWERTY',
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
                                title: const Text('Mute sounds'),
                                value: isMuted ?? false,
                                onChanged: (v) {
                                  if (onToggleMute != null) {
                                    onToggleMute!(v);
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
                                title: const Text('Dark theme'),
                                value: isDark ?? false,
                                onChanged: (v) {
                                  if (onToggleTheme != null) {
                                    onToggleTheme!(v);
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
                                title: const Text('Help'),
                                onTap: onClose,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.info_outline,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                title: const Text('About'),
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
