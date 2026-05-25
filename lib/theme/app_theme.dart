import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// BLColors — ThemeExtension
// ---------------------------------------------------------------------------

class BLColors extends ThemeExtension<BLColors> {
  final Color bg;
  final Color bg2;
  final Color bg3;
  final Color bgHover;
  final Color ink;
  final Color ink2;
  final Color muted;
  final Color faint;
  final Color rule;
  final Color rule2;
  final Color coral;
  final Color coral2;
  final Color coralSoft;
  final Color moss;
  final Color berry;
  final Color gold;

  const BLColors({
    required this.bg,
    required this.bg2,
    required this.bg3,
    required this.bgHover,
    required this.ink,
    required this.ink2,
    required this.muted,
    required this.faint,
    required this.rule,
    required this.rule2,
    required this.coral,
    required this.coral2,
    required this.coralSoft,
    required this.moss,
    required this.berry,
    required this.gold,
  });

  static const dark = BLColors(
    bg:      Color(0xFF111113),   // near-black, faint cool tint
    bg2:     Color(0xFF18181B),   // zinc-900
    bg3:     Color(0xFF212126),   // elevated surface
    bgHover: Color(0xFF26262C),
    ink:     Color(0xFFF4F4F5),   // near-white
    ink2:    Color(0xFFA1A1AA),   // zinc-400
    muted:   Color(0xFF71717A),   // zinc-500
    faint:   Color(0xFF3F3F46),   // zinc-700
    rule:    Color(0xFF27272A),   // zinc-800
    rule2:   Color(0xFF3F3F46),
    coral:   Color(0xFFEA7B5B),   // slightly brighter in dark
    coral2:  Color(0xFFD96A4A),
    coralSoft: Color(0x1EEA7B5B),
    moss:    Color(0xFF8BB860),   // good green on dark
    berry:   Color(0xFFCB6070),
    gold:    Color(0xFFD4A853),
  );

  static const light = BLColors(
    bg:      Color(0xFFF4EDE0),   // warm parchment
    bg2:     Color(0xFFF0E8D8),   // card surface — warm cream, lighter than bg
    bg3:     Color(0xFFE8DFCC),   // elevated inside cards
    bgHover: Color(0xFFEDE5D4),
    ink:     Color(0xFF1A1714),
    ink2:    Color(0xFF4A4239),
    muted:   Color(0xFF8A8075),
    faint:   Color(0xFFB8B0A0),
    rule:    Color(0xFFDDD4C0),   // visible border on warm cards
    rule2:   Color(0xFFCFC5AF),
    coral:   Color(0xFFC8654A),
    coral2:  Color(0xFFA5503A),
    coralSoft: Color(0x14C8654A),
    moss:    Color(0xFF5E7544),   // slightly richer green
    berry:   Color(0xFF9E4D5B),
    gold:    Color(0xFFA18348),
  );

  static BLColors of(BuildContext context) =>
      Theme.of(context).extension<BLColors>()!;

  @override
  BLColors copyWith({
    Color? bg,
    Color? bg2,
    Color? bg3,
    Color? bgHover,
    Color? ink,
    Color? ink2,
    Color? muted,
    Color? faint,
    Color? rule,
    Color? rule2,
    Color? coral,
    Color? coral2,
    Color? coralSoft,
    Color? moss,
    Color? berry,
    Color? gold,
  }) {
    return BLColors(
      bg: bg ?? this.bg,
      bg2: bg2 ?? this.bg2,
      bg3: bg3 ?? this.bg3,
      bgHover: bgHover ?? this.bgHover,
      ink: ink ?? this.ink,
      ink2: ink2 ?? this.ink2,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      rule: rule ?? this.rule,
      rule2: rule2 ?? this.rule2,
      coral: coral ?? this.coral,
      coral2: coral2 ?? this.coral2,
      coralSoft: coralSoft ?? this.coralSoft,
      moss: moss ?? this.moss,
      berry: berry ?? this.berry,
      gold: gold ?? this.gold,
    );
  }

  @override
  BLColors lerp(BLColors? other, double t) {
    if (other == null) return this;
    return BLColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bg2: Color.lerp(bg2, other.bg2, t)!,
      bg3: Color.lerp(bg3, other.bg3, t)!,
      bgHover: Color.lerp(bgHover, other.bgHover, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      rule: Color.lerp(rule, other.rule, t)!,
      rule2: Color.lerp(rule2, other.rule2, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coral2: Color.lerp(coral2, other.coral2, t)!,
      coralSoft: Color.lerp(coralSoft, other.coralSoft, t)!,
      moss: Color.lerp(moss, other.moss, t)!,
      berry: Color.lerp(berry, other.berry, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
    );
  }
}

// ---------------------------------------------------------------------------
// BLTextStyles — static helpers
// ---------------------------------------------------------------------------

class BLTextStyles {
  BLTextStyles._();

  static TextStyle moneyValue(Color color) => GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: -0.4,
      );

  static TextStyle monoLabel(Color color) => GoogleFonts.jetBrainsMono(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 1.6,
      );

  static TextStyle displayBig(Color color) => GoogleFonts.newsreader(
        fontSize: 38,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: -0.95,
      );

  static TextStyle sectionTitle(Color color) => GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: -0.27,
      );

