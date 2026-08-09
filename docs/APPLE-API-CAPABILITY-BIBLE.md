# PackWise — Apple API Capability Bible

> The verified-capability ledger behind the FullPack reconstruction. **Only APIs that
> have been verified against Apple's current documentation (and, where noted, the
> repository's existing verified source) are listed.** No guessed symbols. Every symbol
> here is either already compiling in the repo or confirmed against Apple docs with its
> exact name and availability; the final word is always the actual SDK on the macOS
> runner (see the searchActions lesson at the bottom).

Legend: `✅ verified in repo (compiles)` · `📄 verified against Apple docs` ·
`⚠️ verify on runner SDK before committing` (availability/generic hazards).

---

## 1. Vision — subject segmentation & background removal

| Capability | Framework | Exact symbol | Min iOS | SDK/Xcode | Purpose | Alternatives | Selected implementation | PackWise file | Test |
|---|---|---|---|---|---|---|---|---|---|
| Foreground instance masks | Vision | `VNGenerateForegroundInstanceMaskRequest` | 17.0 | 15+ / 26.3 | Detect foreground instances (items) so they can be separated from the background | `GeneratePersonInstanceMaskRequest` (people only), CoreML custom models | All-instance mask request — items, not people | `Services/SubjectExtractor.swift` | CI/device |
| Instance mask observation | Vision | `VNInstanceMaskObservation` | 17.0 | 15+ / 26.3 | Result object: confidence, bounding box, instance masks | — | Read first observation, render all instances | `Services/SubjectExtractor.swift` | CI/device |
| Mask → image with transparent background | Vision | `observation.generateMaskedImage(ofInstances:croppedToInstancesExtent:)` | 17.0 | 15+ / 26.3 | Produce a cutout image (background removed) | Manual compositing via Core Image `CIBlendWithMask` | Direct API — simpler and safer than manual blending | `Services/SubjectExtractor.swift` | CI/device |
| Run a Vision request | Vision | `VNImageRequestHandler.perform(_:)` | 13.0 | — | Execute request on a CGImage | — | Already used by `VisionService` | `Services/SubjectExtractor.swift`, `Services/VisionService.swift` | ✅ repo |
| Classification (existing) | Vision | `VNClassifyImageRequest`, `VNClassificationObservation` | 13.0 | — | On-device item recognition | — | Existing label→category mapper | `Services/VisionService.swift` | ✅ repo |

**Pattern (subject extraction):**

```swift
let request = VNGenerateForegroundInstanceMaskRequest()
let handler = VNImageRequestHandler(cgImage: cg, orientation: orientation, options: [:])
try handler.perform([request])
guard let observation = request.results?.first else { return nil }
let isolatedBuffer = try observation.generateMaskedImage(
    ofInstances: IndexSet(integersIn: 0..<observation.instanceCount),
    croppedToInstancesExtent: false
)
// isolatedBuffer → CIImage → UIImage (transparent background)
```

## 2. VisionKit — interactive subject lifting

| Capability | Framework | Exact symbol | Min iOS | SDK/Xcode | Purpose | Alternatives | Selected | File | Test |
|---|---|---|---|---|---|---|---|---|---|
| Interactive subject extraction | VisionKit | `ImageAnalyzer`, `ImageAnalysisInteraction`, `ImageAnalysisInteraction.Subject` | 16.0 / 18 (subject APIs) | 15+ | System "lift subject" UI | `VNGenerateForegroundInstanceMaskRequest` | Not used — interactive overlay is overkill for a batch scanner; Vision mask is deterministic | — | — |
| Runtime support check | VisionKit | `ImageAnalyzer.isSupported` | 16.0 | — | Device capability gate | — | If ever used, gate on this | — | — |

## 3. PhotosUI — import

| Capability | Framework | Exact symbol | Min iOS | SDK/Xcode | Purpose | Alternatives | Selected | File | Test |
|---|---|---|---|---|---|---|---|---|---|
| Privacy-preserving photo picker | PhotosUI | `PhotosPicker`, `PhotosPickerItem`, `loadTransferable(type:)` | 14.0 | — | Import without full library permission | `PHPickerViewController` | SwiftUI `PhotosPicker` (already in repo) | `Views/CameraScannerView.swift` | ✅ repo |

