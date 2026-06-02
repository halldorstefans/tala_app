# Tala — Design System (Core Theme)

This document defines the theme layer for Tala's initial build. It covers colors, typography, spacing, and elevation — everything needed to configure a Flutter `ThemeData` and achieve a consistent visual identity without custom widgets.

The skeuomorphic component treatments (paper textures, binder holes, stamped-metal buttons, manila tags) are documented separately in `DESIGN.md` and deferred to a later polish phase.

---

## Identity

**Heritage Workshop.** The visual language draws from mid-century automotive manuals, workshop ledgers, and restoration garage aesthetics. The goal is warmth and weight — surfaces that feel like paper, type that feels like ink, colors that feel like paint on metal. The app should never feel sterile or generic, but the identity comes from the theme, not from decorative illustration.

---

## Colors

Material 3 color scheme. All values below map directly to Flutter's `ColorScheme`.

### Primary — British Racing Green

The brand color. Used for primary actions, active states, navigation highlights, and "completed" status.

| Token                    | Value     |
|--------------------------|-----------|
| primary                  | `#002A15` |
| onPrimary                | `#FFFFFF` |
| primaryContainer         | `#004225` |
| onPrimaryContainer       | `#75AF89` |
| inversePrimary           | `#98D4AC` |
| primaryFixed             | `#B4F0C7` |
| primaryFixedDim          | `#98D4AC` |
| onPrimaryFixed           | `#002110` |
| onPrimaryFixedVariant    | `#165132` |

### Secondary — Toolbox Red

Alerts, destructive actions, critical warnings. Use sparingly.

| Token                    | Value     |
|--------------------------|-----------|
| secondary                | `#AF2D2D` |
| onSecondary              | `#FFFFFF` |
| secondaryContainer       | `#FE6761` |
| onSecondaryContainer     | `#69000A` |
| secondaryFixed           | `#FFDAD7` |
| secondaryFixedDim        | `#FFB3AD` |
| onSecondaryFixed         | `#410004` |
| onSecondaryFixedVariant  | `#8E1319` |

### Tertiary — Brass / Oil

Accents, highlights, in-progress status, cost/currency indicators.

| Token                    | Value     |
|--------------------------|-----------|
| tertiary                 | `#735C00` |
| onTertiary               | `#FFFFFF` |
| tertiaryContainer        | `#CBA72F` |
| onTertiaryContainer      | `#4E3D00` |
| tertiaryFixed            | `#FFE088` |
| tertiaryFixedDim         | `#E9C349` |
| onTertiaryFixed          | `#241A00` |
| onTertiaryFixedVariant   | `#574500` |

### Neutral — Surfaces

Warm parchment base. Avoid pure whites and pure blacks.

| Token                    | Value     |
|--------------------------|-----------|
| surface                  | `#FCF9F8` |
| surfaceDim               | `#DCD9D9` |
| surfaceBright            | `#FCF9F8` |
| surfaceContainerLowest   | `#FFFFFF` |
| surfaceContainerLow      | `#F6F3F2` |
| surfaceContainer         | `#F0EDED` |
| surfaceContainerHigh     | `#EAE7E7` |
| surfaceContainerHighest  | `#E4E2E1` |
| onSurface                | `#1B1C1C` |
| onSurfaceVariant         | `#404942` |
| inverseSurface           | `#303030` |
| inverseOnSurface         | `#F3F0F0` |
| outline                  | `#717971` |
| outlineVariant           | `#C0C9C0` |
| surfaceTint              | `#316948` |

### Error

| Token                    | Value     |
|--------------------------|-----------|
| error                    | `#BA1A1A` |
| onError                  | `#FFFFFF` |
| errorContainer           | `#FFDAD6` |
| onErrorContainer         | `#93000A` |

### Semantic Usage

| Meaning              | Color              | Where                                      |
|----------------------|--------------------|---------------------------------------------|
| Completed / done     | Primary green      | Status chips, checkmarks, completed borders |
| In progress          | Tertiary brass     | Status chips, progress indicators           |
| Planned / pending    | Outline / neutral  | Status chips, muted text                    |
| Warning / delete     | Secondary red      | Delete buttons, alerts, error states        |
| Cost / currency      | Tertiary brass     | Cost fields, totals                         |
| Interactive / active | Primary green      | FAB, active nav, focused inputs             |

---

## Typography

Three type families, each with a distinct role.

### Barlow Condensed — Headlines & Labels

Industrial, vertical, stamped-metal feel. Use for screen titles, section headers, and navigation labels. Uppercase with slight letter-spacing for headers.

| Style        | Size | Weight   | Line Height | Letter Spacing | Usage                        |
|--------------|------|----------|-------------|----------------|------------------------------|
| headlineLg   | 48px | Bold 700 | 1.1         | 0.02em         | Hero / screen title (tablet) |
| headlineMd   | 32px | Semi 600 | 1.2         | —              | Screen titles                |
| headlineSm   | 20px | Semi 600 | 1.2         | —              | Section headers, card titles |
| mobile override | 32px | Bold 700 | 1.1      | —              | headlineLg on phone screens  |

### Source Serif 4 — Body Text

Archival serif for readability. Use for job descriptions, notes, and any long-form text.

