import 'package:flutter/material.dart';
import 'package:croiz/core/responsive/responsive.dart';
import 'package:sizer/sizer.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.graphic,
    super.key,
  });

  final String title;
  final String description;
  final Widget graphic;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 6.w),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(flex: 3, child: Center(child: graphic)),
        SizedBox(height: 4.h),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 14.sp,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const Spacer(flex: 1),
      ],
    ),
  );
}
