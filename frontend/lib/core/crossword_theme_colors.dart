import 'package:flutter/material.dart';

/// Theme extension that carries crossword-specific colors used by grid cells.
@immutable
class CrosswordThemeColors extends ThemeExtension<CrosswordThemeColors> {
  const CrosswordThemeColors({
    required this.defaultBgColor,
    required this.selectedWordBgColor,
    required this.flashingBgColor,
    required this.clearedFlashingBgColor,
    required this.blackCellColor,
    required this.defaultBoxShadowColor,
    required this.selectedBorderColor,
    required this.defaultBorderColor,
    required this.selectedBoxShadowColor1,
    required this.selectedBoxShadowColor2,
    required this.flashingBoxShadowColor,
    required this.clearedFlashingBoxShadowColor,
    required this.clearedFlashingBorderColor,
    required this.flashingBorderColor,
    required this.selectedWordBorderColor,
  });

  final Color defaultBgColor;
  final Color selectedWordBgColor;
  final Color flashingBgColor;
  final Color clearedFlashingBgColor;
  final Color blackCellColor;
  final Color defaultBoxShadowColor;
  final Color selectedBorderColor;
  final Color defaultBorderColor;
  final Color selectedBoxShadowColor1;
  final Color selectedBoxShadowColor2;
  final Color flashingBoxShadowColor;
  final Color clearedFlashingBoxShadowColor;
  final Color clearedFlashingBorderColor;
  final Color flashingBorderColor;
  final Color selectedWordBorderColor;

  @override
  CrosswordThemeColors copyWith({
    Color? defaultBgColor,
    Color? selectedWordBgColor,
    Color? flashingBgColor,
    Color? clearedFlashingBgColor,
    Color? blackCellColor,
    Color? defaultBoxShadowColor,
    Color? selectedBorderColor,
    Color? defaultBorderColor,
    Color? selectedBoxShadowColor1,
    Color? selectedBoxShadowColor2,
    Color? flashingBoxShadowColor,
    Color? clearedFlashingBoxShadowColor,
    Color? clearedFlashingBorderColor,
    Color? flashingBorderColor,
    Color? selectedWordBorderColor,
  }) => CrosswordThemeColors(
    defaultBgColor: defaultBgColor ?? this.defaultBgColor,
    selectedWordBgColor: selectedWordBgColor ?? this.selectedWordBgColor,
    flashingBgColor: flashingBgColor ?? this.flashingBgColor,
    clearedFlashingBgColor:
        clearedFlashingBgColor ?? this.clearedFlashingBgColor,
    blackCellColor: blackCellColor ?? this.blackCellColor,
    defaultBoxShadowColor: defaultBoxShadowColor ?? this.defaultBoxShadowColor,
    selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
    defaultBorderColor: defaultBorderColor ?? this.defaultBorderColor,
    selectedBoxShadowColor1:
        selectedBoxShadowColor1 ?? this.selectedBoxShadowColor1,
    selectedBoxShadowColor2:
        selectedBoxShadowColor2 ?? this.selectedBoxShadowColor2,
    flashingBoxShadowColor:
        flashingBoxShadowColor ?? this.flashingBoxShadowColor,
    clearedFlashingBoxShadowColor:
        clearedFlashingBoxShadowColor ?? this.clearedFlashingBoxShadowColor,
    clearedFlashingBorderColor:
        clearedFlashingBorderColor ?? this.clearedFlashingBorderColor,
    flashingBorderColor: flashingBorderColor ?? this.flashingBorderColor,
    selectedWordBorderColor:
        selectedWordBorderColor ?? this.selectedWordBorderColor,
  );

  @override
  CrosswordThemeColors lerp(
    ThemeExtension<CrosswordThemeColors>? other,
    double t,
  ) {
    if (other is! CrosswordThemeColors) {
      return this;
    }
    return CrosswordThemeColors(
      defaultBgColor: Color.lerp(defaultBgColor, other.defaultBgColor, t)!,
      selectedWordBgColor:
          Color.lerp(selectedWordBgColor, other.selectedWordBgColor, t)!,
      flashingBgColor: Color.lerp(flashingBgColor, other.flashingBgColor, t)!,
      clearedFlashingBgColor:
          Color.lerp(clearedFlashingBgColor, other.clearedFlashingBgColor, t)!,
      blackCellColor: Color.lerp(blackCellColor, other.blackCellColor, t)!,
      defaultBoxShadowColor:
          Color.lerp(defaultBoxShadowColor, other.defaultBoxShadowColor, t)!,
      selectedBorderColor:
          Color.lerp(selectedBorderColor, other.selectedBorderColor, t)!,
      defaultBorderColor:
          Color.lerp(defaultBorderColor, other.defaultBorderColor, t)!,
      selectedBoxShadowColor1:
          Color.lerp(
            selectedBoxShadowColor1,
            other.selectedBoxShadowColor1,
            t,
          )!,
      selectedBoxShadowColor2:
          Color.lerp(
            selectedBoxShadowColor2,
            other.selectedBoxShadowColor2,
            t,
          )!,
      flashingBoxShadowColor:
          Color.lerp(flashingBoxShadowColor, other.flashingBoxShadowColor, t)!,
      clearedFlashingBoxShadowColor:
          Color.lerp(
            clearedFlashingBoxShadowColor,
            other.clearedFlashingBoxShadowColor,
            t,
          )!,
      clearedFlashingBorderColor:
          Color.lerp(
            clearedFlashingBorderColor,
            other.clearedFlashingBorderColor,
            t,
          )!,
      flashingBorderColor:
          Color.lerp(flashingBorderColor, other.flashingBorderColor, t)!,
      selectedWordBorderColor:
          Color.lerp(
            selectedWordBorderColor,
            other.selectedWordBorderColor,
            t,
          )!,
    );
  }

