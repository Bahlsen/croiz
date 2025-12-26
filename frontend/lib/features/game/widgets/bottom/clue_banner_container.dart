import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';

class ClueBannerContainer extends ConsumerWidget {
  const ClueBannerContainer({required this.entry, Key? key}) : super(key: key);

  final PuzzleEntryData entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        final newDir = entry.direction == 'across'
            ? WordDirection.vertical
            : WordDirection.horizontal;
        ref.read(wordDirectionProvider.notifier).value = newDir;
      },
      behavior: HitTestBehavior.opaque,
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 96),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.onSurface.withAlpha((0.12 * 255).round()),
                width: 1,
              ),
            ),
            child: Center(
              child: _AutoSizeClueText(
                text: entry.clue == null || entry.clue!.isEmpty
                    ? '${entry.number}.'
                    : '${entry.number}. ${entry.clue!}',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                minFontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AutoSizeClueText extends StatefulWidget {
  const _AutoSizeClueText({
    required this.text,
    required this.style,
    this.maxLines = 2,
    this.minFontSize = 12,
    Key? key,
  }) : super(key: key);

  final String text;
  final TextStyle style;
  final int maxLines;
  final double minFontSize;

  @override
  State<_AutoSizeClueText> createState() => _AutoSizeClueTextState();
}

class _AutoSizeClueTextState extends State<_AutoSizeClueText> {
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      // Start from provided fontSize or fallback
      final baseFontSize = widget.style.fontSize ?? 18;
      var fontSize = baseFontSize;

      // Try decreasing font size until text fits within maxLines.
      while (fontSize >= widget.minFontSize) {
        final tp = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: widget.style.copyWith(fontSize: fontSize),
          ),
          textDirection: TextDirection.ltr,
          maxLines: widget.maxLines,
          ellipsis: null,
        )..layout(maxWidth: maxWidth);
        if (tp.didExceedMaxLines) {
          fontSize -= 1;
          continue;
        }
        break;
      }

      // Ensure not below minFontSize
      if (fontSize < widget.minFontSize) {
        fontSize = widget.minFontSize;
      }

      // Store for diagnostics/testing

      return Text(
        widget.text,
        textAlign: TextAlign.center,
        maxLines: widget.maxLines,
        style: widget.style.copyWith(fontSize: fontSize),
      );
    },
  );
}
