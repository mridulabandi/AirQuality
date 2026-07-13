# AirCheck (MVL iOS Assignment)

A map-based location comparison and booking app: pick two points (A/B), see live
air quality at each, book a route between them, and review monthly history.

## Requirements
- Xcode 16+
- iOS 17+ device or simulator (project currently targets iOS 26.5 — lower this
  in Build Settings if you need to test on older simulators)

## 1. Clone and open
```bash
git clone <your-repo-url>
cd MVLAssignment
open AirCheck.xcodeproj
```
Dependencies (Alamofire, Google Maps SDK) are managed via Swift Package
Manager and resolve automatically on first build.

> Note: this repo currently also contains an empty `MVLAssignment.xcodeproj`
> stub left over from an in-progress rename. `AirCheck.xcodeproj` is the
> project to open — the stub should be deleted before final submission.

## 2. API key setup (required before first run)

No API key is hardcoded anywhere in source. Two keys are required, injected
via an untracked `.xcconfig` file:

1. Get free keys:
   - AQI: https://aqicn.org/data-platform/token/
   - Reverse geocoding: https://www.bigdatacloud.com/geocoding-apis/free-reverse-geocode-to-city-api

   (No Google Maps key needed — the map screen uses Apple's MapKit via
   native SwiftUI, per the assignment's SwiftUI/MapKit alternative.)

2. In Xcode: **File → New → File → Configuration Settings File**, name it
   `Config.xcconfig`, save it at the project root (do **not** add it to git —
   it's already covered by `.gitignore`).

3. Add:
   ```
   AQICN_TOKEN = your_token_here
   BIGDATACLOUD_KEY = your_key_here
   ```

4. Select your project in the navigator → target → **Info** tab → under each
   configuration (Debug/Release) set the xcconfig file you just created.

5. Add matching custom keys under **Info → Custom iOS Target Properties**:
   | Key | Value |
   |---|---|
   | `AQICN_TOKEN` | `$(AQICN_TOKEN)` |
   | `BIGDATACLOUD_KEY` | `$(BIGDATACLOUD_KEY)` |

   This lets `Bundle.main.object(forInfoDictionaryKey:)` read them at runtime
   (see `APIConstants.swift`) without the values ever appearing in source.

6. Add `NSLocationWhenInUseUsageDescription` the same way if it isn't already
   present (it currently is, under the target's Info settings).

7. **Remove the unused GoogleMaps SPM package**: project navigator → your
   project → **Package Dependencies** tab → select `ios-maps-sdk` → **−**.
   It's no longer referenced by any file now that Screen 1 is native
   SwiftUI/MapKit, and an unused dependency is one more thing a reviewer
   might ask you to justify.

Build and run (`Cmd+R`).

## 3. Architecture

MVVM + Clean Architecture, three layers:

- **Domain** — entities, repository protocols, use cases. No UIKit/SwiftUI/
  Alamofire/GoogleMaps imports; pure Swift business rules.
- **Data** — DTOs, Alamofire-backed network services, repository
  implementations, and `MockBookingRepository` (stands in for the `/books`
  backend, which the assignment doesn't provide).
- **Presentation** — one `ObservableObject` ViewModel + one native SwiftUI
  View per screen (`Presentation/SwiftUI/`), driven by `AppFlowView`'s
  `NavigationStack`. A shared `BookingFlowStore` (Combine `ObservableObject`)
  holds A/B slot state across all 5 screens so "reset on return to Screen 1"
  and "history row pre-fills Screen 1" don't require passing state through
  navigation calls. Screen 1's map uses Apple's MapKit (`Map` view), per the
  assignment's SwiftUI/MapKit alternative to Google Maps.
- **DI** — `AppDIContainer` is the single composition root. Mock vs. real
  `BookingRepository` is switched in one place (`useMockBooking` flag) —
  every use case and view model depends on the protocol, never the concrete
  type, so nothing else changes when a real backend exists.

## 4. Testing
Unit tests live in `MVLAssignmentTests/`, separate from production code, and
cover:
- `Coordinate.cacheKey` — the "same location if lat/lng match to 3 decimal
  places" rule
- `GeoLocation.displayName` — nickname-overrides-address behavior
- `BookingFlowStore` — Set A → Set B → Book state machine, and reset
- `AddressNameMapper` — the "top-2 highest-order administrative entries"
  reverse-geocode rule
- `MockBookingRepository` — accessed only through the `BookingRepository`
  protocol

Run with `Cmd+U`.

## 5. Known limitations
- `/books` has no real backend per the assignment; `MockBookingRepository` is
  used by default. `LiveBookingRepository` exists and implements the same
  protocol for when a real endpoint is available — flip
  `AppDIContainer.useMockBooking` to `false` to switch.
- Location-permission-denied state is intentionally unhandled per the
  assignment's explicit scope note.
