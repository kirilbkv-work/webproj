import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';

/// app theme: cream palette, serif headings, grotesk interface
abstract final class AppTheme {
  /// content column width
  static const double contentMaxWidth = 1180;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 18;

  static ThemeData get light {
    const palette = AppPalette.light;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.brand,
      brightness: Brightness.light,
    ).copyWith(
      primary: palette.brand,
      onPrimary: Colors.white,
      secondary: palette.brandSoft,
      surface: palette.surface,
      onSurface: palette.ink,
      error: palette.danger,
      outline: palette.lineStrong,
      outlineVariant: palette.line,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.bg,
    );

    final body = GoogleFonts.spaceGroteskTextTheme(base.textTheme);
    final textTheme = body.copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 44,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: palette.ink,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: palette.ink,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: palette.ink,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: palette.ink,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: palette.ink,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: palette.inkSoft, height: 1.5),
      bodyMedium: body.bodyMedium?.copyWith(color: palette.inkSoft, height: 1.5),
      bodySmall: body.bodySmall?.copyWith(color: palette.inkMuted),
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: BorderSide(color: color),
    );

    return base.copyWith(
      textTheme: textTheme,
      extensions: const [palette],
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: palette.line),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: palette.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: border(palette.lineStrong),
        enabledBorder: border(palette.lineStrong),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: palette.brandSoft, width: 2),
        ),
        errorBorder: border(palette.danger),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: palette.danger, width: 2),
        ),
        labelStyle: TextStyle(color: palette.inkMuted),
        hintStyle: TextStyle(color: palette.inkMuted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.brand,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.ink,
          backgroundColor: palette.surface,
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: palette.lineStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.brandSoft,
          minimumSize: const Size(0, 40),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: palette.line),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        insetPadding: const EdgeInsets.all(20),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface,
        selectedColor: palette.brand,
        side: BorderSide(color: palette.lineStrong),
        labelStyle: textTheme.bodyMedium,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.ink,
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}