| Style   | Size | Weight      | Line Height | Usage                          |
|---------|------|-------------|-------------|--------------------------------|
| bodyLg  | 18px | Regular 400 | 1.6         | Primary body text, descriptions|
| bodyMd  | 16px | Regular 400 | 1.6         | Secondary body, captions       |

### JetBrains Mono — Technical Data

Monospace for anything that looks like data: part numbers, VINs, timestamps, odometer readings, costs.

| Style   | Size | Weight    | Line Height | Letter Spacing | Usage                        |
|---------|------|-----------|-------------|----------------|------------------------------|
| labelMd | 14px | Medium 500| 1.4         | 0.05em         | Part numbers, dates, specs   |

### Flutter Implementation Note

Define these as `TextTheme` entries in your `ThemeData`. Use Google Fonts package for Barlow Condensed and Source Serif 4. JetBrains Mono is available via google_fonts or can be bundled.

```dart
// Indicative structure — adapt to your ThemeData setup
textTheme: TextTheme(
  headlineLarge: barlowCondensed(48, FontWeight.w700, 1.1),
  headlineMedium: barlowCondensed(32, FontWeight.w600, 1.2),
  headlineSmall: barlowCondensed(20, FontWeight.w600, 1.2),
  bodyLarge: sourceSerif4(18, FontWeight.w400, 1.6),
  bodyMedium: sourceSerif4(16, FontWeight.w400, 1.6),
  labelMedium: jetbrainsMono(14, FontWeight.w500, 1.4),
)
```

---

## Spacing

8px base unit throughout.

| Token         | Value  | Usage                                   |
|---------------|--------|-----------------------------------------|
| unit          | 8px    | Base increment for all padding/margins  |
| gutter        | 24px   | Gap between columns/cards               |
| margin-mobile | 16px   | Screen edge padding on phone            |
| margin-desktop| 64px   | Screen edge padding on tablet/desktop   |
| max-width     | 1280px | Content max-width (future web)          |

Standard increments: 4, 8, 12, 16, 24, 32, 48, 64.

---

## Corner Radius

Soft-industrial: not sharp, not pill-shaped. Machined metal or cut cardstock.

| Token   | Value     | Usage                                |
|---------|-----------|--------------------------------------|
| sm      | 2px       | Chips, small badges                  |
| default | 4px       | Buttons, inputs, cards               |
| md      | 6px       | Dialogs, sheets                      |
| lg      | 8px       | Large containers, bottom sheets      |
| xl      | 12px      | Modal surfaces                       |
| full    | 9999px    | Circular avatars, FAB                |

Default everything to 4px. Only deviate with reason.

---

## Elevation & Depth

Three levels. Use sharp, low-blur shadows to maintain the physical-object feel.

| Level | Name          | Shadow                              | Usage                              |
|-------|---------------|--------------------------------------|------------------------------------|
| 0     | Workbench     | None                                 | Background surface                 |
| 1     | Paper         | `2px` offset, `20%` opacity, no blur | Cards, sheets, dialogs             |
| 2     | Tag           | `1px` offset, `15%` opacity, no blur | Chips, FAB, floating elements      |
| Inset | Stamped       | Inner shadow, `10%` opacity          | Input fields, recessed containers  |

In Flutter, map these to custom `BoxDecoration` shadows rather than Material's default elevation, which uses soft blurred shadows. For the initial build, Material's built-in elevation is acceptable — the sharp-shadow refinement can come in the polish phase.

---

## Borders

All containers get a visible border. This is a defining trait of the visual style — elements have physical edges.

| Usage              | Width | Color            |
|--------------------|-------|------------------|
| Cards, containers  | 1px   | `outlineVariant` |
| Active / focused   | 2px   | `primary`        |
| Dividers, rules    | 1px   | `outlineVariant` |

---

## Status Chips

Simple, flat chips using the semantic color mapping above. No custom shapes yet — standard Flutter `Chip` or `FilterChip` with the right color fill.

| Status       | Background         | Text/Icon          |
|--------------|--------------------|--------------------|
| Completed    | `primaryContainer` | `onPrimaryContainer` |
| In Progress  | `tertiaryContainer`| `onTertiaryContainer`|
| Planned      | `surfaceContainer` | `onSurface`        |

---

## Garage Readability

These aren't decorative choices — they're usability constraints for the primary context (phone in a garage, possibly dim lighting, dirty hands).

- **Minimum tap target:** 48x48px (Material default). For primary actions like quick-add, go larger: 56px FAB.
- **Contrast:** The warm parchment surface with dark on-surface text exceeds WCAG AA. Don't lighten body text below `onSurface`.
- **Font size floor:** No text smaller than 14px (`labelMd`). Part numbers and timestamps at 14px mono are the smallest elements.
- **Input focus:** Green bottom-border on focus. Clear, visible state change — no subtle opacity shifts.

---

## What This Document Doesn't Cover

The following are defined in the full `DESIGN.md` and deferred to a polish phase:

- Paper/grain texture overlays on surfaces
- Binder-hole and staple decorative elements on cards
- Stamped-metal bevel effects on buttons
- Manila-tag shaped status chips with reinforced-hole icons
- Industrial toggle switch styling
- Serrated / perforated edge effects on badges
- Leather or metallic textures on surfaces

The theme layer defined here gives the app its identity. The component treatments above give it personality — they're worth doing, but after the app is useful.
