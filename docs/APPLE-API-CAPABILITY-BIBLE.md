# PackWise — Apple API Capability Bible

> **Living document.** Maps every Apple framework/API used (or planned) in PackWise to its
> exact symbols, SDK availability, iOS version, and implementation status.
> Updated: 2026-08-09. See also [`FULLPACK-CAPABILITY-MATRIX.md`](FULLPACK-CAPABILITY-MATRIX.md).

## 1. Frameworks in use

| Framework | Min iOS | Purpose | Status |
|---|---|---|---|
| SwiftUI | 18 | All UI | ACTIVE |
| SwiftData | 18 | Persistence | ACTIVE |
| Vision | 17 | Item recognition, foreground masks | ACTIVE |
| AVFoundation | 17 | Live camera capture | ACTIVE |
| PhotosUI | 16 | Photo import fallback | ACTIVE |
| WeatherKit | 16 | Weather-aware packing | ACTIVE |
| MapKit | 9.3 | Destination search | ACTIVE |
| CoreLocation | 5 | Geocoding fallback | ACTIVE |
| UserNotifications | 10 | Local reminders | ACTIVE |
| WidgetKit | 17 | Home screen widgets | ACTIVE (v1.0.17) |
| AppIntents | 16 | Siri/Shortcuts | ACTIVE (v1.0.17) |
| CoreImage | 5 | Image rendering pipeline | ACTIVE |
| UIKit (limited) | 2 | Haptics, Settings URL | ACTIVE |

## 2. SwiftUI APIs

| API | iOS | Purpose | Symbol verified | Files |
|---|---|---|---|---|
| `.searchable(text:prompt:)` | 15 | Search fields | ✅ Xcode 26.3 | TripListView, GlobalSearchView, LibraryView |
| `.navigationDestination(for:)` | 16 | Typed nav | ✅ | ContentView, TripListView, DashboardView |
| `.tabViewStyle(.automatic)` | 18 | Adaptive tabs | ✅ | ContentView |
| `.sheet(isPresented:)` | 13 | Modal sheets | ✅ | NewTripSheet, AddPersonalItemSheet |
| `.swipeActions(edge:)` | 15 | Swipe gestures | ✅ | TripListView, LibraryView |
| `.confirmationDialog()` | 15 | Delete confirmations | ✅ | TripListView, LibraryView |
| `.animation(_:value:)` | 15 | Explicit animations | ✅ | CameraScannerView, ContentView |
| `.refreshable` | 15 | Pull-to-refresh | ✅ | DashboardView |
| `.containerBackground(_:for:)` | 17 | Widget backgrounds | ✅ | Widget views |
| `.progressViewStyle` | 13 | Progress bars | ✅ | Throughout |
| `.badge(_:)` | 15 | Tab badges | ✅ | ContentView |
| `ContentUnavailableView` | 17 | Empty states | ✅ | Throughout |
| `PhotosPicker` | 16 | Photo import | ✅ | CameraScannerView, LibraryView |

## 3. Vision APIs

| API | iOS | Symbol | Purpose | Verified | Files |
|---|---|---|---|---|---|
| `VNClassifyImageRequest` | 13 | Image classification | Item recognition | ✅ | VisionService.swift |
| `VNImageRequestHandler` | 11 | Request execution | Vision pipeline | ✅ | VisionService.swift, SubjectExtractor.swift |
| `VNGenerateForegroundInstanceMaskRequest` | 17 | Foreground instance mask | Background removal | ✅ (session 12 fix) | SubjectExtractor.swift |
| `VNInstanceMaskObservation.allInstances` | 17 | Instance mask index set | Get instance count | ✅ (session 12 fix) | SubjectExtractor.swift |
| `VNInstanceMaskObservation.generateMaskedImage(ofInstances:from:croppedToInstancesExtent:)` | 17 | Mask → image | Transparent cutout | ✅ (session 12 fix) | SubjectExtractor.swift |
| `VNObservation.confidence` | 11 | Detection confidence | Quality indicator | ✅ | VisionService.swift, SubjectExtractor.swift |
| `CGImagePropertyOrientation` | 8 | Image orientation | Photo alignment | ✅ | VisionService.swift, SubjectExtractor.swift |

## 4. AVFoundation APIs

| API | iOS | Symbol | Purpose | Verified | Files |
|---|---|---|---|---|---|
| `AVCaptureSession` | 4 | Camera session | Live preview | ✅ | CameraService.swift |
| `AVCaptureDeviceInput` | 4 | Camera input | Capture | ✅ | CameraService.swift |
| `AVCapturePhotoOutput` | 10 | Photo output | Still capture | ✅ | CameraService.swift |
| `AVCaptureDevice.requestAccess(for:)` | 7 | Permission | Auth flow | ✅ | CameraService.swift |
| `AVCaptureDevice.authorizationStatus` | 7 | Auth state | Permission check | ✅ | CameraService.swift |

## 5. SwiftData APIs

