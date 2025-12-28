import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
import 'package:croiz/features/game/helpers/entry_lookup.dart';
import 'package:croiz/features/game/providers/game_providers.dart';

class CrosswordRevealOverlay extends ConsumerWidget {
  const CrosswordRevealOverlay({required this.onClose, Key? key})
    : super(key: key);

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) => SizedBox.expand(
    child: Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          // Match the keyboard horizontal padding (4px each side)
          left: 4,
          right: 4,
          bottom: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: Material(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Theme.of(context).cardColor,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)?.reveal ??
                                    'Reveal',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: onClose,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.tag,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      title: Text(
                        AppLocalizations.of(context)?.revealLetterOption ??
                            'Letter',
                      ),
                      onTap: () {
                        onClose();
                        final sel = ref.read(selectedCellProvider);
                        if (sel == null) {
                          return;
                        }
                        ref
                            .read(gameBoardProvider.notifier)
                            .revealLetterAt(sel.row, sel.col);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.checklist,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      title: Text(
                        AppLocalizations.of(context)?.revealWordOption ??
                            'Word',
                      ),
                      onTap: () {
                        onClose();
                        final sel = ref.read(selectedCellProvider);
                        if (sel == null) {
                          return;
                        }
                        final board = ref.read(gameBoardProvider);
                        final dir = ref.read(wordDirectionProvider);
                        final ctx = computeCurrentEntry(board, sel, dir);
                        if (ctx == null) {
                          return;
                        }
                        ref
                            .read(gameBoardProvider.notifier)
                            .revealEntry(ctx.entry);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.grid_on,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      title: Text(
                        AppLocalizations.of(context)?.revealAllOption ?? 'All',
                      ),
                      onTap: () {
                        onClose();
                        ref.read(gameBoardProvider.notifier).revealAll();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
