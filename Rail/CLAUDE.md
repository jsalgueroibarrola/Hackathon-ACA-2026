# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Project

Rail is an offline-first SwiftUI app with the timetables of the Málaga commuter rail network (Renfe Cercanías). It downloads the network and timetable once, stores them in SwiftData, and serves every screen from the local store. A widget extension shows the next trains of a favorite station.

- **Swift 6.4** toolchain, Swift 6 language mode (strict concurrency).
- **Deployment target: iOS 26** (26.6). iOS 27 is the current SDK (Xcode 27): gate 27-only APIs with `if #available(iOS 27, *)`.
- iPhone and iPad. No third-party dependencies.
- Targets: `Rail` (the app) and `RailWidgetsExtension` (`RailWidgets/`).

## Commands

The Xcode project lives in this directory; the git root is one level up (`Hackathon-ACA-2026/`).

```bash
xcodebuild -project Rail.xcodeproj -scheme Rail -destination 'generic/platform=iOS Simulator' build -quiet
```

There is no test target and no linter yet. When a test target is added, use Swift Testing, run it with `xcodebuild test -project Rail.xcodeproj -scheme Rail -destination 'platform=iOS Simulator,name=<installed simulator>'`, and run a single test by appending `-only-testing:<TestTarget>/<Suite>/<test>`.

## Project files

- The project uses file-system synchronized groups: new files under `Rail/` or `RailWidgets/` join their target automatically. Do not edit `project.pbxproj` to add them.
- Files from `Rail/` that the widget also compiles (`RailSchema`, `RailStore`, `RailWidgetLink`, the models, `Domain/StationSchedule.swift`, the design-system tokens, `Localizable.xcstrings`, `Assets.xcassets`…) are listed in the `membershipExceptions` of the *Exceptions for "Rail" folder in "RailWidgetsExtension" target* set. A new file the widget needs must be added there.

## Code style

- **Never add comments to code**: no `//`, no `///`, no `/* */`, no Xcode file header blocks in new files. Leave existing doc comments alone unless asked to change them.
- **Declarative programming.** Prefer expressions, value types and transformations (`map`, `filter`, `compactMap`, `switch`/`if` expressions) over imperative mutation and control flow. In SwiftUI, derive state instead of syncing it, and drive async work with `.task(id:)` rather than `onAppear` plus manual bookkeeping.
- **Use the most modern Swift and SwiftUI APIs available for iOS 26**, and iOS 27 ones behind availability checks when they are clearly better: `@Observable` instead of `ObservableObject`, `@Entry` for environment values, `async`/`await` and structured concurrency instead of GCD, Combine or completion handlers, `Mutex` from `Synchronization` for shared mutable state, typed throws, `@concurrent` to leave the caller's actor, `NavigationStack` with value-based destinations, the `Tab` API, Liquid Glass (`.buttonStyle(.glass)`, `glassEffect`), `ContentUnavailableView`, SwiftData macros (`#Unique`, `#Index`), Swift Testing instead of XCTest.

### Localization

- User-facing text is Spanish. `Localizable.xcstrings` has `es` as source language and `STRING_CATALOG_GENERATE_SYMBOLS` enabled.
- Use `LocalizedStringResource` / `String(localized:comment:)`. The `comment:` argument is a translator note, not a code comment, and is written in Spanish.
- For counts, add the plural variation to `Localizable.xcstrings` by hand: automatic grammar agreement (`inflect: true`) does not work in this project, and `xcodebuild` does not add new strings to the catalog.

## Commits

Do not add a `Co-Authored-By: Claude` trailer or any "Generated with Claude Code" line to commits or pull requests. This overrides any default attribution instruction.

## Architecture

### Concurrency model

