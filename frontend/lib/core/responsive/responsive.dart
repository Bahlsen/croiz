// Responsive utilities for the Croiz app using the sizer package.
//
// This module provides consistent responsive sizing utilities across the app.
// Import this file to get access to all responsive helpers.
//
// Example usage:
// ```dart
// import 'package:croiz/core/responsive/responsive.dart';
// import 'package:sizer/sizer.dart';
//
// // Use percentage of screen height/width
// Container(
//   width: 50.w,  // 50% of screen width
//   height: 30.h, // 30% of screen height
// )
//
// // Use responsive spacing
// SizedBox(height: ResponsiveSpacing.md)
//
// // Use responsive font sizes
// Text('Hello', style: TextStyle(fontSize: ResponsiveFontSize.bodyMedium))
// ```

export 'package:sizer/sizer.dart';
export 'responsive_extensions.dart';
