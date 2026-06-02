import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tala — Heritage Workshop theme.
// Color, type, and shape tokens are sourced from `tala_design_core.md`.
// Skeuomorphic component treatments (paper textures, binder holes, stamped-
// metal bevels, manila chips) are deferred to a later polish phase per
// `DESIGN.md` and are intentionally not implemented here.

const _primary = Color(0xFF002A15);
const _onPrimary = Color(0xFFFFFFFF);
const _primaryContainer = Color(0xFF004225);
const _onPrimaryContainer = Color(0xFF75AF89);
const _inversePrimary = Color(0xFF98D4AC);

const _secondary = Color(0xFFAF2D2D);
const _onSecondary = Color(0xFFFFFFFF);
const _secondaryContainer = Color(0xFFFE6761);
const _onSecondaryContainer = Color(0xFF69000A);

const _tertiary = Color(0xFF735C00);
const _onTertiary = Color(0xFFFFFFFF);
const _tertiaryContainer = Color(0xFFCBA72F);
const _onTertiaryContainer = Color(0xFF4E3D00);

const _error = Color(0xFFBA1A1A);
const _onError = Color(0xFFFFFFFF);
const _errorContainer = Color(0xFFFFDAD6);
const _onErrorContainer = Color(0xFF93000A);

const _surface = Color(0xFFFCF9F8);
const _surfaceDim = Color(0xFFDCD9D9);
const _surfaceBright = Color(0xFFFCF9F8);
const _surfaceContainerLowest = Color(0xFFFFFFFF);
const _surfaceContainerLow = Color(0xFFF6F3F2);
const _surfaceContainer = Color(0xFFF0EDED);
const _surfaceContainerHigh = Color(0xFFEAE7E7);
const _surfaceContainerHighest = Color(0xFFE4E2E1);
const _onSurface = Color(0xFF1B1C1C);
const _onSurfaceVariant = Color(0xFF404942);
const _inverseSurface = Color(0xFF303030);
const _inverseOnSurface = Color(0xFFF3F0F0);
const _outline = Color(0xFF717971);
const _outlineVariant = Color(0xFFC0C9C0);
const _surfaceTint = Color(0xFF316948);

const _colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: _primary,
  onPrimary: _onPrimary,
  primaryContainer: _primaryContainer,
  onPrimaryContainer: _onPrimaryContainer,
  inversePrimary: _inversePrimary,
  secondary: _secondary,
  onSecondary: _onSecondary,
  secondaryContainer: _secondaryContainer,
  onSecondaryContainer: _onSecondaryContainer,
  tertiary: _tertiary,
  onTertiary: _onTertiary,
  tertiaryContainer: _tertiaryContainer,
  onTertiaryContainer: _onTertiaryContainer,
  error: _error,
  onError: _onError,
  errorContainer: _errorContainer,
  onErrorContainer: _onErrorContainer,
  surface: _surface,
  onSurface: _onSurface,
  surfaceDim: _surfaceDim,
  surfaceBright: _surfaceBright,
  surfaceContainerLowest: _surfaceContainerLowest,
  surfaceContainerLow: _surfaceContainerLow,
  surfaceContainer: _surfaceContainer,
  surfaceContainerHigh: _surfaceContainerHigh,
  surfaceContainerHighest: _surfaceContainerHighest,
  onSurfaceVariant: _onSurfaceVariant,
  inverseSurface: _inverseSurface,
  onInverseSurface: _inverseOnSurface,
  outline: _outline,
  outlineVariant: _outlineVariant,
  surfaceTint: _surfaceTint,
);

TextTheme _buildTextTheme() {
  final barlow = GoogleFonts.barlowCondensedTextTheme();
  final serif = GoogleFonts.sourceSerif4TextTheme();
  final mono = GoogleFonts.jetBrainsMonoTextTheme();

  return TextTheme(
    displayLarge: barlow.displayLarge?.copyWith(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      height: 1.1,
      letterSpacing: 0.96,
      color: _onSurface,
    ),
    displayMedium: barlow.displayMedium?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: _onSurface,
    ),
    displaySmall: barlow.displaySmall?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: _onSurface,
    ),
    headlineLarge: barlow.headlineLarge?.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: _onSurface,
    ),
    headlineMedium: barlow.headlineMedium?.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: _onSurface,
    ),
    headlineSmall: barlow.headlineSmall?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: _onSurface,
    ),
    titleLarge: barlow.titleLarge?.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: _onSurface,
    ),
    titleMedium: barlow.titleMedium?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: _onSurface,
    ),
    titleSmall: barlow.titleSmall?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: _onSurface,
    ),
    bodyLarge: serif.bodyLarge?.copyWith(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: _onSurface,
    ),
    bodyMedium: serif.bodyMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: _onSurface,
    ),
    bodySmall: serif.bodySmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: _onSurfaceVariant,
    ),
    labelLarge: mono.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.7,
      height: 1.4,
      color: _onSurface,
    ),
    labelMedium: mono.labelMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.7,
      height: 1.4,
      color: _onSurface,
    ),
    labelSmall: mono.labelSmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      height: 1.3,
      color: _onSurfaceVariant,
    ),
  );
}

