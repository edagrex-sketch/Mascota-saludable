---
name: Pet Health Management Design System
colors:
  surface: '#faf9f9'
  surface-dim: '#dadada'
  surface-bright: '#faf9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3f3'
  surface-container: '#eeeeed'
  surface-container-high: '#e8e8e8'
  surface-container-highest: '#e3e2e2'
  on-surface: '#1a1c1c'
  on-surface-variant: '#414849'
  inverse-surface: '#2f3131'
  inverse-on-surface: '#f1f1f0'
  outline: '#717879'
  outline-variant: '#c1c8c9'
  surface-tint: '#436468'
  primary: '#00262a'
  on-primary: '#ffffff'
  primary-container: '#1a3c40'
  on-primary-container: '#84a6ab'
  inverse-primary: '#aacdd1'
  secondary: '#7d562d'
  on-secondary: '#ffffff'
  secondary-container: '#ffca98'
  on-secondary-container: '#7a532a'
  tertiary: '#430f15'
  on-tertiary: '#ffffff'
  tertiary-container: '#5f2428'
  on-tertiary-container: '#dd8a8d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#c5e9ee'
  primary-fixed-dim: '#aacdd1'
  on-primary-fixed: '#001f23'
  on-primary-fixed-variant: '#2b4c50'
  secondary-fixed: '#ffdcbd'
  secondary-fixed-dim: '#f0bd8b'
  on-secondary-fixed: '#2c1600'
  on-secondary-fixed-variant: '#623f18'
  tertiary-fixed: '#ffdada'
  tertiary-fixed-dim: '#ffb3b5'
  on-tertiary-fixed: '#3b080f'
  on-tertiary-fixed-variant: '#723337'
  background: '#faf9f9'
  on-background: '#1a1c1c'
  surface-variant: '#e3e2e2'
typography:
  display-lg:
    fontFamily: Outfit
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Outfit
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
  headline-md:
    fontFamily: Outfit
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
  title-lg:
    fontFamily: Outfit
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  xxl: 48px
  container-margin: 20px
  gutter: 16px
---

## Brand & Style
The design system is rooted in the intersection of professional medical precision and the emotional warmth of pet companionship. It adopts a **Premium Modern** aesthetic—a refined evolution of Material 3 principles that prioritizes calm, clarity, and trust.

The visual narrative avoids the cluttered, "playful" tropes of typical pet apps in favor of a sophisticated, clinical-yet-caring atmosphere. By utilizing generous whitespace, soft depth, and a muted, nature-inspired palette, the system ensures that high-stakes health data feels manageable rather than overwhelming. The target audience is discerning pet owners who view their animals as family members and seek an authoritative, high-end experience for health management.

## Colors
The palette is anchored by **Deep Petrol Blue**, providing a foundation of authority and stability. **Muted Gold** is used sparingly for premium accents, achievements, and highlight states, while **Soft Coral** provides a warm, emotional touchpoint for interactive elements.

- **Primary (Deep Petrol):** Core actions, headers, and active navigation states.
- **Secondary (Muted Gold):** Accents, premium features, and high-value notifications.
- **Surface & Background:** Ivory and pure white are layered to create a sense of physical stacks.
- **Semantic States:** All status colors are desaturated to maintain the "premium" feel, avoiding neon or overly vibrant tones.
- **Dark Mode:** In dark mode, the primary petrol shifts to a slightly lighter tint (#2A5C61) to maintain contrast, and the background utilizes a deep charcoal-teal (#0F1A1B) rather than pure black.

## Typography
The typography strategy uses **Outfit** for headlines to provide a modern, geometric character that feels fresh and premium. For functional text and data, **Inter** is employed for its exceptional legibility and neutral, systematic tone.

- **Hierarchy:** Use heavy weights for headlines to create a clear "scan-path" for pet health vitals.
- **Letter Spacing:** Headlines utilize slight negative tracking for a tighter, editorial feel, while labels use positive tracking for clarity at small sizes.
- **Scale:** On mobile, high-level headers scale down to prevent awkward line breaks while maintaining their relative visual weight.

## Layout & Spacing
This design system uses a strict **8px grid system** for all spatial relationships, with 4px increments for micro-adjustments in typography and small components.

- **Mobile Layout:** A 4-column fluid grid with 20px side margins and 16px gutters.
- **Whitespace:** Elements are given room to "breathe." Never crowd data cards; use `xl` spacing (32px) between major logical sections (e.g., separating "Upcoming Vaccines" from "Recent Activity").
- **Alignment:** All text should align to the 4px baseline grid to maintain vertical rhythm across multi-column data layouts.

## Elevation & Depth
Depth is conveyed through **Soft Tonal Layering** and diffused shadows, avoiding harsh borders.

- **Level 0 (Background):** Ivory (#FAFAFA). Used for the base canvas.
- **Level 1 (Cards/Surface):** Pure White (#FFFFFF). Uses a subtle ambient shadow: `0px 4px 20px rgba(26, 60, 64, 0.04)`.
- **Level 2 (Floating/Modals):** Pure White with an increased shadow: `0px 10px 30px rgba(26, 60, 64, 0.08)`.
- **Interaction:** Upon press, cards should slightly "sink" (shadow reduction) rather than lift, providing a tactile, physical response.

## Shapes
Shapes are defined by generous, organic curves that reflect the approachable nature of the brand.

- **Standard Components:** Buttons and input fields use a **16px** (1rem) radius.
- **Large Containers:** Dashboard cards and bottom sheets use a **24px** (1.5rem) radius.
- **Micro-components:** Tags and chips use a pill-shape (full rounding) to contrast against the structured cards.

## Components

### Buttons
- **Primary:** Deep Petrol fill, white text. 16px radius. High-emphasis.
- **Secondary:** Muted Gold fill or Petrol outline. Used for secondary actions like "Add Note."
- **Ghost:** No background, Petrol text. Used for "Cancel" or "View All."
- **Danger:** Soft Red background (#FEECEC) with Error Red text.

### Input Fields
- **Default:** Soft Grey (#F2F2F2) background, no border. Text starts 16px from the left.
- **Focused:** 1.5px border in Primary Petrol.
- **Validation:** Error state uses a Soft Red border and helper text. Success uses a Sage Green checkmark icon.

### Cards
- Dashboard cards must have a 24px corner radius. They should include a subtle internal padding of 20px. Use Title-MD for card headers.

### Bottom Navigation
- A "floating" style navigation bar with a 32px radius. It should have a backdrop blur (Glassmorphism) effect: 20px blur, 80% opacity White. Icons should be 2px thin-line style.

### Skeleton Loaders
- Pulse animation should transition between Soft Grey (#F2F2F2) and a slightly darker Ivory (#EBEBEB). The pulse should be slow (2s duration) to maintain a "calm" atmosphere.

### Iconography
- Use 24px bounding boxes. Line weight should be fixed at 1.5pt or 2pt. Avoid filled icons unless it is an "active" state in the navigation bar.