# PackWise — Architecture

> Current architecture plus the FullPack-reconstruction target architecture. Everything
> in this file corresponds to code that exists in the repository or is explicitly
> marked DESIGNED.

## 1. Stack (verified)

- **Language:** Swift 5.9 language mode (`SWIFT_VERSION 5.9`), compiled by the CI
  runner's Xcode (macOS 15 image; the runner selects the newest installed Xcode).
- **UI:** SwiftUI (iOS 17 deployment target — iPhone + iPad, `TARGETED_DEVICE_FAMILY 1,2`).
- **Persistence:** SwiftData (`@Model`, `ModelContainer`, `ModelContext`) — offline-first.
- **Vision:** `VNClassifyImageRequest` (verified) + `VNGenerateForegroundInstanceMaskRequest`
  (new — subject extraction).
- **Photos:** `PhotosUI.PhotosPicker` (verified).
- **Camera:** AVFoundation `AVCaptureSession` (new).
- **Weather:** WeatherKit (new, optional, graceful fallback).
- **Maps:** MapKit `MKLocalSearchCompleter`/`MKLocalSearch` (new, destination search).
- **Notifications:** UserNotifications (verified).
- **Project generation:** XcodeGen (`ios/project.yml` is the source of truth; the
  generated `.xcodeproj` is never hand-edited).
- **Build/release:** `ios/build.sh` (self-healing unsigned-IPA cascade) + 
  `scripts/verify-ipa.sh` strict gate + `scripts/release-manifest.sh`.

## 2. Directory layout

```
ios/
  PackWise/
    App/            PackWiseApp.swift · ContentView.swift (tab root)
    Models/         Models.swift (Trip, PackingItem, PersonalItem, Outfit, PackCategory, Reminder, UserPreference, PackTemplate)
    Services/       VisionService · SubjectExtractor · CameraService · WeatherProvider · DestinationSearchService · RecommendationService · NotificationService
    Views/          Dashboard · Trips · TripDetail · ItemDetail · CameraScanner · Library · Search · Templates · Reminders · Settings · Onboarding · NewTripSheet
    Resources/      Assets.xcassets · Info.plist
  PackWiseTests/    Swift Testing suite (models & persistence)
  PackWiseUITests/  XCTest UI suite (tabs, trip flow, VoiceOver)
  project.yml       XcodeGen spec — authoritative
  build.sh          IPA pipeline
```

## 3. Data model (SwiftData)

| Model | Key fields | Relationships |
|---|---|---|
| `Trip` | title, destination, `destinationLatitude`/`destinationLongitude` (new), startDate, endDate, purpose, activities, climateInfo, status, createdAt/updatedAt | items (cascade), outfits (cascade), reminders (cascade) |
| `PackingItem` | name, category, quantity, packed, essential, notes, photoData, isFavorite, `personalItemID` | trip |
| `PersonalItem` | name, category, notes, photoData, isFavorite | — (library) |
| `Outfit` | name, dayLabel, itemIDs `[UUID]`, note | trip |
| `Reminder` | title, fireDate, isEnabled | trip |
| `UserPreference` | hasCompletedOnboarding, hapticsEnabled, accentName | singleton row |
| `PackTemplate` | name, tag, detail, itemsJSON | — |

All new fields are additive optionals → SwiftData lightweight migration, no schema break.

## 4. Services

| Service | Responsibility | New/Existing |
|---|---|---|
| `VisionService` | `VNClassifyImageRequest` → category-mapped suggestions, confirm-before-add | Existing (verified) |
| `SubjectExtractor` | `VNGenerateForegroundInstanceMaskRequest` → isolated cutout + thumbnail | **New** |
| `CameraService` | AVCaptureSession lifecycle, auth, still capture | **New** |
| `WeatherProvider` | `WeatherService.shared.weather(for:)` → `WeatherSnapshot`; **nil on any failure** | **New** |
| `DestinationSearchService` | `MKLocalSearchCompleter` autocomplete + `MKLocalSearch` coordinate resolution | **New** |
| `RecommendationService` | deterministic text-based + weather-based suggestions; pure functions, testable | Existing + extended |
| `NotificationService` | local `UNUserNotificationCenter` reminders | Existing |

## 5. User flows (FullPack-aligned)

```
CameraScanner (live preview → shutter/import)
   → SubjectExtractor (background removed, isolated PNG + thumbnail)
   → VisionService (on-device suggestions, confirm-before-add)
   → pick trip → PackingItem persisted
NewTripSheet (destination autocomplete → coordinate on Trip)
   → TripDetailView (weather-aware suggestions when weather available, text-based always)
```

## 6. Availability strategy

- Deployment target stays **iOS 17.0** (repo-wide evidence: README, wiki, project.yml,
  publish gate, verifier). All implemented features use iOS-17-compatible APIs.
- iOS 26+ capabilities (Foundation Models naming, Liquid Glass) are **DESIGNED** with
  explicit `@available` gating and documented capability checks — never referenced at
  the iOS 17 target (searchActions lesson, see `docs/APPLE-API-CAPABILITY-BIBLE.md`).
- WeatherKit requires an entitlement; PackWise ships unsigned → weather degrades to
  the deterministic text engine. Designed, not a defect.

## 7. Privacy invariants

No account · no cloud · no telemetry · on-device Vision · local SwiftData · local
notifications · camera/photo usage strings in `Info.plist` (present, no tracking keys).