## 4. AVFoundation — live camera

| Capability | Framework | Exact symbol | Min iOS | SDK/Xcode | Purpose | Alternatives | Selected | File | Test |
|---|---|---|---|---|---|---|---|---|---|
| Capture session | AVFoundation | `AVCaptureSession` | 4.0 | — | Live preview + capture | `AVCam` UIKit pattern | Standard session | `Services/CameraService.swift` | CI/device |
| Camera input | AVFoundation | `AVCaptureDeviceInput` | 4.0 | — | Wire camera device | — | — | same | CI/device |
| Photo output | AVFoundation | `AVCapturePhotoOutput`, `AVCapturePhoto`, `fileDataRepresentation()` | 10.0 | — | Still capture | `AVCaptureVideoDataOutput` (frame stream) | Still photo — matches product flow | same | CI/device |
| Preview layer | AVFoundation | `AVCaptureVideoPreviewLayer` | 4.0 | — | Live preview in SwiftUI via `UIViewRepresentable` | `PreviewView` with `layerClass` | — | `Views/CameraPreview.swift` | CI/device |
| Permission | AVFoundation | `AVCaptureDevice.requestAccess(for:)` (async) / `authorizationStatus(for:)` | 17 (async) | — | Camera auth | `AVCaptureDevice.requestAccess` (callback, iOS 7) | Async variant, iOS 17 target-safe | `Views/CameraScannerView.swift` | CI/device |

## 5. WeatherKit — weather-aware packing

| Capability | Framework | Exact symbol | Min iOS | SDK/Xcode | Purpose | Alternatives | Selected | File | Test |
|---|---|---|---|---|---|---|---|---|---|
| Weather service | WeatherKit | `WeatherService.shared.weather(for:)` | 16.0 | 14+ | Fetch conditions/forecast for destination | Open-Meteo (network), manual text (existing) | Native WeatherKit, graceful fallback | `Services/WeatherProvider.swift` | CI/device (entitlement) |
| Current conditions | WeatherKit | `Weather.currentWeather.temperature`, `.condition`, `.symbolName` | 16.0 | 14+ | Live temp/condition | — | — | same | CI/device |
| Daily forecast | WeatherKit | `Weather.dailyForecast`, `Forecast<DayWeather>`, `DayWeather.highTemperature/lowTemperature/precipitationChance` | 16.0 | 14+ | Trip-range forecast | — | — | same | CI/device |
| Location input | CoreLocation | `CLLocation`, `CLLocationCoordinate2D` | 2.0 | — | Coordinate for weather | — | — | same | ✅ repo (no) → CI |

> ⚠️ **Entitlement note:** WeatherKit requires the `com.apple.developer.weatherkit`
> entitlement in the signing identity. PackWise is unsigned/sideloaded → weather will
> fail gracefully (`WeatherProvider` returns `nil`) and the app keeps working with the
> deterministic text-based engine. That is the designed fallback, not a bug.

## 6. MapKit — destination search

| Capability | Framework | Exact symbol | Min iOS | SDK/Xcode | Purpose | Alternatives | Selected | File | Test |
|---|---|---|---|---|---|---|---|---|---|
| Place autocomplete | MapKit | `MKLocalSearchCompleter`, `MKLocalSearchCompletion`, `completerDidUpdateResults` | 9.3 | — | Type-ahead destination suggestions | Manual text (existing) | Native completer | `Services/DestinationSearchService.swift` | CI/device |
| Resolve place → coordinate | MapKit | `MKLocalSearch`, `MKLocalSearch.Request(completion:)`, `.start()`, `MKMapItem.placemark.coordinate` | 13.0 | — | Coordinate for a selected suggestion | `CLGeocoder` | `MKLocalSearch` | same | CI/device |
| Coordinate types | CoreLocation | `CLLocationCoordinate2D`, `CLLocationCoordinate2DIsValid` | 2.0 | — | Persist lat/lon on `Trip` | — | — | `Models/Models.swift` | ✅ repo |

## 7. SwiftData — persistence (existing, verified)

