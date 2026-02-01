import 'package:croiz/core/crossword_theme_colors.dart';
import 'package:croiz/features/onboarding/providers/onboarding_provider.dart';
import 'package:croiz/features/onboarding/widgets/onboarding_indicator.dart';
import 'package:croiz/features/onboarding/widgets/onboarding_page.dart';

import 'package:croiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  Future<void> _onFinish() async {
    await ref.read(onboardingStateProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/puzzles');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onFinish,
                child: Text(l10n.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Step 1: Welcome
                  OnboardingPage(
                    title: l10n.onboardingWelcomeTitle,
                    description: l10n.onboardingWelcomeDesc,
                    graphic: _buildWelcomeGraphic(),
                  ),
                  // Step 2: How to Play
                  OnboardingPage(
                    title: l10n.onboardingBasicTitle,
                    description: l10n.onboardingBasicDesc,
                    graphic: _buildGridInteractionGraphic(context, step: 0),
                  ),
                  // Step 3: Direction
                  OnboardingPage(
                    title: l10n.onboardingDirectionTitle,
                    description: l10n.onboardingDirectionDesc,
                    graphic: _buildGridInteractionGraphic(context, step: 1),
                  ),
                  // Step 4: Completion
                  OnboardingPage(
                    title: l10n.onboardingCompletionTitle,
                    description: l10n.onboardingCompletionDesc,
                    graphic: _buildGridInteractionGraphic(context, step: 2),
                  ),
                  // Step 5: Get Started
                  OnboardingPage(
                    title: l10n.onboardingFinishTitle,
                    description: l10n.onboardingFinishDesc,
                    graphic: _buildFinishGraphic(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Column(
                children: [
                  OnboardingIndicator(count: 5, currentPage: _currentPage),
                  SizedBox(height: 4.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _onNext,
                      child: Text(
                        _currentPage == 4
                            ? l10n.onboardingDone
                            : l10n.onboardingNext,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeGraphic() => Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.grid_4x4_rounded, size: 80, color: Colors.white),
        ),
      )
      .animate()
      .scale(duration: 600.ms, curve: Curves.elasticOut)
      .fade(duration: 400.ms);

  Widget _buildGridInteractionGraphic(
    BuildContext context, {
    required int step,
  }) {
    // 0 = Tap, 1 = Direction, 2 = Completion
    final colors =
        Theme.of(context).extension<CrosswordThemeColors>() ??
        CrosswordThemeColors.defaults;

    return Center(
      child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (row) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (col) {
                    // Determine cell state based on step
                    var isSelected = false;
                    var isHighlighted = false;
                    var isCompleted = false;
                    var letter = '';

                    if (step == 0) {
                      // Step 0: Center selected
                      isSelected = row == 1 && col == 1;
                    } else if (step == 1) {
                      // Step 1: Center selected (direction demo)
                      isSelected = row == 1 && col == 1;
                      isHighlighted = (row == 1); // Horizontal highlight
                    } else if (step == 2) {
                      // Step 2: Center word completed
                      if (row == 1) {
                        isCompleted = true;
                        // "WIN"
                        letter = ['W', 'I', 'N'][col];
                      }
                    }

                    // Visual Representation of Cell
                    return Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? colors.flashingBgColor
                                : (isSelected
                                    ? colors.selectedWordBgColor
                                    : (isHighlighted
                                        ? colors.selectedWordBgColor
                                        : colors.defaultBgColor)),
                        border:
                            isSelected
                                ? Border.all(
                                  color: colors.selectedBorderColor,
                                  width: 2,
                                )
                                : Border.all(color: colors.defaultBorderColor),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 2000.ms,
            color: step == 2 ? Colors.green.withValues(alpha: 0.3) : null,
          ) // Flash for completion
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(0.95, 0.95),
            duration: 2000.ms,
            curve: Curves.easeInOut,
          ),
    );
  }

  Widget _buildFinishGraphic(BuildContext context) => const Icon(
        Icons.check_circle_outline_rounded,
        size: 100,
        color: Colors.green,
      )
      .animate()
      .scale(duration: 500.ms, curve: Curves.easeOutBack)
      .then()
      .shake(duration: 500.ms);
}