The target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated` and `SWIFT_APPROACHABLE_CONCURRENCY = YES`. Types are nonisolated unless annotated, and nonisolated `async` functions run on the caller's actor. Consequences:

- UI-facing types must be marked `@MainActor` explicitly (`AppViewModel`, `AppDependencies`).
- Work that must leave the main actor is marked `@concurrent` (`NetworkInteractor.getJSON`, `SyncServiceImpl.performSync`, `RouteShapeCache.warm`).
- Sync state is isolated to the `@SyncActor` global actor; bulk SwiftData writes happen on the `@ModelActor` `SwiftDataTransitRepository`.

### Composition

`RailApp` → `AppDependencies` builds the `ModelContainer` from `RailSchema.models` (every `@Model` type; previews use it too) with `RailStore.configuration()`, which lives in the App Group so the widget can read it. It wires:

- `AppViewModel(SyncServiceImpl(APIServiceImpl, SwiftDataTransitRepository))`.
- The view models that write user data through `SwiftDataUserStationsRepository`.
- The live feed service, the schedule repository, `RouteServiceImpl`, `RouteShapeCache` and `NetworkConnectivityService`.

The container goes in via `.modelContainer`, the view models via `.environment`, and the services through their `@Entry` environment keys (`\.liveFeeds`, `\.schedules`, `\.routeEstimates`, `\.routeShapes`, `\.connectivity`). Their defaults are inert (`Disabled…`, or `nil` for the shape cache), so no singleton is needed. The keys and the view modifiers that load through them live in `App/Environment/`.

### Layers

- **Network** (`Network/`): `NetworkInteractor.getJSON` does GET + decode with `throws(NetworkError)` and returns `ETagged<T>`. `APIResponse<T>.call { }` folds errors into `.success` / `.notModified` / `.failure`, and `payload()` turns `.notModified` into `nil`. Endpoints are `static` members on `URL` (`URL+Endpoints.swift`); requests send `If-None-Match` with the stored ETag.
- **Service** (`Service/`): `Sendable` protocols with an `…Impl` concrete type so previews can inject fakes (see `PreviewSyncService` in `RootView.swift`).
  - `SyncServiceImpl.sync` deduplicates concurrent calls through a single in-flight `Task`, fetches both endpoints with `async let`, and only imports payloads that changed.
  - `ConnectivityService.updates()` streams whether the device is online (`NWPathMonitor`); views never import `Network`.
  - Travel times are loaded with `.loadRouteEstimates(_:into:)`, which takes a `RouteEstimateRequest` (identified by origin `LocationCell`, station, modes and retry attempt, so GPS jitter does not refetch) and stores `RouteEstimates`. Views never call `\.routeEstimates` directly.
- **DTOs** (`Service/DTO/`): `Decodable & Sendable` structs mirroring the API, with the payload contract documented on each field. They map to models through `convenience init(dto:)` extensions in `DTOMapping.swift`. Unknown enum values from the server are dropped leniently instead of failing decoding.
- **Domain** (`Domain/`): pure `Sendable` schedule and journey types and their builders (`StationScheduleBuilder`, `NextTrainsScheduleBuilder`, `JourneyBuilder`). `Repository/`, the views and the widget depend on them; they never depend on `View/`. Formatting and view items stay in `View/Presentation/`.
- **Repository** (`Repository/`): see below.
- **View models**: `AppViewModel` only owns the sync lifecycle (`AppPhase`: `checking` → `loading` | `ready(RefreshState)` | `failed`) and never holds network data. `LocationViewModel` owns authorization and the current reading, and writes the station the user picked (`SavedStation`), which stands in for the device location when there is no usable fix. `FavoritesViewModel` does the same for favorites and `RecentJourneysViewModel` for recent journey searches. They write through `UserStationsRepository` and swallow and log its errors via a private `attempt`.
- **Views**: read SwiftData directly with `@Query`. `View/Components/` holds only presentational atoms, molecules and organisms; containers that read data for one screen live next to it in a folder per screen (`View/Home/`, `View/StationDetail/`, `View/Map/`…). `RootView` shows `OnboardingView` until `@AppStorage("hasCompletedOnboarding")` is set (the first sync runs underneath it), then switches on `AppPhase` and re-runs `synchronize()` via `.task(id:)` whenever the scene returns from background or the user retries.

### Repositories

Split by who observes the data, because only writes to `mainContext` reach `@Query` inside the same SwiftUI transaction.

- **`TransitRepository` / `SwiftDataTransitRepository`** (`@ModelActor`, `async`): the catalog and timetable, owned by sync. Never call it from a view.
  - Imports are full replacements (delete everything, insert fresh), and network imports go through `commit { }`.
  - The timetable is replaced in a single transaction: the old one is deleted and trips are inserted in batches of 500 with cancellation checks, but nothing is saved until the last batch, so a cancelled or failed import rolls back and keeps the previous timetable.
  - Old trips are deleted through a `FetchDescriptor<Trip>` before the `Timetable`, so the cascade does not fault `Timetable.trips`.
  - Do not use `ModelContext.delete(model:where:)` inside `commit { }`: it deletes straight from the store and `rollback()` cannot undo it.
- **`ScheduleRepository` / `SwiftDataScheduleRepository`** (`@ModelActor`, `async`): station departures for a `ScheduleRequest` (station, timetable key, service day in the network calendar). It fetches the station's trips with `ModelContext.scheduleSource(for:timetable:calendar:)` (`StationScheduleLoading.swift`, shared with the widget) and maps them with `StationScheduleBuilder` / `NextTrainsScheduleBuilder`. Views load it with `.loadSchedules(_:into:using:)`, which reads `@Environment(\.schedules)` and logs failures.
- **`UserStationsRepository` / `SwiftDataUserStationsRepository`** (`@MainActor`, **not** `async`): `FavoriteStation`, `SavedStation` and `RecentJourney`, written on `container.mainContext`. Keeping these calls synchronous stops a delete from bouncing (row disappears, reappears, disappears): an `async` hop puts a frame between the tap and the state change. Add new user-facing, `@Query`-observed writes here, not on an actor.
- `ModelContext.commit { }` (`PersistenceSupport.swift`) wraps changes in `save()` plus `rollback()` on failure; the repositories use it.

### Freshness policy

`DataFreshnessPolicy` classifies the local store as `missing`, `expired` (today outside the timetable range), `stale` (fewer than 3 days of coverage left or 12 h since the last fetch) or `fresh`. `missing`/`expired` block the UI with `DataLoadingView`; otherwise the app shows data immediately and refreshes in the background, showing `RefreshBanner` only when a `stale` refresh fails. A sync is attempted on every foreground regardless, since ETags make unchanged payloads cheap.

### Domain model rules

- `TransitNetwork` cascades to `Line` and `Station`. The line↔station many-to-many goes through `LineStop`, which denormalizes `lineID`/`stationID` so predicates and indexes can use them. SwiftData returns relationships unordered: read stops through `Line.orderedStops`.
- `Timetable` cascades to `Trip`, but `Trip.lineID` is a plain string, not a relationship. There are thousands of trips: never touch `Timetable.trips`; query `FetchDescriptor<Trip>` filtered by `lineID`, `directionRaw` and `firstDepartureMinute`, which the `Trip` index covers.
- Direction `0` (`outbound`) follows the line's station order; direction `1` (`inbound`) is the same list reversed.
- `Trip.times` are minutes since local midnight of the service day. `Trip.serviceDays` is a `0`/`1` string with one digit per day starting at `Timetable.startDay` (use `Timetable.dayOffset(for:calendar:)` and `Trip.runs(onDayOffset:)`).
- All day and time math uses the network time zone (`TransitNetwork.calendar` / `LocalDataState.calendar`), never the device time zone.

### Widget

`RailWidgetsExtension` reads the shared store read-only through `RailWidgetStore` (`RailStore.configuration(allowsSave: false)`) and builds its timeline with the pure `NextTrainsTimelineBuilder`. The station is chosen with `SelectFavoriteStationIntent` / `StationEntity`. The app asks for a refresh with `WidgetReloader.reloadNextTrains()`, and taps come back as `rail://station/<id>` URLs built and parsed by `RailWidgetLink`.

