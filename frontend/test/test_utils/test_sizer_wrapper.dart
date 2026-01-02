import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A test wrapper widget that initializes Sizer for widget tests.
///
/// Use this widget to wrap your test widget when it uses Sizer extensions
/// (.h, .w, .sp) to avoid LateInitializationError.
class TestSizerWrapper extends StatelessWidget {
  /// Creates a TestSizerWrapper.
  const TestSizerWrapper({required this.child, super.key});

  /// The widget to wrap with Sizer.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Sizer(builder: (context, orientation, deviceType) => child);
}

/// Wraps a widget with MaterialApp and Sizer for testing.
///
/// This is a convenience function that combines MaterialApp and Sizer
/// initialization for widget tests.
Widget wrapWithSizer(Widget child, {List<LocalizationsDelegate>? delegates}) =>
    TestSizerWrapper(
      child: MaterialApp(localizationsDelegates: delegates, home: child),
    );
