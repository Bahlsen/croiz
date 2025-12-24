import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class CrosswordControlsMenu extends StatelessWidget {
  const CrosswordControlsMenu({
    required this.onClose,
    this.width = 220,
    this.height = 180,
    Key? key,
  }) : super(key: key);

  final VoidCallback onClose;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final menuWidth = (mq.width * 0.9).clamp(220.0, mq.width);
    final menuHeight = (mq.height * 0.7).clamp(180.0, mq.height * 0.95);

    return Positioned.fill(
      child: GestureDetector(
        onTap: onClose,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: Colors.black45,
            child: Center(
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(16),
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
                              icon: const Icon(Icons.close),
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
                              leading: const Icon(Icons.info_outline),
                              title: const Text('About'),
                              onTap: onClose,
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.settings),
                              title: const Text('Settings'),
                              onTap: onClose,
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.help_outline),
                              title: const Text('Help'),
                              onTap: onClose,
                            ),
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
    );
  }
}
