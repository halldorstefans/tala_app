# Tala - Design System

**Version 1.0** | Last Updated: October 2025

## Design Philosophy

**Core Feeling:** A vintage workshop where classic car enthusiasts document their restoration journey. Warm, tactile, authentic—not sterile or corporate.

**Guiding Principles:**
1. **Texture over flatness** - Subtle depth and materiality
2. **Craft over perfection** - Authentic, lived-in quality
3. **Function with character** - Every element tells a story
4. **Timeless not trendy** - Classic aesthetic that ages well

---

## Color System

### Primary Colors
```
Garage Gray (Primary)
- Dark: #2C2C2E
- Medium: #3A3A3C  
- Light: #48484A
- Usage: Headers, navigation, primary buttons

Aged Paper (Background)
- Base: #F5F3EE
- Tint: #FAFAF8
- Usage: Main backgrounds, card surfaces
```

### Accent Colors
```
Brass Patina (Accent 1)
- Base: #B8860B
- Light: #D4A017
- Dark: #9A7209
- Usage: Highlights, active states, success indicators

Engine Blue (Accent 2)
- Base: #1B4965
- Light: #2D5F7F
- Dark: #0F2E3F
- Usage: Links, informational elements

Leather Brown (Accent 3)
- Base: #8B4513
- Light: #A0522D
- Dark: #654321
- Usage: Warm accents, secondary elements

Safety Orange (Highlight)
- Base: #FF6B35
- Usage: Warnings, important actions, CTAs

British Racing Green (Success)
- Base: #004225
- Light: #006837
- Usage: Completed tasks, success states
```

### Semantic Colors
```
Success: #004225 (British Racing Green)
Warning: #FF6B35 (Safety Orange)
Error: #C41E3A (Deep red)
Info: #1B4965 (Engine Blue)
```

### Text Colors
```
Primary Text: #2C2C2E (90% opacity)
Secondary Text: #3A3A3C (70% opacity)
Disabled Text: #48484A (40% opacity)
Inverse Text: #F5F3EE (on dark backgrounds)
```

---

## Typography

### Font Families
```css
--font-display: 'DIN Condensed', 'Arial Narrow', sans-serif;
--font-technical: 'IBM Plex Mono', 'Courier New', monospace;
--font-body: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
```

### Type Scale
```
Display Large: 48px / 56px (line-height) | Bold | DIN Condensed
Display Medium: 36px / 44px | Bold | DIN Condensed
Display Small: 28px / 36px | Bold | DIN Condensed

Heading 1: 24px / 32px | Bold | DIN Condensed
Heading 2: 20px / 28px | SemiBold | DIN Condensed
Heading 3: 16px / 24px | SemiBold | Inter

Body Large: 16px / 24px | Regular | Inter
Body Medium: 14px / 20px | Regular | Inter
Body Small: 12px / 16px | Regular | Inter

Technical: 13px / 20px | Regular | IBM Plex Mono
Label: 12px / 16px | Medium | Inter (UPPERCASE, 0.5px letter-spacing)
Caption: 11px / 14px | Regular | Inter
```

### Usage Guidelines
- **Display fonts:** Vehicle names, page titles
- **Headings:** Section titles, card headers
- **Body text:** Descriptions, notes, content
- **Technical font:** Part numbers, VIN, mileage, costs, dates, specifications
- **Labels:** Form labels, tags, status badges

---

## Spacing System

Based on 8px grid for consistency and alignment.

```
--space-1: 4px    (micro spacing)
--space-2: 8px    (tight spacing)
--space-3: 12px   (compact spacing)
--space-4: 16px   (default spacing)
--space-5: 20px   (comfortable spacing)
--space-6: 24px   (relaxed spacing)
--space-8: 32px   (section spacing)
--space-10: 40px  (large spacing)
--space-12: 48px  (extra large spacing)
--space-16: 64px  (page margins)
```

### Common Patterns
- **Component padding:** 16px (space-4)
- **Card padding:** 20px (space-5)
- **Section gaps:** 32px (space-8)
- **Page margins:** 64px desktop, 16px mobile (space-16/space-4)
- **Form field spacing:** 12px (space-3)

---

## Layout Grid

### Desktop (1200px+)
```
12-column grid
Column width: flexible
Gutter: 24px
Margin: 64px
```

### Tablet (768px - 1199px)
```
8-column grid
Column width: flexible
Gutter: 20px
Margin: 32px
```

### Mobile (<768px)
```
4-column grid
Column width: flexible
Gutter: 16px
Margin: 16px
```

---

## Components

### Buttons

