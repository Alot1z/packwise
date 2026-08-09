# PackWise — UI/UX Design System

> **Living document.** Describes the PackWise visual identity, design tokens, and component
> system. Implementation lives in `ios/PackWise/DesignSystem/DesignTokens.swift`.

## 1. Design principles

| Principle | What it means |
|---|---|
| **Warm** | Amber/terracotta primary, cream backgrounds, golden accents. The app should feel like a well-loved leather travel bag, not a cold enterprise dashboard. |
| **Premium** | Controlled spacing, refined serif headings, subtle materials. Every pixel is intentional. |
| **Tactile** | Controls respond with spring animations and haptics. Cards have depth. Buttons feel pressable. |
| **Calm** | Restrained color palette (max 3 accent colors per screen). Clear hierarchy. No visual noise. |
| **Travel-oriented** | Design communicates clothing, preparation, discovery, organization, movement. The scanner is the centerpiece. |
| **Modern Apple** | Uses contemporary SwiftUI conventions (`.searchable`, `.navigationDestination`, materials). Progressive disclosure. |
| **Accessible** | Dynamic Type, VoiceOver labels, Reduce Motion gates, 4.5:1+ contrast. Never an afterthought. |

## 2. Color palette

### Light mode

```
Primary:     #EB7352  (terracotta, warm brand anchor)
Secondary:   #266B6B  (deep teal, calm travel-marine)
Accent:      #E6A633  (golden amber, highlights/progress)
Background:  #F7F5F0  (warm off-white, not sterile #FFF)
Surface:     #FDFCF7  (very slightly warm card)
Text:        #262220  (near-black with warmth)
Text sec:    #6B6059  (warm grey)
Success:     #389E59  (green)
Warning:     #B85C00  (brown-amber, WCAG AA)
Error:       #BD2E1E  (dark red)
```

### Dark mode

```
Background:  #1A1412  (warm near-black)
Surface:     #282320  (warm dark card)
Primary:     #F08060  (brighter terracotta)
Text:        #F0EDEA  (warm off-white)
```

## 3. Typography

- **Headings**: serif (`.serif` design), warm personality
- **Body**: default system, clean reading
- **Data**: monospaced digits for counts, percentages
- **No fixed font sizes** — all use semantic text styles or `@ScaledMetric`
- **Dynamic Type**: full range, no caps, no minimumScaleFactor

```
Title Large:  .serif, bold, 28pt
Title Medium: .serif, semibold, 22pt
Title Small:  .serif, medium, 20pt
Headline:     .default, semibold, 17pt
Body:         .default, regular, 17pt
Caption:      .default, regular, 12pt
Mono:         .monospaced, regular, 12pt
```

## 4. Spacing & layout

```
xs:  4pt   (icon padding, tight chips)
sm:  8pt   (inline gaps, badge padding)
md:  12pt  (cell padding, chip horizontal)
lg:  16pt  (card padding, section gaps)
xl:  24pt  (section margins)
xxl: 32pt  (hero spacing)
```

- Lists use `.insetGrouped` with warm background
- Cards use 12pt corner radius
- Sheet presentations use `.presentationDetents`

## 5. Component library

### Card (`packWiseCard`)
Off-white surface, 12pt radius, subtle shadow. Elevated variant for overlays.

### Chip (`packWiseChip`)
Compact capsule: category label, tag, status. Colored background at 18% opacity.

### Section Header (`packWiseSectionHeader`)
Serif title3, warm text color. Consistent spacing.

### Progress bar
Blue-to-green gradient, 6pt height, rounded. Shows packed/total.

### Scanner button
72pt outer ring (white stroke), 58pt inner fill. Spring animation on press.

## 6. Motion system

| Token | Use |
|---|---|
| `fast` | Toggle, checkbox, tap feedback (0.3s spring) |
| `standard` | Navigation, sheet present, card appear (0.4s spring) |
| `slow` | Onboarding, major transitions (0.5s spring) |
| `bouncy` | Scanner capture, success states (0.4s, low damping) |

- All animations gated on `@Environment(\.accessibilityReduceMotion)`
- Haptics accompany destructive confirmations and success states
- Scanner: capture → flash → subject isolate → card appear

## 7. Scanner UX flow

```
LIVE CAMERA (full screen, black background)
    │
    ├─ Camera permission check
    ├─ Live AVCaptureSession preview
    ├─ Framing guide (rounded rect, white 35% opacity)
    ├─ "Center the item, then capture" hint
    │
    ▼
CAPTURE (bouncy spring on shutter)
    │
    ├─ Flash overlay (white, 150ms fade)
    ├─ Photo appears in review card
    │
    ▼
PROCESSING (parallel, on device)
    │
    ├─ Vision classification (name + category suggestions)
    ├─ SubjectExtractor (background removal, transparent PNG)
    ├─ Progress indicators for both
    │
    ▼
REVIEW CARD
    │
    ├─ Isolated subject image (on transparent bg)
    ├─ Item name field (pre-filled from Vision)
    ├─ Category suggestions list (tap to select)
    ├─ Trip picker
    │
    ▼
CONFIRM → inventory insertion → success haptic → reset
```

## 8. Screen-by-screen design direction

### Dashboard
- Warm stat pills (terracotta tint, 12pt radius)
- Upcoming trips as cards with progress rings
- On-device recommendations in an amber-tinted section
- Missing essentials with warning icon
- Pull-to-refresh haptic

### Trip List
- Cards with destination, date range, progress
- Swipe actions with confirmation haptics
- Empty state: illustrated suitcase with warm text

### Trip Detail
- Tabs: Items / Outfits / Weather
- Items: grouped by category, swipe to toggle packed
- Progress bar at top (green when complete)
- Outfits: visual cards showing item thumbnails

### Scanner
- Full-screen black live camera
- White framing guide
- Shutter button: 72pt outer ring + 58pt fill
- Review: isolated subject on warm surface
- Suggestions as tappable chips

### Library
- Grid/List toggle
- Item cards with isolated thumbnails
- Category filter chips
- Warm empty state: "Your digital wardrobe"

### Search
- `.searchable` with scoped suggestions
- Recent items, trips, outfits
- Category and tag filtering

## 9. Accessibility checklist

- [x] Dynamic Type: all fonts semantic or @ScaledMetric
- [x] VoiceOver: labels on every interactive control
- [x] Reduce Motion: animation gates on every animation
- [x] Contrast: 4.5:1 minimum for text, state never color-only
- [x] Haptics: accompany confirmations and destructive actions
- [x] Large content: no minimumScaleFactor, no dynamicTypeSize caps
