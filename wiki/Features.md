# Features — everything inside the IPA

All features run **on device**, **offline**, with **no cloud**. The website is docs — the IPA is the app.

## Trips

Create, edit, delete. Fields: title, destination, dates, purpose, activities, `climateInfo`, category (`Work`, `Beach`, `Outdoor`, `International`, custom), status (`planning`/`packing`/`ready`/`archived`), notes. History, duplicate, apply template.

## Smart packing lists

Per trip. Categories: Clothing, Electronics, Toiletries, Documents, Medical, Accessories, Outdoor + custom `PackCategory`. Each `PackingItem`: name, category, quantity, `packed`/`essential`, notes, photo, `isFavorite`, linked `PersonalItem`. Progress (`packed/total`), missing count, essentials missing, search / sort / filter. 5 starters: Weekend City, Business, Beach, Hiking, International + custom create/edit/duplicate via `PackTemplate` (`itemsJSON`).

## Personal item library

`PersonalItem` — name, category, notes, photo, `isFavorite`, reused across trips (linked via `personalItemID`).

## Scanner (live camera + background removal)

`CameraScannerView` — a real camera workflow, not a picker-only screen: `AVCaptureSession` live preview, capture button, flip camera, permission + unauthorized states, and a photo-library import fallback (`PhotosPicker`). Each capture runs two on-device passes in parallel:

- `SubjectExtractor` — `VNGenerateForegroundInstanceMaskRequest` removes the background and produces a transparent cutout (persisted as PNG). Graceful degradation: when Vision finds no subject it keeps the original photo with a clear message.
- `VisionService` — `VNClassifyImageRequest` maps labels to PackWise categories and shows confidence.

Flow: capture/import → background removal + suggestions → **you confirm** name/trip → add to list. Never silently modifies data. No cloud image processing.

## Weather-aware packing

- `DestinationSearchService` — `MKLocalSearchCompleter` autocomplete in the New Trip sheet resolves a chosen place to a coordinate (no manual lat/lon).
- `WeatherProvider` — `WeatherKit` fetches live conditions + daily forecast for the trip window and shows them in the trip header.
- `RecommendationService.suggestions(for:weather:)` — deterministic rules (precipitation ≥ 50% → umbrella + rain shell; lows < 5°C → warm layers + gloves; heat → sun protection) merged with the text engine. **Weather is an enhancement, never a blocker**: unsigned sideload builds lack the WeatherKit entitlement, so every fetch can fail — callers silently fall back to the offline text engine. No account or network required for the core app.

## Outfit Planner

`Outfit` — name, `dayLabel`, `itemIDs`, note, linked `Trip`. Compose from packed items, assign to trip days, preview, reuse.

## Dashboard

Upcoming trips, packing progress, missing essentials, recent activity, quick actions — all local. See `DashboardView`.

## Search

`GlobalSearchView` — trips, items, categories, outfits, templates — offline, `searchable`, filtering, sorting, favorites.

## Reminders

`Reminder` + `NotificationService` — `UserNotifications` local. Packing + trip prep reminders, custom scheduling, `requestAuthorization` + `schedule` + `cancel`.

## Templates

`PackTemplate` / `TemplateItem` — Weekend, Business, Beach, Hiking, International + custom. Create, edit, duplicate, apply to any trip.

## UI

Launch → Onboarding → Dashboard → Trips → Trip Detail → Packing List → Item Detail → Scanner → Outfit → Library → Search → Templates → Reminders → Settings. Light/Dark, Dynamic Type, VoiceOver, iPhone + iPad. Empty/loading/error states, haptics.
