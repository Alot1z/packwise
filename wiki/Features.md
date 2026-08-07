# Features — everything inside the IPA

All features run **on device**, **offline**, with **no cloud**. The website is docs — the IPA is the app.

## Trips

Create, edit, delete. Fields: title, destination, dates, purpose, activities, `climateInfo`, category (`Work`, `Beach`, `Outdoor`, `International`, custom), status (`planning`/`packing`/`ready`/`archived`), notes. History, duplicate, apply template.

## Smart packing lists

Per trip. Categories: Clothing, Electronics, Toiletries, Documents, Medical, Accessories, Outdoor + custom `PackCategory`. Each `PackingItem`: name, category, quantity, `packed`/`essential`, notes, photo, `isFavorite`, linked `PersonalItem`. Progress (`packed/total`), missing count, essentials missing, search / sort / filter. 5 starters: Weekend City, Business, Beach, Hiking, International + custom create/edit/duplicate via `PackTemplate` (`itemsJSON`).

## Personal item library

`PersonalItem` — name, category, notes, photo, `isFavorite`, reused across trips (linked via `personalItemID`).

## Vision Scanner

`VisionService` — `VNClassifyImageRequest` on device. Flow: import/scan photo → classify → category-mapped suggestions → **you confirm** → add to list. Never silently modifies data. No cloud image processing.

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
