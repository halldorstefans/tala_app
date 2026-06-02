---
name: Heritage Workshop
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e4e2e1'
  on-surface: '#1b1c1c'
  on-surface-variant: '#404942'
  inverse-surface: '#303030'
  inverse-on-surface: '#f3f0f0'
  outline: '#717971'
  outline-variant: '#c0c9c0'
  surface-tint: '#316948'
  primary: '#002a15'
  on-primary: '#ffffff'
  primary-container: '#004225'
  on-primary-container: '#75af89'
  inverse-primary: '#98d4ac'
  secondary: '#af2d2d'
  on-secondary: '#ffffff'
  secondary-container: '#fe6761'
  on-secondary-container: '#69000a'
  tertiary: '#735c00'
  on-tertiary: '#ffffff'
  tertiary-container: '#cba72f'
  on-tertiary-container: '#4e3d00'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b4f0c7'
  primary-fixed-dim: '#98d4ac'
  on-primary-fixed: '#002110'
  on-primary-fixed-variant: '#165132'
  secondary-fixed: '#ffdad7'
  secondary-fixed-dim: '#ffb3ad'
  on-secondary-fixed: '#410004'
  on-secondary-fixed-variant: '#8e1319'
  tertiary-fixed: '#ffe088'
  tertiary-fixed-dim: '#e9c349'
  on-tertiary-fixed: '#241a00'
  on-tertiary-fixed-variant: '#574500'
  background: '#fcf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e1'
typography:
  headline-lg:
    fontFamily: Barlow Condensed
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: 0.02em
  headline-md:
    fontFamily: Barlow Condensed
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-sm:
    fontFamily: Barlow Condensed
    fontSize: 20px
    fontWeight: '600'
    lineHeight: '1.2'
  body-lg:
    fontFamily: Source Serif 4
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Source Serif 4
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: '1.4'
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Barlow Condensed
    fontSize: 32px
    fontWeight: '700'
    lineHeight: '1.1'
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 8px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
  max-width: 1280px
---

## Brand & Style

The design system is rooted in the "Tactile Skeuomorphic" movement, blended with "Industrial Brutalism." It seeks to evoke the sensory experience of a high-end restoration garage: the smell of aged leather, the weight of a steel wrench, and the matte texture of a printed shop manual. 

The target audience consists of automotive enthusiasts and restorers who value craftsmanship over convenience. The UI avoids the sterile "app" feel in favor of a physical logbook experience. Elements should feel heavy, anchored, and permanent. Every interaction should feel like a physical action—flipping a page, toggling a heavy switch, or stamping a metal plate.

Visual hallmarks include:
- **Paper & Grain:** Surfaces utilize subtle noise and parchment-like off-whites to eliminate digital glare.
- **Material Depth:** Usage of inset and outset shadows to simulate stamped metal and embossed leather.
- **Functional Wear:** A "weathered" but clean aesthetic where borders feel like ink on paper rather than pixels on a screen.

## Colors

The palette is inspired by mid-century automotive excellence and workshop utility.

- **Primary (British Racing Green):** Used for primary actions, branding, and "restored" status indicators. It represents prestige and completion.
- **Secondary (Toolbox Red):** Reserved for alerts, critical warnings, and "stop" actions. It mimics the high-visibility enamel of classic tool chests.
- **Tertiary (Brass/Oil):** A muted metallic yellow used for accents, highlights, and vintage trim details.
- **Neutral (Oil Black & Charcoal):** These are not pure blacks but weathered, desaturated tones that simulate grease-stained metal and vulcanized rubber.
- **Base (Parchment):** The primary background color is a warm, slightly yellowed off-white that feels like heavy-weight archival paper.

## Typography

Typography functions as "labels on a part" or "ink in a ledger."

- **Headlines (Industrial Sans):** `Barlow Condensed` provides the rugged, verticality of stamped VIN plates and technical manual covers. It should almost always be presented in uppercase with slight tracking to enhance the "industrial" feel.
- **Body (Archival Serif):** `Source Serif 4` offers high legibility for long-form restoration notes, mimicking the typeface of mid-century automotive guides.
- **Technical Data (Monospace):** `JetBrains Mono` is used for technical specs, part numbers, and timestamps, simulating typewriter entries or serial number engravings.

## Layout & Spacing

The layout philosophy follows a **Fixed Grid** system that mimics a physical ledger or a technical drawing board.

- **Structure:** Content is housed in "Sheets" or "Cards." On desktop, these sheets have generous outer margins (`64px`) to make the digital screen feel like a desk surface.
- **Rhythm:** An `8px` base unit governs all padding and margins. 
- **The Ledger Line:** Vertical and horizontal dividers are used frequently but subtly, mimicking the ruling of a notebook. 
- **Alignment:** Data-heavy sections (specs) should use a strict columnar alignment, while narrative sections (logs) allow for more breathing room and whitespace.

## Elevation & Depth

This design system eschews modern soft shadows in favor of **Physical Layering**.

- **Level 0 (The Workbench):** The darkest layer, a charcoal surface with a subtle leather or metallic texture.
- **Level 1 (The Paper):** Parchment-colored sheets that sit "on top" of the workbench. These use a sharp `2px` drop shadow with `20%` opacity—no blur—to suggest a physical edge.
- **Level 2 (The Tags):** Small elements like chips or badges that are "pinned" or "taped" to the paper.
- **Inset Depth:** Input fields and secondary containers use "inner shadows" to appear as if they are recessed or stamped into the material, reminiscent of a punch-press.

## Shapes

The shape language is "Soft-Industrial." Elements are not perfectly sharp (which feels aggressive) nor pill-shaped (which feels too modern/tech).

- **Standard Radius:** A `4px` (`0.25rem`) corner is applied to most buttons and containers, simulating the natural rounding of machined metal or cut cardstock.
- **Stamp Effect:** Status badges may use a "clipped corner" or a "serrated edge" effect to mimic vintage inspection stamps or perforated paper.
- **Hard Borders:** All elements are contained by a `1px` or `2px` solid border in a slightly darker shade than the surface, ensuring a defined physical footprint.

## Components

### Buttons & Controls
- **Primary Action:** Designed like an embossed metal plate. Deep green background, white uppercase Barlow text, and a subtle "bevel" effect created by a light top-border and a dark bottom-border.
- **Switches:** Instead of modern sliders, use "toggle" styles that look like physical industrial switches (metal or heavy plastic textures).

### Input Fields
- **The Ledger Input:** Eschew the "box" look. Use a single bottom border (like a lined notebook) with a label set in `JetBrains Mono` floating just above it. On focus, the line changes to British Racing Green.

### Cards & Sheets
- **The Work Order:** Cards should have a subtle paper texture overlay. Use "binder hole" icons or "staple" graphics in the corners of containers to reinforce the physical logbook metaphor.

### Chips & Tags
- **The Parts Tag:** Status chips for parts (e.g., "In Progress", "Sourced") should look like manila shipping tags, complete with a small circle icon representing a reinforced hole for a wire tie.

### Lists
- Use thin, weathered dividers. Every list item should feel like a row in a ledger, with consistent alignment for "Date," "Task," and "Mechanic" labels.