import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/core/responsive/responsive.dart';

/// Container for displaying the clue text with auto-sizing.
///
/// **IMPORTANT DESIGN CONSTRAINT:**
/// The banner has a FIXED height that NEVER changes. The text must adapt to fit:
/// - Text wraps to multiple lines (up to 4 lines)
/// - Font size shrinks progressively if text is too long
/// - As a last resort, text is truncated with ellipsis
///
/// This ensures consistent layout and prevents the banner from pushing
/// other UI elements around.
class ClueBannerContainer extends ConsumerWidget {
  const ClueBannerContainer({required this.entry, super.key});

  final PuzzleEntryData entry;

  /// Fixed height for the clue banner - MUST NOT CHANGE.
  /// Text adapts to fit within this fixed space.
  static const double fixedHeight = 80;

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
      // SizedBox enforces FIXED height - banner size never changes
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
///
/// Algorithm:
/// 1. Start with base font size
/// 2. Measure text with TextPainter allowing multiple lines
/// 3. If text doesn't fit, reduce font size by 1 and retry
/// 4. Stop at minimum font size (9) and use ellipsis if still too long
class _AutoSizeClueText extends StatelessWidget {
  const _AutoSizeClueText({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  static const int _maxLines = 4;
  static const double _minFontSize = 9;
  static const double _lineHeight = 1.25;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final maxHeight = constraints.maxHeight;
      final baseFontSize = style.fontSize ?? 16;
      
      // Try decreasing font sizes until text fits
      for (var fontSize = baseFontSize; fontSize >= _minFontSize; fontSize -= 0.5) {
        final testStyle = style.copyWith(fontSize: fontSize, height: _lineHeight);
        final tp = TextPainter(
          text: TextSpan(text: text, style: testStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          maxLines: _maxLines,
        )..layout(maxWidth: maxWidth);

        // Check if text fits without overflow
        if (tp.height <= maxHeight && !tp.didExceedMaxLines) {
          return Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: testStyle,
              maxLines: _maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      }

      // Fallback: minimum font size with ellipsis
      final minStyle = style.copyWith(fontSize: _minFontSize, height: _lineHeight);
      return Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: minStyle,
          maxLines: _maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      );
    },
  );
}
