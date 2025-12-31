import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// Container for displaying the clue text with auto-sizing.
///
/// Has a FIXED height - text adapts to fit (shrinks, wraps to multiple lines).
/// Text automatically shrinks to fit within the container.
class ClueBannerContainer extends ConsumerWidget {
  const ClueBannerContainer({required this.entry, super.key});

  final PuzzleEntryData entry;

  /// Fixed height for the clue banner.
  static const double fixedHeight = 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        final newDir = entry.direction == 'across'
            ? WordDirection.vertical
            : WordDirection.horizontal;
        ref.read(wordDirectionProvider.notifier).setDirection(newDir);
      },
      behavior: HitTestBehavior.opaque,
      // SizedBox with fixed height - banner size never changes
      child: SizedBox(
        height: fixedHeight,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsivePadding.sm,
            horizontal: ResponsivePadding.md,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveBorderRadius.md),
            border: Border.all(
              color: colorScheme.onSurface.withAlpha((0.12 * 255).round()),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: _AutoSizeClueText(
            text: entry.clue == null || entry.clue!.isEmpty
                ? '${entry.number}.'
                : '${entry.number}. ${entry.clue!}',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: ResponsiveFontSize.titleMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Text widget that automatically shrinks font size to fit constraints.
/// Text can wrap to multiple lines and shrinks to fit the fixed container.
class _AutoSizeClueText extends StatelessWidget {
  const _AutoSizeClueText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final maxHeight = constraints.maxHeight;
      final baseFontSize = style.fontSize ?? 18;
      
      // Try decreasing font sizes until text fits
      for (var fontSize = baseFontSize; fontSize >= 10; fontSize -= 1) {
        final testStyle = style.copyWith(fontSize: fontSize, height: 1.2);
          final tp = TextPainter(
            text: TextSpan(text: text, style: testStyle),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLines: 3,
          )..layout(maxWidth: maxWidth);

          if (tp.height <= maxHeight) {
            return Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: testStyle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }
        }

        // Fallback: minimum font size with ellipsis
        final minStyle = style.copyWith(fontSize: 10, height: 1.2);
        return Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: minStyle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
}
