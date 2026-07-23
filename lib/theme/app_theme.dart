import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// "Obsidian & Champagne".
///
/// F-segment luxury does not shout. The palette is a warm near-black — never
/// blue-black, which reads as consumer tech — lit by a single champagne
/// metallic. Colour is rationed: the accent appears on roughly one element per
/// screen, and semantic colours are desaturated so nothing looks like a
/// notification badge. Radii stay near-square, surfaces are separated by
/// hairlines rather than shadows or blur, and type does the work.
abstract final class AppColors {
  // Warm blacks. The brown undertone is deliberate.
  static const ink = Color(0xFF0A0908);
  static const obsidian = Color(0xFF100E0C);
  static const surface = Color(0xFF16130F);
  static const surfaceRaised = Color(0xFF1D1915);
  static const hairline = Color(0xFF2B251E);
  static const hairlineSoft = Color(0xFF1F1B16);

  // The single accent, and its two supporting tones.
  static const champagne = Color(0xFFC6A664);
  static const champagneLight = Color(0xFFE6D3A8);
  static const champagneDeep = Color(0xFF8A7038);

  // Bone, not white. Pure white on warm black looks cheap.
  static const bone = Color(0xFFF2EDE4);
  static const boneMuted = Color(0xFFA79C8B);
  static const boneFaint = Color(0xFF6E6557);

  // Desaturated semantics — closer to enamel than to traffic lights.
  static const jade = Color(0xFF8CA487);
  static const amber = Color(0xFFC9A961);
  static const rust = Color(0xFFAD6B5E);

  /// Brushed-metal sweep for rules, keylines and the accent hairline.
  static const gilt = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [champagneDeep, champagneLight, champagne],
    stops: [0, 0.45, 1],
  );
}

/// Spacing scale. A luxury layout is mostly the large end of this.
abstract final class Gap {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 20.0;
  static const lg = 32.0;
  static const xl = 52.0;
  static const xxl = 84.0;

  /// Horizontal page margin. Wide, so content reads as a set page.
  static const page = 28.0;
}

abstract final class AppTheme {
  static const systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.ink,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Small tracked-out capitals. Used for every label, eyebrow and button.
  static const TextStyle caps = TextStyle(
    fontFamily: 'Sans',
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.6,
    height: 1.4,
    color: AppColors.boneFaint,
  );

  /// Figures pulled from the spec sheet: sans, light, tightly tracked.
  static const TextStyle figure = TextStyle(
    fontFamily: 'Sans',
    fontSize: 34,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    height: 1,
    color: AppColors.bone,
  );

  static ThemeData build() {
    const scheme = ColorScheme.dark(
      primary: AppColors.champagne,
      onPrimary: AppColors.ink,
      secondary: AppColors.champagneLight,
      onSecondary: AppColors.ink,
      surface: AppColors.surface,
      onSurface: AppColors.bone,
      error: AppColors.rust,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.ink,
      fontFamily: 'Sans',
      textTheme: _text,
      // No ink splashes: a ripple is a consumer-app gesture.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      dividerTheme: const DividerThemeData(
        color: AppColors.hairline,
        thickness: 1,
        space: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.champagne,
        inactiveTrackColor: AppColors.hairline,
        thumbColor: AppColors.champagneLight,
        overlayColor: AppColors.champagne.withValues(alpha: 0.10),
        trackHeight: 1.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6, elevation: 0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: Gap.sm),
        hintStyle: _text.bodyMedium!.copyWith(color: AppColors.boneFaint),
        labelStyle: caps,
        floatingLabelStyle: caps.copyWith(color: AppColors.champagne),
        // Underlines only. Boxed fields read as a form; rules read as a ledger.
        border: _line(AppColors.hairline),
        enabledBorder: _line(AppColors.hairline),
        focusedBorder: _line(AppColors.champagne),
        errorBorder: _line(AppColors.rust),
        focusedErrorBorder: _line(AppColors.rust),
        errorStyle: const TextStyle(
          fontFamily: 'Sans',
          fontSize: 11,
          letterSpacing: 0.6,
          color: AppColors.rust,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: TextStyle(
          fontFamily: 'Sans',
          fontSize: 13.5,
          letterSpacing: 0.3,
          color: AppColors.bone,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static UnderlineInputBorder _line(Color color) =>
      UnderlineInputBorder(borderSide: BorderSide(color: color));

  static const _text = TextTheme(
    // ── Bodoni. Large only, tight leading, never bold. ──────────────────────
    displayLarge: TextStyle(
      fontFamily: 'Display',
      fontSize: 62,
      fontWeight: FontWeight.w400,
      height: 1.02,
      letterSpacing: -0.5,
      color: AppColors.bone,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Display',
      fontSize: 42,
      fontWeight: FontWeight.w400,
      height: 1.08,
      letterSpacing: -0.2,
      color: AppColors.bone,
    ),
    displaySmall: TextStyle(
      fontFamily: 'Display',
      fontSize: 30,
      fontWeight: FontWeight.w400,
      height: 1.18,
      color: AppColors.bone,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Display',
      fontSize: 22,
      fontWeight: FontWeight.w400,
      height: 1.25,
      color: AppColors.bone,
    ),

    // ── Jost. Everything else. ─────────────────────────────────────────────
    titleLarge: TextStyle(
      fontFamily: 'Sans',
      fontSize: 15,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: AppColors.bone,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Sans',
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
      color: AppColors.bone,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Sans',
      fontSize: 15,
      fontWeight: FontWeight.w300,
      height: 1.75,
      letterSpacing: 0.15,
      color: AppColors.boneMuted,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Sans',
      fontSize: 13.5,
      fontWeight: FontWeight.w300,
      height: 1.65,
      letterSpacing: 0.15,
      color: AppColors.boneMuted,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Sans',
      fontSize: 12,
      fontWeight: FontWeight.w300,
      height: 1.55,
      letterSpacing: 0.2,
      color: AppColors.boneFaint,
    ),
    labelSmall: caps,
  );
}
