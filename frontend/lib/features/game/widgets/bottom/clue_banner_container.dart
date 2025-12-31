import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// Container for displaying the clue text with auto-sizing.
///
/// Has a minimum height to ensure visibility and proper layout.
/// Text automatically shrinks to fit within the container.
class ClueBannerContainer extends ConsumerWidget {
  const ClueBannerContainer({required this.entry, super.key});

  final PuzzleEntryData entry;

  /// Minimum height for the clue banner.
  static const double minHeight = 56;

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
      // ConstrainedBox ensures minimum height for banner visibility
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
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
              fontSize: ResponsiveFontSize.bodyLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Text widget that automatically shrinks font size to fit constraints.
class _AutoSizeClueText extends StatelessWidget {
  const _AutoSizeClueText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  static const double _minFontSize = 10;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final maxHeight = constraints.maxHeight;
      final baseFontSize = style.fontSize ?? 16;
      var fontSize = baseFontSize;

      // Find the largest font size that fits within constraints
      while (fontSize >= _minFontSize) {
        final testStyle = style.copyWith(fontSize: fontSize, height: 1.2);
        final tp = TextPainter(
          text: TextSpan(text: text, style: testStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout(maxWidth: maxWidth);

        if (maxHeight.isFinite && tp.height <= maxHeight) {
          return Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(text: text, style: testStyle),
            ),
          );
        }
        fontSize -= 0.5;
      }

      // At minimum font size - make it scrollable
      final finalStyle = style.copyWith(fontSize: _minFontSize, height: 1.2);
      return SingleChildScrollView(
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(text: text, style: finalStyle),
          ),
        ),
      );
    },
  );
}
