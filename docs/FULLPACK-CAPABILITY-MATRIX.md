# FullPack — Capability Matrix

> Maps every **observable** FullPack capability to the PackWise implementation, the
> Apple technology it uses, and its honest status. This file is the living contract
> between product research and repository engineering.
>
> **Status legend:** `DISCOVERED` = identified from evidence · `DESIGNED` = mapped to an
> Apple API and a PackWise design · `IMPLEMENTED` = source exists in the repo ·
> `TESTED` = covered by unit/UI tests · `CI-VALIDATED` = proven by a macOS/Xcode run ·
> `COMPLETE` = fully verified end-to-end · `BLOCKED` = requires something unavailable.
>
> **Evidence sources:** App Store listing of *Fullpack — Packing & Outfit*
> (id6745692929, Signer Labs) for the product surface; official Apple Developer
> documentation for every API. A capability is **not** COMPLETE merely because source
> code exists.

---

## 1. Product reference

| Field | Value |
|---|---|
| App | Fullpack — Packing & Outfit |
| App Store ID | `6745692929` |
| Developer | Signer Labs |
| Publicly described flow | photograph an item → automatic background removal → AI item naming/category → inventory → trips (dates/destinations) → weather-aware packing → packing lists → outfit planning |

**Not copied:** FullPack's proprietary code, models, backend, or credentials. PackWise
reproduces the *observable functionality* with independent implementation and public
Apple APIs.

---

## 2. Capability matrix

### 2.1 Scanner / camera

| FullPack capability | Evidence | Atomic behavior | Apple API | Min iOS | PackWise implementation | Files | Status |
|---|---|---|---|---|---|---|---|
| Photograph an item with the live camera | App Store listing ("photographing an item") | Permission → live preview → shutter → capture | `AVCaptureSession`, `AVCaptureDeviceInput`, `AVCapturePhotoOutput`, `AVCaptureDevice.requestAccess(for:)` | 17 (target) | `CameraService` (session lifecycle, auth, capture) + `CameraScannerView` (preview, shutter, retake) | `Services/CameraService.swift`, `Views/CameraScannerView.swift`, `Views/CameraPreview.swift` | IMPLEMENTED (CI gate pending) |
| Import a photo instead of capturing | Screenshot/flow evidence | PhotosPicker → image | `PhotosUI.PhotosPicker` | 14 | Fallback path inside `CameraScannerView` | `Views/CameraScannerView.swift` | IMPLEMENTED |
| Automatic background removal / subject extraction | App Store listing ("removes the background") | Vision instance mask → transparent cutout | `VNGenerateForegroundInstanceMaskRequest`, `VNInstanceMaskObservation`, `VNImageRequestHandler` | 17 | `SubjectExtractor` renders all-instance mask to an isolated PNG + thumbnail | `Services/SubjectExtractor.swift` | IMPLEMENTED (CI gate pending) |
| Camera permission + graceful denial | Product norm | auth status → UI | `AVCaptureDevice.authorizationStatus`, `requestAccess` | 17 (async variant) | Unauthorized state offers Settings deep-link | `Views/CameraScannerView.swift` | IMPLEMENTED |
| Capture review / retake | Flow evidence | confirm or retake | SwiftUI | — | Capture-review stage with Retake/Discard | `Views/CameraScannerView.swift` | IMPLEMENTED |

### 2.2 Recognition & categorization

| FullPack capability | Evidence | Atomic behavior | Apple API | Min iOS | PackWise implementation | Files | Status |
|---|---|---|---|---|---|---|---|
| On-device item recognition | "AI item naming/category assignment" | classify → suggestions | `VNClassifyImageRequest` (existing, verified in repo) | 13 | `VisionService` label→category map (conservative, confirm-before-add) | `Services/VisionService.swift` | TESTED/CI-VALIDATED (existing) |
| Natural-language naming via Apple Intelligence | Listing wording ("AI ... naming") | local LLM names/categorizes | `FoundationModels.LanguageModelSession` / `@Generable` | **26** (Apple Intelligence) | **DESIGNED — deferred.** Deployment target is iOS 17; capability-check + fallback to `VisionService` specified in `docs/APPLE-API-CAPABILITY-BIBLE.md`. No speculative symbol use. | — | DESIGNED (BLOCKED until iOS 26 target decision) |
| Manual naming/category correction | Product norm | editable fields | SwiftUI | — | Name field + category picker in add flow | `Views/CameraScannerView.swift`, `Views/TripDetailView.swift` | IMPLEMENTED |

### 2.3 Inventory