| Capability | Exact symbol | Min iOS | Purpose | File | Test |
|---|---|---|---|---|---|
| Models | `@Model` | 17 | All domain objects | `Models/Models.swift` | ✅ repo (6 tests) |
| Container | `ModelContainer`, `ModelConfiguration` | 17 | App/in-memory containers | `PackWiseApp.swift`, tests | ✅ repo |
| Context | `ModelContext` | 17 | CRUD | views | ✅ repo |
| Queries | `@Query`, `FetchDescriptor` | 17 | Lists/search | views | ✅ repo |
| Relationships | `@Relationship(deleteRule:)` | 17 | Trip→items/outfits/reminders | `Models/Models.swift` | ✅ repo |

## 8. Foundation Models — Apple Intelligence (documented, deferred)

| Capability | Framework | Exact symbol | Min iOS | SDK/Xcode | Purpose | Decision |
|---|---|---|---|---|---|---|
| Local LLM session | FoundationModels | `LanguageModelSession`, `LanguageModel`, `@Generable` | **26** (Apple Intelligence) | 26.x | Natural-language item naming/categorization | **DESIGNED, not implemented.** Deployment target is iOS 17; capability-check + fallback to `VisionService` specified below. Do not reference these symbols at iOS 17 target — compile risk (searchActions lesson). |

**Deferred design (when the deployment target decision allows):**

```swift
// Gated at runtime + compile-time behind iOS 26 availability.
if #available(iOS 26.0, *) {
    // capability check, then LanguageModelSession with @Generable<ItemMetadata>
} else {
    // fall back to VisionService classification
}
```

## 9. App Intents / WidgetKit / ActivityKit (documented, deferred)

| Capability | Framework | Exact symbol | Min iOS | Purpose | Decision |
|---|---|---|---|---|---|
| Intent | AppIntents | `AppIntent`, `@Parameter`, `IntentResult` | 16 | "Add inventory item", "Mark packed" | DESIGNED — blueprint only |
| Entity | AppIntents | `AppEntity`, `EntityQuery` | 16 | Expose `PackingItem`/`Trip` to system | DESIGNED |
| Intent testing | AppIntentsTesting | `AppIntentTesting` | 17 | Test intents | DESIGNED |
| Interactive widget | WidgetKit | `AppIntentConfiguration`, `Button(intent:)` | 17 | Next trip / progress widget | DESIGNED |
| Live Activity | ActivityKit | `Activity<Attributes>`, `ActivityConfiguration` | 16.1 | Departure countdown | DESIGNED |

Blueprint (App Intents):

```swift
import AppIntents
struct AddInventoryItemIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Inventory Item"
    @Parameter(title: "Item Name") var itemName: String
    func perform() async throws -> some IntentResult {
        // insert PersonalItem via shared store
        return .result()
    }
}
```

## 10. Liquid Glass — iOS 26 design (documented, deferred)

| Capability | Framework | Exact symbol | Min iOS | Purpose | Decision |
|---|---|---|---|---|---|
| Glass effect | SwiftUI | `glassEffect(_:in:)` | **26** | Scanner controls, floating buttons | DESIGNED — iOS 26-only; verify symbol against runner SDK before any use |
| Container | SwiftUI | `GlassEffectContainer`, `GlassEffectTransition` | **26** | Grouped glass surfaces | DESIGNED |
| Styles | SwiftUI | `GlassButtonStyle`, `GlassProminentButtonStyle` | **26** | Buttons | DESIGNED |

## 11. Availability / verification rules

1. **Deployment target:** iOS 17.0 (repo-wide, unchanged — see `docs/ARCHITECTURE.md`).
2. **New-symbol rule:** a symbol introduced after iOS 17 may only enter the source
   inside a compile-time `@available(iOS N, *)` boundary, and that boundary alone is
   **never** proof the symbol exists in the SDK. The macOS CI compiler is the gate.
3. **searchActions lesson:** an earlier "availability-safe" shim around
   `.searchActions` — an API that **does not exist in SwiftUI at all** — was rejected
   by Xcode 26.3 (`value of type 'Self' has no member 'searchActions'`). Static grep
   "proof" is not proof. Every entry above was re-checked against Apple documentation;
   entries marked ⚠️ must additionally be confirmed by the runner's actual SDK.
4. **Verification matrix:** every row in this bible must eventually carry
   `CI-VALIDATED` from a real `xcodebuild` run before its capability is marked COMPLETE
   in the capability matrix.