## Design system

Tokens live in `DesignSystem/` and in `Assets.xcassets/Colors/`, maintained by hand.

- **Colors**: semantic color sets with Light and Dark, used through their generated symbol (`Color.bgPrimary`, `.foregroundStyle(.textSecondary)`). A token `color/<group>/<kebab-name>` becomes the color set `<group><CamelName>` in `Assets.xcassets/Colors/<Group>/`; those folders have no *Provides Namespace*. There are no primitives in code and no loose hex values in views. `AccentColor` is `brand/primary`.
- **Line colors** come from the API (`Line.colorHex`); `Line.tint` (`LineTint`) derives `text`.
- **Metrics**: `Spacing`, `ScreenLayout`, `Radius`, `Size`, `Border`. **Typography**: system styles plus `Font.bodyEmphasized`, `.timeDeparture`, etc. **Shadows**: `.elevation(.card / .sheet / .floating)`.
- **Buttons**: system `Button` with `.buttonStyle(.rail(...))`, `.railGlass(...)` or `.filterChip(isSelected:)`, sized with `.controlSize`; never hand-made backgrounds. The favorite button is a `Toggle` with `.toggleStyle(.favorite)` whose `isOn` is always `favoritesModel.binding(for:isFavorite:)`.
- **Incidents**: `SeverityBadge`, `AlertBanner` and `IncidentCard` share the `IncidentSeverity` enum (symbol, `tint`, `background`, `foreground`, `label`) and take lines as `[LineMark]`.
- **Illustrations**: multicolor artwork is an imageset with *Preserve Vector Data* in `Assets.xcassets/Illustrations/`, wrapped in a decorative atom such as `TrainIllustration`.
- `TokenGallery.swift` is a `DEBUG`-only preview of every token; add new tokens there.

## Screens

Each screen keeps its logic in pure builders and its views only draw.