| FullPack capability | Evidence | Atomic behavior | Apple API | Min iOS | PackWise implementation | Files | Status |
|---|---|---|---|---|---|---|---|
| Digital inventory of belongings | Listing ("builds a digital inventory") | library CRUD, photos, favorites | SwiftData | 17 | `PersonalItem` library with photos/notes/favorites, reuse across trips | `Models/Models.swift`, `Views/LibraryView.swift` | TESTED (persistence) |
| Isolated-image presentation | Screenshot evidence | cutout shown, original kept | SwiftData + PNG data | — | Scanner stores isolated PNG (thumbnail + full cutout) | `Services/SubjectExtractor.swift`, `Models/Models.swift` | IMPLEMENTED |
| Category counts / filtering / sorting | Listing ("assigns ... category") | category filter, search | SwiftData `#Predicate` / in-memory filter | — | Segmented category filter + search in `LibraryView` | `Views/LibraryView.swift` | TESTED (indirect) |
| Item detail with photo editing | Product norm | edit/change/remove photo | SwiftUI + PhotosUI | — | `PersonalItemDetail` in `LibraryView.swift` | same | IMPLEMENTED |

### 2.4 Trips & destinations

| FullPack capability | Evidence | Atomic behavior | Apple API | Min iOS | PackWise implementation | Files | Status |
|---|---|---|---|---|---|---|---|
| Trips with name/dates/destination | Listing ("trips with dates/destinations") | CRUD, status, duplicate | SwiftData | 17 | `Trip` model, `TripListView`, `NewTripSheet` | `Models/Models.swift`, `Views/TripListView.swift`, `Views/NewTripSheet.swift` | TESTED |
| Destination search / place autocomplete | "destinations" | type-ahead place results | `MKLocalSearchCompleter`, `MKLocalSearch`, `MKMapItem` | 9.3 / 13 | `DestinationSearchService` + suggestions list in `NewTripSheet`; coordinate persisted on `Trip` | `Services/DestinationSearchService.swift`, `Views/NewTripSheet.swift` | IMPLEMENTED (CI gate pending) |
| Geocoding fallback for free-text destinations | Product norm | text → coordinate | `CLGeocoder` (iOS 5) | 5 | `DestinationSearchService.geocode(destination:)` — resolves free-text on trip creation when no completer suggestion was picked | `Services/DestinationSearchService.swift` | IMPLEMENTED |
| Destination coordinate on trip | Needed by weather | lat/lon persisted | SwiftData optional doubles | — | `Trip.destinationLatitude/Longitude` | `Models/Models.swift` | IMPLEMENTED |

### 2.5 Weather-aware packing

| FullPack capability | Evidence | Atomic behavior | Apple API | Min iOS | PackWise implementation | Files | Status |
|---|---|---|---|---|---|---|---|
| Weather-aware packing suggestions | App Store listing ("weather-aware packing suggestions") | fetch forecast → deterministic suggestions | `WeatherKit.WeatherService.shared.weather(for:)`, `Weather.currentWeather`, `Weather.dailyForecast` | 16 | `WeatherProvider` (graceful nil on entitlement/network failure) + weather rules in `RecommendationService` | `Services/WeatherProvider.swift`, `Services/RecommendationService.swift` | IMPLEMENTED (CI/device gate: entitlement) |
| Deterministic fallback without weather | "weather-aware" must degrade | rule-based from trip fields | — | — | Existing text-keyword engine runs when weather is nil | `Services/RecommendationService.swift` | TESTED |
| Trip-range forecast aggregation | Design requirement | daily highs/lows/precip over trip dates | `Forecast<DayWeather>` | 16 | `WeatherSnapshot.dailyForecast` surfaced in `TripDetailView` header | `Services/WeatherProvider.swift`, `Views/TripDetailView.swift` | IMPLEMENTED |

### 2.6 Packing lists

| FullPack capability | Evidence | Atomic behavior | Apple API | Min iOS | PackWise implementation | Files | Status |
|---|---|---|---|---|---|---|---|
| Packing lists per trip | Listing ("creates packing lists") | items, quantity, packed state, progress | SwiftData | 17 | `PackingItem`, `TripDetailView` items tab, progress bars | `Models/Models.swift`, `Views/TripDetailView.swift` | TESTED (progress, persistence) |
| Packed/unpacked + quantities | Product norm | toggle + stepper | SwiftUI | — | swipe-to-toggle, stepper, filters | `Views/TripDetailView.swift` | TESTED (UI) |
| Templates | Listing/norm | one-tap apply | SwiftData | — | `PackTemplate` + 5 starter templates | `Models/Models.swift`, `Views/TemplateLibraryView.swift` | TESTED (roundtrip) |

### 2.7 Outfits

