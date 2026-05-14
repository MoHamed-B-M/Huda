import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Customizable theme configuration
class ThemeConfig {
  final Color seedColor;
  final ThemeMode themeMode;
  final double arabicFontSize;
  final double englishFontSize;
  final String arabicFontFamily;
  final bool enableDynamicColor;

  const ThemeConfig({
    this.seedColor = const Color(0xFF1F7A5E),
    this.themeMode = ThemeMode.system,
    this.arabicFontSize = 24.0,
    this.englishFontSize = 16.0,
    this.arabicFontFamily = 'Amiri',
    this.enableDynamicColor = true,
  });

  ThemeConfig copyWith({
    Color? seedColor,
    ThemeMode? themeMode,
    double? arabicFontSize,
    double? englishFontSize,
    String? arabicFontFamily,
    bool? enableDynamicColor,
  }) {
    return ThemeConfig(
      seedColor: seedColor ?? this.seedColor,
      themeMode: themeMode ?? this.themeMode,
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      englishFontSize: englishFontSize ?? this.englishFontSize,
      arabicFontFamily: arabicFontFamily ?? this.arabicFontFamily,
      enableDynamicColor: enableDynamicColor ?? this.enableDynamicColor,
    );
  }
}

/// Generates Material 3 Light Theme
ThemeData buildLightTheme(ThemeConfig config) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: config.seedColor,
    brightness: Brightness.light,
    dynamicSchemeVariant: config.enableDynamicColor
        ? DynamicSchemeVariant.tonalSpot
        : null,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    typography: Typography.material2021(),
    textTheme: _buildTextTheme(config, colorScheme),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.amiri(
          fontSize: 12,
          color: colorScheme.onSurface,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      circularTrackColor: colorScheme.surfaceVariant,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.surfaceVariant,
      thumbColor: colorScheme.primary,
    ),
  );
}

/// Generates Material 3 Dark Theme
ThemeData buildDarkTheme(ThemeConfig config) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: config.seedColor,
    brightness: Brightness.dark,
    dynamicSchemeVariant: config.enableDynamicColor
        ? DynamicSchemeVariant.tonalSpot
        : null,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    typography: Typography.material2021(),
    textTheme: _buildTextTheme(config, colorScheme),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surface,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.amiri(
          fontSize: 12,
          color: colorScheme.onSurface,
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}

/// Build custom text theme with Arabic and English fonts
TextTheme _buildTextTheme(
  ThemeConfig config,
  ColorScheme colorScheme,
) {
  final baseTextTheme = TextTheme(
    displayLarge: GoogleFonts.amiri(
      fontSize: config.arabicFontSize + 16,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
    displayMedium: GoogleFonts.amiri(
      fontSize: config.arabicFontSize + 12,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
    displaySmall: GoogleFonts.amiri(
      fontSize: config.arabicFontSize + 8,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
    headlineLarge: GoogleFonts.amiri(
      fontSize: config.arabicFontSize + 4,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.amiri(
      fontSize: config.arabicFontSize,
      fontWeight: FontWeight.w600,
      height: 2.2,
      color: colorScheme.onSurface,
    ),
    headlineSmall: GoogleFonts.amiri(
      fontSize: config.arabicFontSize - 4,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    titleLarge: GoogleFonts.amiri(
      fontSize: config.arabicFontSize - 2,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.amiri(
      fontSize: config.arabicFontSize - 4,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.amiri(
      fontSize: config.arabicFontSize - 6,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurfaceVariant,
    ),
    bodyLarge: GoogleFonts.amiri(
      fontSize: config.englishFontSize + 2,
      height: 1.5,
      color: colorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.amiri(
      fontSize: config.englishFontSize,
      height: 1.5,
      color: colorScheme.onSurface,
    ),
    bodySmall: GoogleFonts.amiri(
      fontSize: config.englishFontSize - 2,
      color: colorScheme.onSurfaceVariant,
    ),
    labelLarge: GoogleFonts.amiri(
      fontSize: config.englishFontSize - 2,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    ),
    labelMedium: GoogleFonts.amiri(
      fontSize: config.englishFontSize - 4,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurfaceVariant,
    ),
    labelSmall: GoogleFonts.amiri(
      fontSize: config.englishFontSize - 6,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurfaceVariant,
    ),
  );

  return baseTextTheme;
}

// ============ Riverpod Theme Provider ============

final themeConfigProvider =
    StateNotifierProvider<ThemeConfigNotifier, ThemeConfig>(
  (ref) => ThemeConfigNotifier(),
);

class ThemeConfigNotifier extends StateNotifier<ThemeConfig> {
  ThemeConfigNotifier() : super(const ThemeConfig());

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setArabicFontSize(double size) {
    state = state.copyWith(arabicFontSize: size);
  }

  void setEnglishFontSize(double size) {
    state = state.copyWith(englishFontSize: size);
  }

  void setArabicFontFamily(String family) {
    state = state.copyWith(arabicFontFamily: family);
  }

  void setDynamicColor(bool enabled) {
    state = state.copyWith(enableDynamicColor: enabled);
  }

  void resetToDefaults() {
    state = const ThemeConfig();
  }
}

/// Provider for light theme
final lightThemeProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(themeConfigProvider);
  return buildLightTheme(config);
});

/// Provider for dark theme
final darkThemeProvider = Provider<ThemeData>((ref) {
  final config = ref.watch(themeConfigProvider);
  return buildDarkTheme(config);
});