#### Primary Button
```
Background: #B8860B (Brass)
Text: #2C2C2E (Dark Gray)
Font: Inter, 14px, SemiBold
Padding: 12px 24px
Border-radius: 2px (minimal rounding)
Text-transform: uppercase
Letter-spacing: 0.5px

Hover: Background #D4A017
Active: Background #9A7209
Disabled: Background #48484A, Opacity 0.4
```

#### Secondary Button
```
Background: transparent
Border: 2px solid #2C2C2E
Text: #2C2C2E
Font: Inter, 14px, SemiBold
Padding: 10px 24px (account for border)
Border-radius: 2px

Hover: Background #2C2C2E, Text #F5F3EE
Active: Background #3A3A3C
Disabled: Border and text 40% opacity
```

#### Icon Button
```
Size: 40x40px
Background: transparent
Icon color: #3A3A3C
Border-radius: 2px

Hover: Background #F5F3EE
Active: Background #EAEAE8
```

### Cards

#### Standard Card
```
Background: #FAFAF8
Border: 1px solid #E0DED9
Border-radius: 2px
Padding: 20px
Box-shadow: 0 1px 3px rgba(44, 44, 44, 0.08)

Hover: Box-shadow 0 2px 8px rgba(44, 44, 44, 0.12)
```

#### Vehicle Card
```
Same as standard card, plus:
Aspect ratio: 4:3 for photo area
Photo border-radius: 2px
Title: Heading 2 style
Subtitle: Body Medium, secondary text color
```

### Form Elements

#### Text Input
```
Height: 40px
Background: #FFFFFF
Border: 1px solid #C8C6C1
Border-radius: 2px
Padding: 0 12px
Font: IBM Plex Mono, 13px
Text color: #2C2C2E

Focus: Border #1B4965 (2px), Box-shadow 0 0 0 3px rgba(27, 73, 101, 0.1)
Error: Border #C41E3A
Disabled: Background #F5F3EE, Opacity 0.6
```

#### Text Area
```
Min-height: 120px
Same styling as text input
Padding: 12px
Resize: vertical only
```

#### Select Dropdown
```
Same as text input
Add down arrow icon (right side, 12px from edge)
```

#### Checkbox
```
Size: 20x20px
Border: 2px solid #3A3A3C
Border-radius: 2px
Background (checked): #B8860B
Checkmark: #2C2C2E

Focus: Box-shadow 0 0 0 3px rgba(184, 134, 11, 0.2)
```

#### Radio Button
```
Size: 20x20px (outer circle)
Border: 2px solid #3A3A3C
Border-radius: 50%
Inner dot: 10x10px, #B8860B

Focus: Box-shadow 0 0 0 3px rgba(184, 134, 11, 0.2)
```

### Navigation

#### Top Navigation Bar
```
Height: 64px
Background: #2C2C2E
Color: #F5F3EE
Border-bottom: 2px solid #B8860B
Padding: 0 64px (desktop), 0 16px (mobile)

Logo/Title: Display Small, #F5F3EE
Nav items: Body Medium, #F5F3EE (70% opacity)
Active item: #B8860B, 100% opacity
```

#### Sidebar Navigation
```
Width: 240px (desktop), full-width drawer (mobile)
Background: #FAFAF8
Border-right: 1px solid #E0DED9

Section header: Label style, #3A3A3C
Nav item: Body Medium, #2C2C2E, Padding 12px 20px
Active item: Background #B8860B (10% opacity), Border-left 3px solid #B8860B
Hover: Background #F5F3EE
```

### Tags/Badges

#### Status Badge
```
Padding: 4px 8px
Border-radius: 2px
Font: Caption, SemiBold, uppercase
Letter-spacing: 0.5px

Completed: Background #004225 (20% opacity), Text #004225
In Progress: Background #B8860B (20% opacity), Text #9A7209
Planned: Background #1B4965 (20% opacity), Text #1B4965
```

#### Part Number Tag
```
Background: #2C2C2E (10% opacity)
Text: #2C2C2E
Font: IBM Plex Mono, 11px
Padding: 4px 8px
Border-radius: 2px
```

### Tables

```
Background: #FFFFFF
Border: 1px solid #E0DED9

Header:
- Background: #F5F3EE
- Text: Label style, #2C2C2E
- Padding: 12px 16px
- Border-bottom: 2px solid #E0DED9

Row:
- Padding: 12px 16px
- Border-bottom: 1px solid #E0DED9
- Hover: Background #FAFAF8

Cells:
- Text: Body Medium
- Numbers: IBM Plex Mono (tabular-nums)
```

### Modals/Dialogs

```
Background: #FFFFFF
Border-radius: 2px
Box-shadow: 0 8px 32px rgba(44, 44, 44, 0.24)
Max-width: 600px
Padding: 32px

Header: Heading 1, margin-bottom 24px
Footer: padding-top 24px, border-top 1px solid #E0DED9

Overlay: Background rgba(44, 44, 44, 0.6)
```

