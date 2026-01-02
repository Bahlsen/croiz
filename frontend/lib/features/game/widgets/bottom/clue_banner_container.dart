import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/l10n/app_localizations.dart';
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
  static const double fixedHeight = 96;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        final newDir =
            entry.direction == 'across'
                ? WordDirection.vertical
                : WordDirection.horizontal;
        ref.read(wordDirectionProvider.notifier).setDirection(newDir);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: fixedHeight,
        margin: EdgeInsets.symmetric(horizontal: ResponsivePadding.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveBorderRadius.lg),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      colorScheme.surfaceBright,
                      colorScheme.surfaceContainerHigh,
                    ]
                    : [
                      Colors.white,
                      colorScheme.surfaceContainerHighest.withAlpha(128),
                    ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(isDark ? 40 : 100),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          key: ValueKey('${entry.number}-${entry.direction}-${entry.clue}'),
          padding: EdgeInsets.symmetric(
            vertical: ResponsivePadding.sm,
            horizontal: ResponsivePadding.md,
          ),
          child: Row(
            children: [
              _buildNumberBadge(context),
              SizedBox(width: ResponsivePadding.sm),
              Expanded(
                child: _AutoSizeClueText(
                  key: const Key('clue_text'),
                  text: entry.clue ?? '',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: ResponsiveFontSize.bodyLarge,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAcross = entry.direction == 'across';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(ResponsivePadding.xs),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Text(
            '${entry.number}',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveFontSize.titleMedium,
            ),
          ),
        ),
        SizedBox(height: ResponsivePadding.xxs),
        Text(
          isAcross
              ? (AppLocalizations.of(context)?.across.toUpperCase() ?? 'ACROSS')
              : (AppLocalizations.of(context)?.down.toUpperCase() ?? 'DOWN'),
          style: TextStyle(
            color: colorScheme.primary.withAlpha(180),
            fontWeight: FontWeight.w800,
            fontSize: 8,
            letterSpacing: 0.5,
          ),
        ),
      ],
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
///
/// Supports `<i>text</i>` tags for italic formatting.
class _AutoSizeClueText extends StatelessWidget {
  const _AutoSizeClueText({required this.text, required this.style, super.key});

  final String text;
  final TextStyle style;

  static const int _maxLines = 4;
  static const double _minFontSize = 9;
  static const double _lineHeight = 1.25;

  /// Parses text with `<i>text</i>` tags into TextSpans.
  List<TextSpan> _parseItalicTags(String input, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'<i>(.*?)</i>');
    var lastEnd = 0;

    for (final match in regex.allMatches(input)) {
      // Add text before the match (normal style)
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: input.substring(lastEnd, match.start),
            style: baseStyle,
          ),
        );
      }
      // Add the matched text (italic style)
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ),
      );
      lastEnd = match.end;
    }

    // Add remaining text after last match
    if (lastEnd < input.length) {
      spans.add(TextSpan(text: input.substring(lastEnd), style: baseStyle));
    }

    // If no matches found, return the whole text as a single span
    if (spans.isEmpty) {
      spans.add(TextSpan(text: input, style: baseStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;
      final maxHeight = constraints.maxHeight;
      final baseFontSize = style.fontSize ?? 16;

      // Try decreasing font sizes until text fits
      for (
        var fontSize = baseFontSize;
        fontSize >= _minFontSize;
        fontSize -= 0.5
      ) {
        final testStyle = style.copyWith(
          fontSize: fontSize,
          height: _lineHeight,
        );
        final spans = _parseItalicTags(text, testStyle);
        final tp = TextPainter(
          text: TextSpan(children: spans),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          maxLines: _maxLines,
        )..layout(maxWidth: maxWidth);

        // Check if text fits without overflow
        if (tp.height <= maxHeight && !tp.didExceedMaxLines) {
          return Center(
            child: RichText(
              textAlign: TextAlign.center,
              maxLines: _maxLines,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(children: spans),
            ),
          );
        }
      }

      // Fallback: minimum font size with ellipsis
      final minStyle = style.copyWith(
        fontSize: _minFontSize,
        height: _lineHeight,
      );
      final fallbackSpans = _parseItalicTags(text, minStyle);
      return Center(
        child: RichText(
          textAlign: TextAlign.center,
          maxLines: _maxLines,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(children: fallbackSpans),
        ),
      );
    },
  );
}
