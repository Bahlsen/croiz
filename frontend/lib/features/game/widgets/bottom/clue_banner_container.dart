import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:croiz/domain/entities/game_entities.dart';
import 'package:croiz/features/game/providers/game_providers.dart';
import 'package:croiz/core/responsive/responsive.dart';

class ClueBannerContainer extends ConsumerWidget {
  const ClueBannerContainer({required this.entry, super.key});

  final PuzzleEntryData entry;

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
      child: SizedBox(
        // Responsive height - text will shrink to fit, banner won't grow
        height: 12.h,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ResponsivePadding.lg,
            horizontal: ResponsivePadding.xl,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveBorderRadius.lg),
            border: Border.all(
              color: colorScheme.onSurface.withAlpha((0.12 * 255).round()),
              width: 1,
            ),
          ),
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
      final baseFontSize = style.fontSize ?? 18;
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
          // Text fits at this font size - use RichText with same TextSpan
          // to guarantee identical rendering
          return Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(text: text, style: testStyle),
            ),
          );
        }
        fontSize -= 0.5;
      }

      // At minimum font size but still doesn't fit - make it scrollable
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
