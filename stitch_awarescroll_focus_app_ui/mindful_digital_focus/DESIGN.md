---
name: Mindful Digital Focus
colors:
  surface: '#fcf8ff'
  surface-dim: '#d8d7f6'
  surface-bright: '#fcf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f2ff'
  surface-container: '#eeecff'
  surface-container-high: '#e7e6ff'
  surface-container-highest: '#e1e0ff'
  on-surface: '#181930'
  on-surface-variant: '#444656'
  inverse-surface: '#2d2e46'
  inverse-on-surface: '#f1efff'
  outline: '#747688'
  outline-variant: '#c4c5d9'
  surface-tint: '#2348ef'
  primary: '#123de7'
  on-primary: '#ffffff'
  primary-container: '#3a5bff'
  on-primary-container: '#f2f1ff'
  inverse-primary: '#bac3ff'
  secondary: '#006b55'
  on-secondary: '#ffffff'
  secondary-container: '#6dfad2'
  on-secondary-container: '#00725b'
  tertiary: '#824700'
  on-tertiary: '#ffffff'
  tertiary-container: '#a65b00'
  on-tertiary-container: '#ffefe5'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dee0ff'
  primary-fixed-dim: '#bac3ff'
  on-primary-fixed: '#00105b'
  on-primary-fixed-variant: '#002fc9'
  secondary-fixed: '#6dfad2'
  secondary-fixed-dim: '#4bddb7'
  on-secondary-fixed: '#002018'
  on-secondary-fixed-variant: '#005140'
  tertiary-fixed: '#ffdcc2'
  tertiary-fixed-dim: '#ffb77a'
  on-tertiary-fixed: '#2e1500'
  on-tertiary-fixed-variant: '#6d3a00'
  background: '#fcf8ff'
  on-background: '#181930'
  surface-variant: '#e1e0ff'
typography:
  display-timer:
    fontFamily: IBM Plex Mono
    fontSize: 56px
    fontWeight: '600'
    lineHeight: 64px
    letterSpacing: -0.04em
  headline-h1:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-h2:
    fontFamily: Inter
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-h3:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-large:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-medium:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-mono:
    fontFamily: IBM Plex Mono
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
    letterSpacing: 0.02em
  caption-medium:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-mobile: 0.75rem
  margin: 1.25rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is crafted for mindful screen time management, intentional phone sessions, and focused productivity blocks. The personality balances empathetic calmness with clear behavioral accountability. Rather than feeling punitive or clinical, the interface provides a warm, supportive, and restorative space that encourages conscious agency over compulsive device habits.

The aesthetic merges contemporary mobile minimalism with tactile, ambient interactions and gentle expressive touches. Clean interfaces are paired with soft line motifs, playful focus state indicators, and smooth circular progress visualizations to create a non-judgmental environment that lowers cognitive load while elevating personal reflection.

## Colors

The palette relies on deliberate functional chromatic roles:
- **Primary (`#3A5BFF`, deep tone `#22348F`):** Drives primary activation, focus commitment states, and key navigational paths.
- **Secondary / Success (`#00B894`):** Signifies completed focus sessions, locked-in achievements, and constructive streaks.
- **Reflect / Tertiary Accent (`#FF9F43`):** Reserved for mindful interventions, breathing breathers, session pause states, and intuitive reflection prompts.
- **Destructive / Alert (`#E5484D`):** Applied exclusively to session abandonment and emergency overrides to discourage reflexive tapping.
- **Surfaces & Grounds:** Light mode relies on a crisp base (`#F7F8FC`) paired with elevated containers (`#FFFFFF`) and hairline structure (`#E2E4F0`). Dark mode shifts smoothly to an immersive nighttime canvas (`#0E1021`) with supportive surface planes (`#171A2E`).
- **Typography hierarchy:** Main text renders in high-contrast neutral (`#14152B`), supported by secondary guidance shades (`#6B6F8C`).

## Typography

Typography establishes an immediate functional divide:
- **Inter** handles all narrative, administrative, and actionable interface copy. Strict tracking adjustments maintain crisp readability across varying mobile viewports.
- **IBM Plex Mono** is strictly reserved for quantitative metrics: active countdown countdowns, numeric session durations, elapsed percentages, and tabular analytics. Its fixed-pitch structure avoids rhythmic layout shifts during live active count increments.