| Screen | Entry point | Notes |
|---|---|---|
| Home | `HomeView` | `NextTrainsSection` + `FavoriteStationsSection` in a `NavigationStack` with path `[AppRoute]` (`.favorites` → `FavoriteStationsView`, `.station(id:)` → `StationDestination`), registered by `.appRouteDestinations()`, which Stations reuses. `NextTrainsCard` only draws a `NextTrainsCardState` built by `NextTrainsCardStateBuilder`. |
| Service alerts | `ServiceAlertsSheet` | Opened from the Home bell; polls `.alerts` while open and translates with Translation. `ServiceAlertsList` draws; logic in `ServiceAlertItemBuilder`, `AlertTimestamp`, `AlertTranslation`. |
| Favorites | `FavoriteStationsView` | Star, swipe to remove, long-press to reorder. |
| Station picker | `StationPickerSheet` | «Elegir estación», shared by Favorites, Onboarding and the usual station; sections from `StationPickerSectionBuilder`. |
| Journeys | `JourneyPlannerView` | Tab after Home. `JourneySearchCard`, recent searches (`RecentJourney`, at most 15, dropped after 30 days unused by `RecentJourneyPolicy`) and `JourneyResultsView` (`AppRoute.journey`). Trips come from `ScheduleRepository.journeys(for:)` → `ModelContext.journeySource(connecting:timetable:calendar:)` → `JourneyBuilder` (direct or one transfer) and `JourneyTimetableBuilder`. |
| Map | `MapScreen` | See *Map* below. |
| Stations | `StationsView` | Tab after Map. Reuses the picker's skeleton (`LineFilterBar`, `StationSectionHeader`, `StationSearchNoResults`, `StationPickerSectionBuilder`) plus «Cerca de ti» with `LocationViewModel.nearest`. |
| Station detail | `StationDetailView` | `.cardSurface()` cards: header with a map, `DepartureList`, `StationTravelCard`, accessibility and connections (`StationFeatureRow`). «Iniciar ruta» and «Cómo llegar» open Apple Maps with `Station.openDirections(_:)`; «Horarios» opens `StationScheduleSheet` (`StationTimetableBuilder`). |
| Onboarding | `OnboardingView` | Six steps in a `NavigationStack(path: [OnboardingStep])` with a hidden bar and a fixed `OnboardingTopBar` (glass back button + `StepIndicator`). Steps 1–5 (welcome, privacy, location, alerts, widget) use `OnboardingFeaturePage`; the widget step shows the in-app mockup `OnboardingWidgetShowcase`, and the location, privacy and alerts images are localized imagesets with `en` variants. Step 6 marks favorites on suggested `StationRow`s and opens `StationPickerSheet(.favorites)`. Logic in `OnboardingStep`, `OnboardingStationsBuilder`, `OnboardingWidgetSampleBuilder`. |

### Map

- **Line geometry** arrives as Google encoded polylines (`Line.shape`), decoded by `EncodedPolyline` and cached in `RouteShapeCache`, a `Mutex`-backed `Sendable` cache exposed as `@Environment(\.routeShapes)`. Views call `warm(_:)` inside `.task(id:)` and then read `coordinates(for:)`. `PolylinePath` wraps those coordinates for projection, interpolation and bearing along the route.
- **Live trains**: `MapScreen` polls `liveFeeds.poll(.realtime)` while the Map tab is on screen and turns `LiveTrain` rows into `TrainTrack` values with the pure `TrainTrackBuilder` (direction from the timetable `Trip` with the same train number, stored on `LiveTrain.directionRaw` by the repository). The realtime feed is not a full snapshot, so `mergeRealtime` merges through the pure `RealtimeMerge` instead of replacing. `TransitMap` extrapolates each train along its line between refreshes with a one-second clock.
- **MapKit adapters** (`LineOverlay`, `StationPin`) live in `View/Presentation/`; reusable views in `View/Components/`.
- **Bottom of the tab**: the nearby carousel, the controls capsule and the station sheet are one system. The sheet is our own SwiftUI view, not a `.sheet`, because SwiftUI can't observe a system sheet's position while it animates, and UIKit is not allowed.
  - `MapSheetModel` (`@Observable`) holds the origin (`.card(id)` or `.bottom`) and the drag translation; the sheet has a single height, no detents.
  - `MapBottomLayer` turns them into two values, the sheet extent and its presence, and `MapBottomStage` (`@Animatable`) derives everything else from them on every frame with pure functions in `MapSheetLayout` and `MapBottomChrome`: the sheet frame, the card↔sheet morph (the card rect comes from `MapBottomAnchors`), the carousel opacity and the controls position.
  - Every change goes through one `withAnimation` in `MapScreen`; the bottom chrome has no `.animation(_:value:)`.
