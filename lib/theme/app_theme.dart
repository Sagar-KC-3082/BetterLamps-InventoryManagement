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
  final Color bg0;
  final Color shadow;

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
    required this.bg0,
    required this.shadow,
  });

  static const dark = BLColors(
    bg0:       Color(0xFF050507),
    bg:        Color(0xFF09090B),   // zinc-950
    bg2:       Color(0xFF0F0F12),   // card surface
    bg3:       Color(0xFF18181C),   // elevated
    bgHover:   Color(0xFF1C1C21),
    ink:       Color(0xFFF8FAFC),   // near-white, cool
    ink2:      Color(0xFF94A3B8),   // slate-400
    muted:     Color(0xFF64748B),   // slate-500
    faint:     Color(0xFF334155),   // slate-700
    rule:      Color(0xFF1E1E26),   // barely visible
    rule2:     Color(0xFF2A2A34),
    coral:     Color(0xFF8B5CF6),   // violet-500
    coral2:    Color(0xFF7C3AED),   // violet-600
    coralSoft: Color(0x1A8B5CF6),
    moss:      Color(0xFF22C55E),   // green-500
    berry:     Color(0xFFF43F5E),   // rose-500
    gold:      Color(0xFFF59E0B),   // amber-500
    shadow:    Color(0x50000000),
  );

  static const light = BLColors(
    bg0:       Color(0xFFF0F0F3),
    bg:        Color(0xFFF8F8FB),   // very light gray
    bg2:       Color(0xFFFFFFFF),   // white cards
    bg3:       Color(0xFFF1F1F5),
    bgHover:   Color(0xFFF5F5F8),
    ink:       Color(0xFF18181B),   // zinc-900
    ink2:      Color(0xFF52525B),   // zinc-600
    muted:     Color(0xFFA1A1AA),   // zinc-400
    faint:     Color(0xFFD4D4D8),   // zinc-300
    rule:      Color(0xFFE4E4E7),   // zinc-200
    rule2:     Color(0xFFD4D4D8),
    coral:     Color(0xFF7C3AED),   // violet-700
    coral2:    Color(0xFF6D28D9),   // violet-800
    coralSoft: Color(0x0F7C3AED),
    moss:      Color(0xFF16A34A),   // green-600
    berry:     Color(0xFFE11D48),   // rose-600
    gold:      Color(0xFFD97706),   // amber-600
    shadow:    Color(0x12000000),
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
    Color? bg0,
    Color? shadow,
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
      bg0: bg0 ?? this.bg0,
      shadow: shadow ?? this.shadow,
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
      bg0: Color.lerp(bg0, other.bg0, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

// ---------------------------------------------------------------------------
// BLTextStyles — static helpers (Inter only)
// ---------------------------------------------------------------------------

class BLTextStyles {
  BLTextStyles._();

  static TextStyle h1(Color color) => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.5);
  static TextStyle h2(Color color) => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.3);
  static TextStyle h3(Color color) => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.2);
  static TextStyle body(Color color) => GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w400, color: color);
  static TextStyle label(Color color) => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: color, letterSpacing: 0.1);
  static TextStyle caption(Color color) => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: color);
  static TextStyle number(Color color) => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700, color: color, letterSpacing: -0.8,
    fontFeatures: [const FontFeature.tabularFigures()],
  );

  // Aliases for backward compatibility
  static TextStyle moneyValue(Color color) => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.3);
  static TextStyle monoLabel(Color color) => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: color, letterSpacing: 0.2);
  static TextStyle displayBig(Color color) => GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, color: color, letterSpacing: -1.0);
  static TextStyle sectionTitle(Color color) => GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: color, letterSpacing: -0.2);
  static TextStyle bodyUI(Color color) => GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w400, color: color);
  static TextStyle labelUI(Color color) => GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: color, letterSpacing: 0.1);
}

// ---------------------------------------------------------------------------
// BuildContext extensions
// ---------------------------------------------------------------------------

extension BLContextExtension on BuildContext {
  BLColors get blColors => BLColors.of(this);
  bool get blIsDark => Theme.of(this).brightness == Brightness.dark;

  Color get accentColor => blColors.coral;

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

  BoxShadow get cardShadow => BoxShadow(
    color: blColors.shadow,
    blurRadius: 12,
    offset: const Offset(0, 2),
  );

  LinearGradient get primaryGradient => LinearGradient(
        colors: [blColors.coral, blColors.coral2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  BoxDecoration get glassDecoration => BoxDecoration(
        color: blColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: blColors.rule, width: 0.5),
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
      displayLarge:  GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w700, letterSpacing: -1.0, color: ink),
      displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.7, color: ink),
      headlineSmall: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.4, color: ink),
      titleLarge:    GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: ink),
      titleMedium:   GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: -0.2, color: ink),
      bodyLarge:     GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: ink),
      bodyMedium:    GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w400, color: ink),
      bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: ink),
      labelLarge:    GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: ink),
      labelMedium:   GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: ink),
      labelSmall:    GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, letterSpacing: 0.2, color: ink),
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
        onPrimary: Colors.white,
        secondary: colors.moss,
        onSecondary: Colors.white,
        error: colors.berry,
        onError: Colors.white,
        surface: colors.bg2,
        onSurface: colors.ink,
        outline: colors.rule,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colors.bg2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        hintStyle: GoogleFonts.inter(fontSize: 13.5, color: colors.muted),
        labelStyle: GoogleFonts.inter(fontSize: 12.5, color: colors.muted, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.coral,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: colors.rule),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.muted,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: colors.rule, width: 0.5),
        ),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bg2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.rule, width: 0.5),
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
