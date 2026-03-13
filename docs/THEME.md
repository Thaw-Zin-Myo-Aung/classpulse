# THEME.md
# ClassPulse — Design System & Theme Contract

> **AI Instruction:** All colors, typography, spacing, and radius values MUST come from this file.
> Never hardcode hex values inline. Never use `Colors.blue` or `Colors.grey` from Material.
> Always reference `AppColors`, `AppTextStyles`, `AppSpacing`, and `AppRadius` constants.

---

## 1. Color Palette (`AppColors`)

### Primary — Proton Purple

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#6D4AFF` | Main buttons, active nav, key icons |
| `primaryLight` | `#E3D9FF` | Chip backgrounds, input focus highlights |
| `primaryDark` | `#4B2FCC` | Pressed / ripple states |

### Backgrounds & Surfaces

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#FFFFFF` | All screen scaffolds |
| `surface` | `#F7F5FF` | Cards, form containers, bottom sheets |
| `surfaceVariant` | `#EEE9FF` | Mood selector tiles, inactive chips |

### Text

| Token | Hex | Usage |
|-------|-----|-------|
| `textPrimary` | `#1B1340` | Headings, labels, body copy |
| `textSecondary` | `#6B6B8A` | Subtitles, placeholder text, hints |
| `textOnPrimary` | `#FFFFFF` | Text on purple buttons |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#4AB748` | Check-in confirmed, completed status |
| `error` | `#FF4444` | Validation errors, failed GPS/QR |
| `warning` | `#F5A623` | Partial states, retry prompts |

### Borders & Dividers

| Token | Hex | Usage |
|-------|-----|-------|
| `border` | `#E0DAFF` | Input borders, card outlines, dividers |

### Dart Class

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary        = Color(0xFF6D4AFF);
  static const Color primaryLight   = Color(0xFFE3D9FF);
  static const Color primaryDark    = Color(0xFF4B2FCC);

  // Backgrounds & Surfaces
  static const Color background     = Color(0xFFFFFFFF);
  static const Color surface        = Color(0xFFF7F5FF);
  static const Color surfaceVariant = Color(0xFFEEE9FF);

  // Text
  static const Color textPrimary    = Color(0xFF1B1340);
  static const Color textSecondary  = Color(0xFF6B6B8A);
  static const Color textOnPrimary  = Color(0xFFFFFFFF);

  // Semantic
  static const Color success        = Color(0xFF4AB748);
  static const Color error          = Color(0xFFFF4444);
  static const Color warning        = Color(0xFFF5A623);

  // Border
  static const Color border         = Color(0xFFE0DAFF);
}
```

---

## 2. Typography (`AppTextStyles`)

### Font Family

**Plus Jakarta Sans** — Google Fonts

```yaml
# pubspec.yaml dependency
google_fonts: ^6.2.1
```

```dart
// Usage in theme
fontFamily: GoogleFonts.plusJakartaSans().fontFamily
```

### Type Scale

| Token | Size | Weight | Usage |
|-------|------|--------|-------|
| `displayLarge` | 28px | Bold (700) | Screen titles (e.g. "Check In") |
| `displayMedium` | 24px | SemiBold (600) | Section headers |
| `titleLarge` | 20px | SemiBold (600) | Card titles, form section labels |
| `titleMedium` | 16px | SemiBold (600) | Input labels, list item titles |
| `bodyLarge` | 16px | Regular (400) | Body text, form field values |
| `bodyMedium` | 14px | Regular (400) | Secondary body, descriptions |
| `labelLarge` | 14px | SemiBold (600) | Button text |
| `labelSmall` | 12px | Medium (500) | Captions, timestamps, hints |

### Dart Class

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classpulse/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
    fontSize: 24, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
```

---

## 3. Spacing (`AppSpacing`)

All spacing follows an **8px base grid**.

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Icon padding, tight gaps |
| `sm` | 8px | Between inline elements |
| `md` | 16px | Standard screen padding, form gaps |
| `lg` | 24px | Section spacing |
| `xl` | 32px | Top/bottom screen breathing room |
| `xxl` | 48px | Hero sections, large empty states |

```dart
class AppSpacing {
  AppSpacing._();

  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double xxl = 48.0;
}
```

---

## 4. Border Radius (`AppRadius`)

Style: **Rounded & Soft**

| Token | Value | Usage |
|-------|-------|-------|
| `sm` | 8px | Small chips, tags |
| `md` | 12px | Input fields, small cards |
| `lg` | 16px | Main cards, bottom sheets |
| `xl` | 24px | Primary buttons, large containers |
| `full` | 999px | Pills, avatar circles, FABs |

```dart
class AppRadius {
  AppRadius._();

  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double full = 999.0;
}
```

---

## 5. Component Styles

### Primary Button
- Background: `AppColors.primary`
- Text: `AppTextStyles.labelLarge` (white)
- Border Radius: `AppRadius.xl` (24px)
- Height: 52px
- Elevation: 0 (flat)
- Pressed color: `AppColors.primaryDark`

### Secondary Button (Outlined)
- Background: transparent
- Border: 1.5px `AppColors.primary`
- Text: `AppTextStyles.labelLarge` in `AppColors.primary`
- Border Radius: `AppRadius.xl`
- Height: 52px

### Input Field
- Fill color: `AppColors.surface`
- Border: 1px `AppColors.border`
- Focused border: 2px `AppColors.primary`
- Border Radius: `AppRadius.md` (12px)
- Label style: `AppTextStyles.titleMedium`
- Hint style: `AppTextStyles.bodyMedium`

### Card
- Background: `AppColors.surface`
- Border Radius: `AppRadius.lg` (16px)
- Elevation: 0
- Border: 1px `AppColors.border`
- Padding: `AppSpacing.md` (16px)

### Mood Tile (Atom)
- Background unselected: `AppColors.surfaceVariant`
- Background selected: `AppColors.primaryLight`
- Border selected: 2px `AppColors.primary`
- Border Radius: `AppRadius.md` (12px)
- Size: 56x56px

---

## 6. Full MaterialTheme Setup

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      outline: AppColors.border,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
```

---

## AI Hallucination Warnings

> ⚠️ Do NOT use `Colors.purple`, `Colors.blue`, or any Material built-in color constants.

> ⚠️ Do NOT hardcode font sizes inline. Always use `AppTextStyles.*`.

> ⚠️ Do NOT hardcode padding values like `EdgeInsets.all(16)`. Use `AppSpacing.md`.

> ⚠️ Do NOT set `borderRadius: BorderRadius.circular(8)` inline. Use `AppRadius.*`.

> ⚠️ `AppTheme.lightTheme` is the ONLY theme. Do NOT generate a dark theme.