| FullPack capability | Evidence | Atomic behavior | Apple API | Min iOS | PackWise implementation | Files | Status |
|---|---|---|---|---|---|---|---|
| Outfit planning | Listing ("outfit planning") | compose from items, day labels | SwiftData + SwiftUI | 17 | `Outfit` model + outfits tab in `TripDetailView` | `Models/Models.swift`, `Views/TripDetailView.swift` | TESTED (indirect) |
| Outfit recommendation engine | Design objective | deterministic color/category/weather combos | pure Swift | — | `RecommendationService.outfitSuggestions(for:weather:)` with weather-aware, trip-context, and packed-item filtering | `Services/RecommendationService.swift` | IMPLEMENTED (CI gate pending) |

### 2.8 System integrations (modernization layer)

| FullPack capability | Evidence | Atomic behavior | Apple API | Min iOS | PackWise implementation | Files | Status |
|---|---|---|---|---|---|---|---|
| Siri/Shortcuts actions | Modern native norm | add item, mark packed, create trip | `AppIntents.AppIntent`, `AppEntity` | 16 | **IMPLEMENTED** — `AddInventoryItemIntent`, `MarkPackedIntent`, `CreateTripIntent` + `PackWiseShortcuts` provider; App Group container ensures intents see the same SwiftData store | `AppIntents/PackWiseIntents.swift` | IMPLEMENTED (CI gate pending) |
| Widgets (next trip, progress) | Modern native norm | interactive widget | `WidgetKit.StaticConfiguration` | 17 | **IMPLEMENTED** — `NextTripWidget` (systemSmall/systemMedium) + `PackingProgressWidget` (systemMedium/systemLarge); App Group container for shared SwiftData | `Widgets/PackWiseWidgetBundle.swift`, `Widgets/NextTripWidget.swift`, `Widgets/PackingProgressWidget.swift` | IMPLEMENTED (CI gate pending) |
| PackWise warm design system | Original product design | terracotta primary, serif headings, card/chip modifiers, spring animation tokens | SwiftUI | 18 | **IMPLEMENTED** — `DesignSystem/DesignTokens.swift` (240+ lines) with full color palette, typography scale, spacing system, animation tokens, reusable view modifiers | `DesignSystem/DesignTokens.swift` | IMPLEMENTED |
| Live Activities (departure) | Modern native norm | trip countdown | `ActivityKit` | 16.1 | **DESIGNED** | — | DESIGNED |
| Liquid Glass styling | iOS 26 design system | glass surfaces | `glassEffect(_:in:)`, `GlassEffectContainer` | **26** | **DESIGNED — deferred.** Requires iOS 26 SDK; PackWise targets iOS 18 | — | DESIGNED (BLOCKED until iOS 26 target) |

### 2.9 Privacy & architecture (PackWise invariants, not FullPack features)

| Claim | Evidence | PackWise status |
|---|---|---|
| No account / no cloud / offline-first | README, wiki, Info.plist (no tracking keys) | IMPLEMENTED — camera/photo usage strings present; no telemetry imports |
| On-device Vision | `VisionService` + `SubjectExtractor` use local Vision only | IMPLEMENTED |
| Local reminders | `UserNotifications` local only | TESTED |
| Weather is optional | `WeatherProvider` returns nil on any failure; UI degrades | IMPLEMENTED |

---

## 3. Explicit non-goals (evidence-backed)

| Item | Why excluded |
|---|---|
| Subscription / paywall | Directive §43: no artificial locks; core functionality free |
| Mandatory cloud AI | Local-first architecture; remote provider never the only path |
| iOS 26-only features as hard requirements | Deployment target is iOS 17 (repo-wide evidence: README, wiki, project.yml, publish gate); iOS 26 APIs are documented, gated designs |
| Private/undocumented APIs, `@_silgen_name`, unsafe casts | Directive §9 hard ban |

---

## 4. Status rollup

| Area | Status |
|---|---|
| Live camera capture | IMPLEMENTED — needs macOS CI + device validation |
| Background removal | IMPLEMENTED — needs macOS CI + device validation |
| Recognition/categorization | TESTED (existing VisionService) |
| Inventory | TESTED |
| Trips + destination search | IMPLEMENTED — needs macOS CI |
| Weather-aware packing | IMPLEMENTED — needs device/entitlement validation |
| Packing lists / templates / outfits | TESTED |
| Design system / iOS 18 migration / scanner polish | IMPLEMENTED (design system + iOS 18 + scanner UX) |
| App Intents / Widgets / Liquid Glass | IMPLEMENTED (Widgets + App Intents) / DESIGNED (Liquid Glass — iOS 26) |
| Privacy / offline-first | IMPLEMENTED |

> Next gate: the macOS CI run on the new Swift (camera, subject extraction, weather,
> destination search) is the authoritative acceptance test — see `docs/BUILD.md` and
> `docs/CI.md`.