---

## Icons

### Style Guidelines
- **Style:** Line icons, 2px stroke weight
- **Size:** 20px (default), 16px (small), 24px (large)
- **Color:** Inherit from parent text color
- **Alignment:** Centered with text baseline

### Icon Set
Use **Lucide Icons** or similar for consistency:
- Car: `car`
- Wrench: `wrench`
- Package: `package`
- Calendar: `calendar`
- DollarSign: `dollar-sign`
- Camera: `camera`
- File: `file-text`
- Clock: `clock`
- Settings: `settings`
- Plus: `plus`
- Check: `check`
- X: `x`
- ChevronDown: `chevron-down`
- Search: `search`

---

## Textures & Effects

### Background Texture
```css
/* Subtle concrete grain */
background-image: url('data:image/svg+xml,...'); /* Noise pattern */
opacity: 0.03;
```

### Card Shadow (depth)
```css
/* Elevated cards */
box-shadow: 
  0 1px 3px rgba(44, 44, 44, 0.08),
  0 1px 2px rgba(44, 44, 44, 0.04);

/* Hover state */
box-shadow: 
  0 4px 12px rgba(44, 44, 44, 0.12),
  0 2px 4px rgba(44, 44, 44, 0.08);
```

### Focus Ring
```css
/* Accessible focus indicator */
box-shadow: 0 0 0 3px rgba(184, 134, 11, 0.3);
outline: none;
```

---

## Animation & Transitions

### Timing Functions
```css
--ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
--ease-out: cubic-bezier(0.0, 0, 0.2, 1);
--ease-in: cubic-bezier(0.4, 0, 1, 1);
```

### Duration
```css
--duration-fast: 150ms;
--duration-base: 250ms;
--duration-slow: 350ms;
```

### Common Transitions
```css
/* Hover effects */
transition: all 250ms cubic-bezier(0.4, 0, 0.2, 1);

/* Color changes */
transition: color 150ms cubic-bezier(0.4, 0, 0.2, 1);

/* Opacity fades */
transition: opacity 250ms cubic-bezier(0.0, 0, 0.2, 1);

/* Scale effects */
transition: transform 250ms cubic-bezier(0.4, 0, 0.2, 1);
```

### Micro-interactions
- **Button press:** Scale to 0.98
- **Card hover:** Lift 2px (translateY)
- **Check complete:** Scale bounce (0 → 1.1 → 1)
- **Loading:** Subtle pulse on brass accent

---

## Responsive Breakpoints

```css
--breakpoint-mobile: 0px;
--breakpoint-tablet: 768px;
--breakpoint-desktop: 1200px;
--breakpoint-wide: 1600px;
```

### Responsive Patterns

#### Stack on Mobile
```
Desktop: Side-by-side (flex-direction: row)
Mobile: Stacked (flex-direction: column)
```

#### Hide/Show Elements
```
Desktop: Show detailed stats, full navigation
Mobile: Simplified stats, hamburger menu
```

#### Adjust Spacing
```
Desktop: 64px page margins
Tablet: 32px page margins
Mobile: 16px page margins
```

---

## Component Patterns

### Vehicle Card Pattern
```html
<div class="vehicle-card">
  <img class="vehicle-card__image" src="..." alt="Vehicle name" />
  <div class="vehicle-card__content">
    <h2 class="vehicle-card__title">1967 Ford Mustang</h2>
    <p class="vehicle-card__subtitle">Last work: 3 days ago</p>
    <div class="vehicle-card__footer">
      <span class="badge badge--completed">Completed</span>
      <button class="button button--secondary button--small">View Details</button>
    </div>
  </div>
</div>
```

### Maintenance Log Entry Pattern
```html
<div class="maintenance-entry">
  <div class="maintenance-entry__header">
    <span class="technical-text">Work Order #0342</span>
    <span class="badge badge--in-progress">In Progress</span>
  </div>
  <h3 class="maintenance-entry__title">Engine Rebuild</h3>
  <div class="maintenance-entry__meta">
    <span class="technical-text">Oct 21, 2025</span>
    <span class="technical-text">45,234 mi</span>
    <span class="technical-text">$2,847.50</span>
  </div>
  <p class="maintenance-entry__description">...</p>
  <div class="maintenance-entry__parts">
    <span class="tag tag--part">Spark Plugs (RN12YC)</span>
    <span class="tag tag--part">Oil Filter (FL-1A)</span>
  </div>
</div>
```

### Form Field Pattern
```html
<div class="form-field">
  <label class="form-field__label">Part Number</label>
  <input 
    type="text" 
    class="form-field__input form-field__input--technical" 
    placeholder="ABC-12345"
  />
  <span class="form-field__hint">Enter OEM or aftermarket part number</span>
</div>
```

