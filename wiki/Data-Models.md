# Data Models

All models are SwiftData `@Model`, stored locally, offline. Source: [`ios/PackWise/Models/Models.swift`](https://github.com/Alot1z/packwise/blob/main/ios/PackWise/Models/Models.swift)

## Trip

`id: UUID` (unique), `title`, `destination`, `startDate?`, `endDate?`, `purpose?`, `activities?`, `climateInfo?`, `notes?`, `tripCategory?`, `status: TripStatus` (`planning`/`packing`/`ready`/`archived`), `createdAt`, `updatedAt`, `items: [PackingItem]` (cascade), `outfits: [Outfit]` (cascade), `reminders: [Reminder]` (cascade). Computed: `progress: Double`, `missingCount`, `essentialsMissing`.

## PackingItem

`id`, `name`, `category` (default `General`), `quantity`, `packed: Bool`, `essential: Bool`, `notes?`, `photoData: Data?`, `isFavorite: Bool`, `createdAt`, `trip: Trip?`, `personalItemID: UUID?`.

## PersonalItem

Library, reusable. `id`, `name`, `category`, `notes?`, `photoData?`, `isFavorite`, `createdAt`.

## Outfit

`id`, `name`, `dayLabel?`, `itemIDs: [UUID]`, `note?`, `createdAt`, `trip: Trip?`.

## PackCategory

`id`, `name`, `icon`, `isBuiltIn: Bool`, `sortOrder`. Built-ins: Clothing, Electronics, Toiletries, Documents, Medical, Accessories, Outdoor, General (`defaultCategories`, `builtInCategoryNames`).

## Reminder

`id`, `title`, `fireDate: Date`, `isEnabled`, `trip: Trip?`, `createdAt`.

## UserPreference

Single row. `id`, `hasCompletedOnboarding: Bool` (default `false`), `defaultTripCategory?`, `hapticsEnabled: Bool` (`true`), `accentName: String` (`PackWiseAccent`).

## PackTemplate + TemplateItem

`PackTemplate`: `id`, `name`, `tag?`, `detail?`, `itemsJSON: Data` (JSON-encoded `[TemplateItem]`), `createdAt`, `decodedItems: [TemplateItem]`. `TemplateItem`: `id: UUID`, `name`, `category`, `quantity`, `essential: Bool`.

Starters (`starterTemplates`): Weekend City · 2 Nights (Weekend), Business · Three Days (Work), Beach Vacation (Beach), Hiking Trip (Outdoor), International Travel (International).

## Constants

`defaultCategories: [(name, icon)]`, `builtInCategoryNames: [String]`, `starterTemplates: [(name, tag, detail, items)]`.

## Privacy

All data stays on device. No CloudKit required for core use. Photos are `Data` in SwiftData.
