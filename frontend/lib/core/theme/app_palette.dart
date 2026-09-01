import 'package:flutter/material.dart';

/// extra design tokens missing from [ColorScheme]
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.bgDeep,
    required this.surface,
    required this.surfaceAlt,
    required this.line,
    required this.lineStrong,
    required this.ink,
    required this.inkSoft,
    required this.inkMuted,
    required this.brand,
    required this.brandSoft,
    required this.brandTint,
    required this.accent,
    required this.accentTint,
    required this.danger,
    required this.dangerTint,
    required this.info,
    required this.infoTint,
  });

  final Color bg;
  final Color bgDeep;
  final Color surface;
  final Color surfaceAlt;
  final Color line;
  final Color lineStrong;
  final Color ink;
  final Color inkSoft;
  final Color inkMuted;
  final Color brand;
  final Color brandSoft;
  final Color brandTint;
  final Color accent;
  final Color accentTint;
  final Color danger;
  final Color dangerTint;
  final Color info;
  final Color infoTint;

  static const AppPalette light = AppPalette(
    bg: Color(0xFFF7F4EF),
    bgDeep: Color(0xFFEFEAE1),
    surface: Color(0xFFFFFBF7),
    surfaceAlt: Color(0xFFF3EEE6),
    line: Color(0xFFE3DCD1),
    lineStrong: Color(0xFFCFC5B6),
    ink: Color(0xFF1C1917),
    inkSoft: Color(0xFF4A423A),
    inkMuted: Color(0xFF7B7168),
    brand: Color(0xFF1B4332),
    brandSoft: Color(0xFF2D6A4F),
    brandTint: Color(0xFFE7EFE9),
    accent: Color(0xFFB45309),
    accentTint: Color(0xFFFDF0E0),
    danger: Color(0xFF9B2C2C),
    dangerTint: Color(0xFFFBEAEA),
    info: Color(0xFF1D4E89),
    infoTint: Color(0xFFE8EFF8),
  );

  @override
  AppPalette copyWith({
    Color? bg,
    Color? bgDeep,
    Color? surface,
    Color? surfaceAlt,
    Color? line,
    Color? lineStrong,
    Color? ink,
    Color? inkSoft,
    Color? inkMuted,
    Color? brand,
    Color? brandSoft,
    Color? brandTint,
    Color? accent,
    Color? accentTint,
    Color? danger,
    Color? dangerTint,
    Color? info,
    Color? infoTint,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      bgDeep: bgDeep ?? this.bgDeep,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      inkMuted: inkMuted ?? this.inkMuted,
      brand: brand ?? this.brand,
      brandSoft: brandSoft ?? this.brandSoft,
      brandTint: brandTint ?? this.brandTint,
      accent: accent ?? this.accent,
      accentTint: accentTint ?? this.accentTint,
      danger: danger ?? this.danger,
      dangerTint: dangerTint ?? this.dangerTint,
      info: info ?? this.info,
      infoTint: infoTint ?? this.infoTint,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppPalette(
      bg: mix(bg, other.bg),
      bgDeep: mix(bgDeep, other.bgDeep),
      surface: mix(surface, other.surface),
      surfaceAlt: mix(surfaceAlt, other.surfaceAlt),
      line: mix(line, other.line),
      lineStrong: mix(lineStrong, other.lineStrong),
      ink: mix(ink, other.ink),
      inkSoft: mix(inkSoft, other.inkSoft),
      inkMuted: mix(inkMuted, other.inkMuted),
      brand: mix(brand, other.brand),
      brandSoft: mix(brandSoft, other.brandSoft),
      brandTint: mix(brandTint, other.brandTint),
      accent: mix(accent, other.accent),
      accentTint: mix(accentTint, other.accentTint),
      danger: mix(danger, other.danger),
      dangerTint: mix(dangerTint, other.dangerTint),
      info: mix(info, other.info),
      infoTint: mix(infoTint, other.infoTint),
    );
  }
}

extension AppPaletteContext on BuildContext {
  /// design tokens of the app
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  TextTheme get texts => Theme.of(this).textTheme;
}