## Layout & Spacing

The structural layout targets iOS form factors centered on standard 390px viewport baselines. 

- **Grid Model:** 4-column layout for phone displays with an outer gutter of 16px and column spacing of 12px.
- **Rhythm:** An 8pt spatial baseline underpins vertical component stacks, card paddings, and bottom navigation offsets.
- **Viewport Safe Zones:** Bottom CTAs float above navigation safe areas with 16px vertical clearances. Interactive touch targets hold a minimum hit-box boundary of 48px to prevent accidental taps during active sessions.

## Elevation & Depth

Visual hierarchy uses subtle surface offsets and directional ambient lighting rather than heavy drop shadows:

- **Level 0 (Canvas Base):** Flat, un-elevated page grounding (`#F7F8FC` in light mode; `#0E1021` in dark mode).
- **Level 1 (Card & Module Layer):** Elevated container `#FFFFFF` with a 1px solid stroke (`#E2E4F0`) and an ambient shadow: `0 4px 16px -2px rgba(20, 21, 43, 0.04), 0 2px 6px -1px rgba(20, 21, 43, 0.02)`.
- **Level 2 (Active Overlays & Floating Timer Controls):** Raised sheets and floating modal indicators with `0 12px 32px -4px rgba(20, 21, 43, 0.08), 0 4px 12px -2px rgba(20, 21, 43, 0.04)` combined with subtle 1px matching borders.
- **Active Lock Glow:** Focused state surfaces introduce a colored ambient halo around circular dials utilizing soft 20% opacity primary or accent color spreads.

## Shapes

The geometric signature uses generous curved borders to promote comfort and reduce cognitive tension:

- **Cards & Content Blocks:** Built with a uniform 16px border radius (`rounded-lg`), creating friendly, organic containers.
- **Action Buttons & Inputs:** Default interactive components feature a 12px corner radius.
- **Pill Elements:** Reflection toggles, streak indicators, mindful prompt chips, and quick tags strictly leverage fully rounded pill geometry (`rounded-full` / 9999px).
- **Circular Visualizers:** Timer indicators, circular track dials, and app icon shields maintain absolute circular ratios (1:1).

## Components

### Buttons
- **Primary Focus Button:** Height of 48px, 12px corner radius, `#3A5BFF` fill with white text (Inter SemiBold 16px). Active tap state scales to `0.98` with `#22348F`.
- **Reflection / Breathing Button:** Height of 24px, pill-shaped geometry, filled with 15% opacity `#FF9F43` background and solid `#FF9F43` text (Inter Medium 12px).
- **Secondary Ghost Button:** Height of 48px, 12px radius, transparent fill, 1px `#E2E4F0` border, `#14152B` text.

### Circular Focus Timer & Progress Dial
- Centerpiece interactive element configured within a 280px × 280px container.
- Uses a background SVG track of 10px stroke width (`#E2E4F0`), covered by an active animated stroke (`#3A5BFF` for focus sessions, `#FF9F43` during mindfulness reflection) with rounded stroke-ends.
- Inner dial houses the tabular display timer in `IBM Plex Mono` (56px) and an accompanying contextual label in Inter (14px).

### Cards
- Standard surface containers wrapped with a 16px radius, filled with `#FFFFFF` (or `#171A2E` in dark mode), bounded by a 1px solid `#E2E4F0` stroke and ambient Level 1 elevation.
- Internal card padding is strictly 16px or 20px.

### Mindful Reflection Chips & Tags
- Height of 32px, pill-shaped, used for session categorization (e.g., "Deep Work", "Mindful Pause", "Reading").
- Selected state: `#3A5BFF` with white text; Unselected state: `#F7F8FC` surface with `#6B6F8C` text and 1px stroke.

### Input Fields
- Height of 48px with 12px border radius, styled with a `#FFFFFF` surface, 1px `#E2E4F0` border, and 16px horizontal padding.
- Focused state transitions border color to `#3A5BFF` with a 2px outer outline at 20% opacity.

### Lock-In Toggle & Checkboxes
- 24px switches with smooth 200ms spring animations transitioning from `#E2E4F0` to `#00B894` upon arming a FocusLock block.