---

## Accessibility Guidelines

### Color Contrast
- All text must meet WCAG AA standards (4.5:1 for normal text)
- Interactive elements must be distinguishable (3:1 minimum)
- Don't rely on color alone for information

### Focus States
- All interactive elements must have visible focus indicators
- Focus ring: 3px solid brass accent at 30% opacity
- Never remove focus outlines without replacement

### Keyboard Navigation
- Tab order must follow logical reading order
- All actions accessible via keyboard
- ESC closes modals/dropdowns
- Arrow keys for navigation where appropriate

### Screen Readers
- Use semantic HTML elements
- Provide alt text for all images
- Use ARIA labels for icon-only buttons
- Announce dynamic content changes

### Touch Targets
- Minimum 44x44px for touch targets
- Adequate spacing between clickable elements (8px minimum)

---

## Usage Examples for AI

### Prompt Template for AI Code Generation

```
Create a [COMPONENT_NAME] using The Garage design system with these specifications:
- Colors: [specific colors from palette]
- Typography: [specific text styles]
- Spacing: [specific spacing values]
- Component type: [button/card/form/etc]
- State: [default/hover/active/disabled]
- Responsive: [yes/no, breakpoint behavior]

Ensure accessibility with proper ARIA labels and keyboard support.
```

### Example AI Prompt

```
Create a vehicle card component using The Garage design system:
- Background: Aged Paper Tint (#FAFAF8)
- Border: 1px solid #E0DED9
- Border-radius: 2px
- Padding: 20px (space-5)
- Title: Heading 2 style (DIN Condensed, 20px, SemiBold)
- Subtitle: Body Medium, secondary text color
- Include hover state with elevated shadow
- Responsive: full-width on mobile, max-width 320px on desktop
- Accessible with proper semantic HTML and ARIA labels
```

---

## Flutter Implementation Reference

### Theme Configuration
```dart
ThemeData garageTheme = ThemeData(
  // Colors
  primaryColor: Color(0xFF2C2C2E),
  primaryColorLight: Color(0xFF48484A),
  accentColor: Color(0xFFB8860B),
  scaffoldBackgroundColor: Color(0xFFF5F3EE),
  cardColor: Color(0xFFFAFAF8),
  
  // Typography
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'DINCondensed',
      fontSize: 48,
      fontWeight: FontWeight.bold,
      height: 1.17,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'DINCondensed',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'IBMPlexMono',
      fontSize: 13,
      height: 1.54,
    ),
  ),
  
  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFB8860B),
      foregroundColor: Color(0xFF2C2C2E),
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    ),
  ),
  
  // Input Decoration
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(color: Color(0xFFC8C6C1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(2),
      borderSide: BorderSide(color: Color(0xFF1B4965), width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  ),
);
```

### Custom Widget Example
```dart
class VehicleCard extends StatelessWidget {
  final String name;
  final String lastWork;
  final String imageUrl;
  
  const VehicleCard({
    required this.name,
    required this.lastWork,
    required this.imageUrl,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: BorderSide(color: Color(0xFFE0DED9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 4),
                Text(
                  'Last work: $lastWork',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Color(0xFF3A3A3C).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Design Tokens (JSON Format)

For programmatic access:

```json
{
  "colors": {
    "primary": {
      "dark": "#2C2C2E",
      "medium": "#3A3A3C",
      "light": "#48484A"
    },
    "accent": {
      "brass": "#B8860B",
      "brassLight": "#D4A017",
      "brassDark": "#9A7209"
    },
    "background": {
      "base": "#F5F3EE",
      "tint": "#FAFAF8"
    },
    "semantic": {
      "success": "#004225",
      "warning": "#FF6B35",
      "error": "#C41E3A",
      "info": "#1B4965"
    }
  },
  "typography": {
    "fontFamily": {
      "display": "DIN Condensed, Arial Narrow, sans-serif",
      "technical": "IBM Plex Mono, Courier New, monospace",
      "body": "Inter, -apple-system, BlinkMacSystemFont, sans-serif"
    },
    "fontSize": {
      "displayLarge": "48px",
      "heading1": "24px",
      "bodyMedium": "14px",
      "technical": "13px",
      "caption": "11px"
    }
  },
  "spacing": {
    "1": "4px",
    "2": "8px",
    "3": "12px",
    "4": "16px",
    "5": "20px",
    "6": "24px",
    "8": "32px",
    "10": "40px",
    "12": "48px",
    "16": "64px"
  },
  "borderRadius": {
    "minimal": "2px",
    "small": "4px",
    "medium": "8px",
    "circle": "50%"
  }
}
```

---

## Version History

**v1.0 (Oct 2025)**
- Initial design system release
- Core components and patterns
- Color palette and typography defined
- Accessibility guidelines established