  static TextStyle bodyUI(Color color) => GoogleFonts.interTight(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: color,
        letterSpacing: -0.07,
      );

  static TextStyle labelUI(Color color) => GoogleFonts.interTight(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: -0.06,
      );
}

// ---------------------------------------------------------------------------
// BuildContext extensions
// ---------------------------------------------------------------------------

extension BLContextExtension on BuildContext {
  BLColors get blColors => BLColors.of(this);
  bool get blIsDark => Theme.of(this).brightness == Brightness.dark;

  // Legacy compat helpers for old screens still being migrated
  Color get backgroundColor => blColors.bg;
  Color get surfaceColor => blColors.bg2;
  Color get cardColor => blColors.bg2;
  Color get textPrimary => blColors.ink;
  Color get textSecondary => blColors.muted;
  Color get dividerColor => blColors.rule;
  Color get borderColor => blColors.rule;
  Color get primaryColor => blColors.coral;
  bool get isDarkMode => blIsDark;

  List<BoxShadow> get subtleShadow => [];
  List<BoxShadow> get brandShadow => [];

  LinearGradient get primaryGradient => LinearGradient(
        colors: [blColors.coral, blColors.coral2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  BoxDecoration get glassDecoration => BoxDecoration(
        color: blColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blColors.rule),
      );

  Color get successColor => blColors.moss;
  Color get successBgColor => blColors.moss.withOpacity(0.12);
  Color get warningColor => blColors.gold;
  Color get warningBgColor => blColors.gold.withOpacity(0.12);
  Color get errorColor => blColors.berry;
  Color get errorBgColor => blColors.berry.withOpacity(0.12);
}

// ---------------------------------------------------------------------------
// AppTheme
// ---------------------------------------------------------------------------

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color ink) {
    return TextTheme(
      displayLarge: GoogleFonts.newsreader(
        fontSize: 38,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.95,
        color: ink,
      ),
      displayMedium: GoogleFonts.newsreader(
        fontSize: 26,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.65,
        color: ink,
      ),
      headlineSmall: GoogleFonts.newsreader(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.33,
        color: ink,
      ),
      titleLarge: GoogleFonts.newsreader(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.27,
        color: ink,
      ),
      titleMedium: GoogleFonts.interTight(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.07,
        color: ink,
      ),
      bodyLarge: GoogleFonts.interTight(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.07,
        color: ink,
      ),
      bodyMedium: GoogleFonts.interTight(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.07,
        color: ink,
      ),
      bodySmall: GoogleFonts.interTight(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.06,
        color: ink,
      ),
      labelLarge: GoogleFonts.interTight(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.06,
        color: ink,
      ),
      labelMedium: GoogleFonts.jetBrainsMono(
        fontSize: 10.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
        color: ink,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 9.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: ink,
      ),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required BLColors colors,
  }) {
    final textTheme = _buildTextTheme(colors.ink);

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.bg,
      extensions: [colors],
      textTheme: textTheme,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.coral,
        onPrimary: colors.ink,
        secondary: colors.moss,
        onSecondary: colors.ink,
        error: colors.berry,
        onError: colors.ink,
        surface: colors.bg2,
        onSurface: colors.ink,
        outline: colors.rule,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.rule, width: 1),
        ),
      ),
      dividerColor: colors.rule,
      dividerTheme: DividerThemeData(color: colors.rule, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bg2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: colors.rule),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: colors.rule),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: colors.coral, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: colors.berry, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: GoogleFonts.interTight(
          fontSize: 13.5,
          color: colors.muted,
          letterSpacing: -0.07,
        ),
        labelStyle: GoogleFonts.interTight(
          fontSize: 12.5,
          color: colors.muted,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.06,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.coral,
          foregroundColor: colors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          textStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            fontSize: 13.5,
            letterSpacing: -0.07,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: colors.rule),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          ),
          textStyle: GoogleFonts.interTight(
            fontWeight: FontWeight.w500,
            fontSize: 13.5,
            letterSpacing: -0.07,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.muted,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: GoogleFonts.interTight(fontWeight: FontWeight.w500, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.rule),
        ),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.rule),
        ),
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme =>
      _buildTheme(brightness: Brightness.dark, colors: BLColors.dark);

  static ThemeData get lightTheme =>
      _buildTheme(brightness: Brightness.light, colors: BLColors.light);
}