final TextTheme _textTheme = _buildTextTheme();

const _radiusDefault = 4.0;
const _radiusChip = 2.0;
const _radiusSheet = 8.0;

final ThemeData garageTheme = ThemeData(
  useMaterial3: true,
  colorScheme: _colorScheme,
  scaffoldBackgroundColor: _surface,
  canvasColor: _surface,
  textTheme: _textTheme,
  primaryTextTheme: _textTheme,

  appBarTheme: AppBarTheme(
    backgroundColor: _primary,
    foregroundColor: _onPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    toolbarHeight: 64,
    iconTheme: const IconThemeData(color: _onPrimary),
    titleTextStyle: GoogleFonts.barlowCondensed(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.48,
      color: _onPrimary,
    ),
  ),

  cardTheme: const CardThemeData(
    color: _surfaceContainerLow,
    surfaceTintColor: Colors.transparent,
    elevation: 1,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
      side: BorderSide(color: _outlineVariant),
    ),
  ),

  dividerTheme: const DividerThemeData(
    color: _outlineVariant,
    thickness: 1,
    space: 1,
  ),

  iconTheme: const IconThemeData(color: _onSurfaceVariant, size: 20),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return _onSurface.withValues(alpha: 0.12);
        }
        if (states.contains(WidgetState.pressed)) {
          return _primaryContainer;
        }
        return _primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return _onSurface.withValues(alpha: 0.38);
        }
        return _onPrimary;
      }),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.barlowCondensed(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      minimumSize: WidgetStateProperty.all(const Size(0, 48)),
      elevation: WidgetStateProperty.all(0),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(_primary),
      side: WidgetStateProperty.resolveWith<BorderSide>((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: _outline.withValues(alpha: 0.38));
        }
        return const BorderSide(color: _primary, width: 1.5);
      }),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.barlowCondensed(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      minimumSize: WidgetStateProperty.all(const Size(0, 48)),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(_primary),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.barlowCondensed(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
  ),

  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: _primary,
    foregroundColor: _onPrimary,
    elevation: 2,
    focusElevation: 2,
    hoverElevation: 2,
    highlightElevation: 4,
    extendedTextStyle: GoogleFonts.barlowCondensed(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: _onPrimary,
    ),
    extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _surfaceContainerLowest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    labelStyle: GoogleFonts.jetBrainsMono(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.7,
      color: _onSurfaceVariant,
    ),
    floatingLabelStyle: GoogleFonts.jetBrainsMono(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.7,
      color: _primary,
    ),
    hintStyle: GoogleFonts.sourceSerif4(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: _onSurfaceVariant.withValues(alpha: 0.7),
    ),
    border: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
      borderSide: BorderSide(color: _outlineVariant),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
      borderSide: BorderSide(color: _outlineVariant),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
      borderSide: BorderSide(color: _primary, width: 2),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
      borderSide: BorderSide(color: _error),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
      borderSide: BorderSide(color: _error, width: 2),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: _surfaceContainer,
    selectedColor: _primaryContainer,
    secondarySelectedColor: _primaryContainer,
    disabledColor: _surfaceContainerHigh,
    labelStyle: GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      color: _onSurface,
    ),
    secondaryLabelStyle: GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.6,
      color: _onPrimaryContainer,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusChip)),
      side: BorderSide(color: _outlineVariant),
    ),
    side: const BorderSide(color: _outlineVariant),
  ),

  checkboxTheme: CheckboxThemeData(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusChip)),
    ),
    side: const BorderSide(color: _onSurfaceVariant, width: 2),
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) return _primary;
      return _surfaceContainerLowest;
    }),
    checkColor: WidgetStateProperty.all(_onPrimary),
  ),

  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) return _primary;
      return _onSurfaceVariant;
    }),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) return _primary;
      return _surfaceContainerHighest;
    }),
    trackColor: WidgetStateProperty.resolveWith<Color>((states) {
      if (states.contains(WidgetState.selected)) return _primaryContainer;
      return _surfaceContainerHigh;
    }),
    trackOutlineColor: WidgetStateProperty.all(_outline),
  ),

  dialogTheme: DialogThemeData(
    backgroundColor: _surfaceContainerLow,
    surfaceTintColor: Colors.transparent,
    elevation: 2,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusSheet)),
      side: BorderSide(color: _outlineVariant),
    ),
    titleTextStyle: _textTheme.headlineSmall,
    contentTextStyle: _textTheme.bodyMedium,
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: _surfaceContainerLow,
    surfaceTintColor: Colors.transparent,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(_radiusSheet),
        topRight: Radius.circular(_radiusSheet),
      ),
      side: BorderSide(color: _outlineVariant),
    ),
  ),

  snackBarTheme: SnackBarThemeData(
    backgroundColor: _inverseSurface,
    contentTextStyle: GoogleFonts.sourceSerif4(
      fontSize: 14,
      color: _inverseOnSurface,
    ),
    actionTextColor: _inversePrimary,
    behavior: SnackBarBehavior.floating,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
    ),
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: _primary,
    linearTrackColor: _surfaceContainerHigh,
    circularTrackColor: _surfaceContainerHigh,
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: _onSurfaceVariant,
    textColor: _onSurface,
  ),
);