  // Central default used when a Theme does not provide the extension.
  static const CrosswordThemeColors defaults = CrosswordThemeColors(
    defaultBgColor: Color(0xFF000000),
    selectedWordBgColor: Color.fromRGBO(33, 150, 243, 0.42),
    flashingBgColor: Color.fromRGBO(105, 240, 174, 0.48),
    clearedFlashingBgColor: Color.fromRGBO(255, 82, 82, 0.48),
    blackCellColor: Color(0xFF000000),
    defaultBoxShadowColor: Color.fromRGBO(0, 0, 0, 0.5),
    selectedBorderColor: Color.fromARGB(255, 110, 32, 124),
    defaultBorderColor: Color(0xFF616161),
    selectedBoxShadowColor1: Color.fromRGBO(128, 0, 128, 0.32),
    selectedBoxShadowColor2: Color.fromRGBO(0, 0, 255, 0.28),
    flashingBoxShadowColor: Color.fromRGBO(105, 240, 174, 0.85),
    clearedFlashingBoxShadowColor: Color.fromRGBO(255, 82, 82, 0.9),
    clearedFlashingBorderColor: Colors.redAccent,
    flashingBorderColor: Colors.greenAccent,
    selectedWordBorderColor: Colors.blueAccent,
  );

  // Light-theme defaults for crossword visuals (lighter backgrounds, darker
  // text, subtler shadows).
  static const CrosswordThemeColors lightDefaults = CrosswordThemeColors(
    defaultBgColor: Color(0xFFFFFFFF),
    // Use a subtle yellow overlay for selected word in light theme so
    // the selected word is visible against white cells.
    selectedWordBgColor: Color.fromRGBO(255, 235, 59, 0.42),
    flashingBgColor: Color.fromRGBO(105, 240, 174, 0.32),
    clearedFlashingBgColor: Color.fromRGBO(255, 82, 82, 0.32),
    // In light theme use a grey for blocked cells instead of pure black
    blackCellColor: Color(0xFF9E9E9E),
    defaultBoxShadowColor: Color.fromRGBO(0, 0, 0, 0.12),
    // In light theme, selected cell border should be orange to contrast
    // against white cells (orange for light, violet for dark).
    selectedBorderColor: Color(0xFFFF9800),
    defaultBorderColor: Color(0xFFBDBDBD),
    // Slight amber shadows for selection on light backgrounds
    selectedBoxShadowColor1: Color.fromRGBO(255, 193, 7, 0.18),
    selectedBoxShadowColor2: Color.fromRGBO(255, 193, 7, 0.12),
    flashingBoxShadowColor: Color.fromRGBO(105, 240, 174, 0.45),
    clearedFlashingBoxShadowColor: Color.fromRGBO(255, 82, 82, 0.45),
    clearedFlashingBorderColor: Color(0xFFFF5252),
    flashingBorderColor: Color(0xFF66FF99),
    selectedWordBorderColor: Color(0xFF64B5F6),
  );

  // Dark-theme overrides: keep normal cells white per user request while
  // the overall scaffold stays dark. Blocked cells remain dark to contrast.
  static const CrosswordThemeColors darkDefaults = CrosswordThemeColors(
    defaultBgColor: Color(0xFFFFFFFF),
    selectedWordBgColor: Color.fromRGBO(33, 150, 243, 0.42),
    flashingBgColor: Color.fromRGBO(105, 240, 174, 0.48),
    clearedFlashingBgColor: Color.fromRGBO(255, 82, 82, 0.48),
    blackCellColor: Color(0xFF000000),
    defaultBoxShadowColor: Color.fromRGBO(0, 0, 0, 0.5),
    selectedBorderColor: Color.fromARGB(255, 110, 32, 124),
    defaultBorderColor: Color(0xFF616161),
    selectedBoxShadowColor1: Color.fromRGBO(128, 0, 128, 0.32),
    selectedBoxShadowColor2: Color.fromRGBO(0, 0, 255, 0.28),
    flashingBoxShadowColor: Color.fromRGBO(105, 240, 174, 0.85),
    clearedFlashingBoxShadowColor: Color.fromRGBO(255, 82, 82, 0.9),
    clearedFlashingBorderColor: Colors.redAccent,
    flashingBorderColor: Colors.greenAccent,
    selectedWordBorderColor: Colors.blueAccent,
  );
}