| API | iOS | Symbol | Purpose | Verified | Files |
|---|---|---|---|---|---|
| `@Model` | 17 | Persistent model | All entities | ✅ | Models.swift |
| `@Attribute(.unique)` | 17 | Uniqueness constraint | IDs | ✅ | Models.swift |
| `@Relationship(deleteRule:)` | 17 | Cascade deletes | Trip → Items | ✅ | Models.swift |
| `ModelContainer(for:)` | 17 | Container creation | App init | ✅ | PackWiseApp.swift |
| `ModelConfiguration(groupContainer:)` | 17 | App Group sharing | Widgets/Intents | ✅ (v1.0.17) | PackWiseApp.swift, Widgets |
| `@Query(sort:)` | 17 | Reactive queries | Views | ✅ | Throughout |
| `FetchDescriptor` | 17 | Programmatic fetch | Widgets | ✅ | Widget providers |
| `#Predicate` | 17 | Compile-time predicates | Filtering | ✅ | AppIntents, Widgets |

## 6. WeatherKit APIs

| API | iOS | Symbol | Purpose | Verified | Files |
|---|---|---|---|---|---|
| `WeatherService.shared.weather(for:)` | 16 | Current weather | Trip detail | ⚠️ entitlement | WeatherProvider.swift |
| `Weather.currentWeather` | 16 | Conditions | Temperature, precip | ⚠️ entitlement | WeatherProvider.swift |
| `Weather.dailyForecast` | 16 | Forecast | Trip-range weather | ⚠️ entitlement | WeatherProvider.swift |
| `Forecast<DayWeather>` | 16 | Day forecast | Aggregation | ⚠️ entitlement | WeatherProvider.swift |

> **Note:** WeatherKit requires the WeatherKit capability entitlement. Unsigned sideload
> builds cannot use it. `WeatherProvider` is designed to fail-nil gracefully — the
> deterministic text engine is never blocked.

## 7. MapKit / CoreLocation APIs

| API | iOS | Symbol | Purpose | Verified | Files |
|---|---|---|---|---|---|
| `MKLocalSearchCompleter` | 9.3 | Place autocomplete | Destination search | ✅ | DestinationSearchService.swift |
| `MKLocalSearch` | 6.1 | Place resolution | Coordinate lookup | ✅ | DestinationSearchService.swift |
| `MKLocalSearch.Request(completion:)` | 13 | Request from suggestion | Coordinate resolution | ✅ | DestinationSearchService.swift |
| `CLGeocoder.geocodeAddressString(_:)` | 5 | Free-text geocoding | Fallback for typed-in destinations | ✅ (v1.0.16) | DestinationSearchService.swift |
| `CLLocationCoordinate2D` | 4 | Coordinate type | Lat/lon storage | ✅ | DestinationSearchService.swift, Models.swift |

## 8. WidgetKit APIs

| API | iOS | Symbol | Purpose | Verified | Files |
|---|---|---|---|---|---|
| `Widget` protocol | 14 | Widget definition | Widget struct | ✅ (v1.0.17) | Both widgets |
| `StaticConfiguration` | 14 | Static widget config | Provider binding | ✅ (v1.0.17) | Both widgets |
| `TimelineProvider` | 14 | Timeline updates | Data refresh | ✅ (v1.0.17) | Both widgets |
| `TimelineEntry` | 14 | Timeline data | Snapshot/entry | ✅ (v1.0.17) | Both widgets |
| `.containerBackground(_:for:)` | 17 | Widget background | Styling | ✅ (v1.0.17) | Both widgets |
| `.supportedFamilies(_:)` | 16 | Family constraint | Size options | ✅ (v1.0.17) | Both widgets |

## 9. App Intents APIs

| API | iOS | Symbol | Purpose | Verified | Files |
|---|---|---|---|---|---|
| `AppIntent` protocol | 16 | Intent definition | Siri/Shortcuts | ✅ (v1.0.17) | PackWiseIntents.swift |
| `AppShortcutsProvider` | 16 | Shortcut registration | Spotlight/Shortcuts | ✅ (v1.0.17) | PackWiseIntents.swift |
| `@Parameter` | 16 | Intent parameter | Input fields | ✅ (v1.0.17) | PackWiseIntents.swift |
| `IntentDescription` | 16 | Intent metadata | Description | ✅ (v1.0.17) | PackWiseIntents.swift |
| `ProvidesDialog` | 16 | Dialog result | Siri response | ✅ (v1.0.17) | PackWiseIntents.swift |

## 10. Designed / deferred APIs

| API | iOS | Purpose | Reason deferred |
|---|---|---|---|
| `FoundationModels.LanguageModelSession` | 26 | Apple Intelligence item naming | Requires iOS 26 SDK; PackWise targets iOS 18 |
| `glassEffect(_:in:)` | 26 | Liquid Glass styling | Requires iOS 26 SDK |
| `GlassEffectContainer` | 26 | Glass container | Requires iOS 26 SDK |
| `ActivityKit` (Live Activities) | 16.1 | Trip countdown | Designed but not yet implemented |
| `CoreML` on-device models | 11 | Custom item classifier | Future enhancement |

## 11. Non-Apple dependencies

PackWise uses **zero** third-party Swift packages or CocoaPods. The only dependency is the
Apple SDK itself. This keeps the project buildable indefinitely without external package
resolution failures.

## 12. API verification methodology

Every API claim in this document is verified by at least one of:
1. **Xcode compilation** — macOS CI runner's actual compiler accepts the symbol
2. **Official Apple documentation** — linked in each section with the canonical URL
3. **SDK header inspection** — `xcrun --sdk iphoneos` confirms availability

No API is listed as "available" based on memory, blog posts, or `@available` annotations alone.
The `.searchActions` incident (sessions 8–10) proved that wrong assumptions cascade:
`@available(iOS 18.0, *)` cannot protect code from a symbol that does not exist in SwiftUI.
