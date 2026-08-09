# Vision & Privacy

## On-device Vision — how it works

```
Photo (import or camera)
  → VisionService.classify(image: UIImage)
    → VNClassifyImageRequest (on device, no network)
    → confidence > 0.15, top 8, mapped to PackWise categories
  → suggestions: [VisionSuggestion(label, confidence, category)]
  → YOU confirm — then PackingItem is created
  → never silently modifies data
```

`VisionService` (`Services/VisionService.swift`) is `@MainActor ObservableObject` with `isProcessing`, `suggestions`, `error`. `category(for:)` maps Vision labels to Clothing/Electronics/Toiletries/Documents/Medical/Accessories/Outdoor/General conservatively.

- Top `filtered { confidence > 0.15 }`, `prefix(8)`
- If empty → single “Unrecognized — add manually” suggestion
- Display: `label.replacingOccurrences(of: ",", with: " ·").capitalized`, `displayConfidence: "%.0f%%"`

Consumed by `CameraScannerView` — live `AVCaptureSession` capture → `SubjectExtractor` (foreground instance mask) → suggestions → choose trip → add. Photo-library import remains available in `LibraryView`.

## Privacy

- No cloud image processing. No external AI API. No data collection.
- All data in SwiftData on device. `Trip`, `PackingItem`, `PersonalItem`, `Outfit`, `Reminder`, `UserPreference`, `PackTemplate` — offline, backup-safe.
- Notifications are local `UserNotifications` only.
- No mandatory login, no paid services, no tracking. See [Build & Release](Build-and-Release) for self-hosting.

## Permissions

`Info.plist` declares `NSCameraUsageDescription` + `NSPhotoLibraryUsageDescription`. The app works without granting them — scanner just won’t have images.
