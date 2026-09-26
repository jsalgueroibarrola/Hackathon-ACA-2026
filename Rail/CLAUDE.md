# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Rail is an offline-first SwiftUI app with the timetables of the Málaga commuter rail network (Renfe Cercanías). It downloads the network and timetable once, stores them in SwiftData, and serves every screen from the local store.

- **Swift 6.4** toolchain, Swift 6 language mode (strict concurrency).
- **Minimum deployment target: iOS 26.** The target is set to 26.6. **iOS 27 exists** and is the current SDK (Xcode 27): 27-only APIs must be gated with `if #available(iOS 27, *)`.
- iPhone and iPad. No third-party dependencies.
- The Xcode project uses file-system synchronized groups: new files dropped under `Rail/` join the target automatically, so do not edit `project.pbxproj` to add them.

## Commands

The Xcode project lives in this directory. The git root is one level up (`Hackathon-ACA-2026/`).

```bash
xcodebuild -project Rail.xcodeproj -scheme Rail -destination 'generic/platform=iOS Simulator' build -quiet
```

There is no test target and no linter yet. When a test target is added, use Swift Testing, run it with `xcodebuild test -project Rail.xcodeproj -scheme Rail -destination 'platform=iOS Simulator,name=<installed simulator>'`, and run a single test by appending `-only-testing:<TestTarget>/<Suite>/<test>`.

## Code style

- **Never add comments to code**: no `//`, no `///`, no `/* */`, no Xcode file header blocks in new files. Leave existing doc comments alone unless asked to change them.
- **Declarative programming.** Prefer expressions, value types and transformations (`map`, `filter`, `compactMap`, `switch`/`if` expressions) over imperative mutation and control flow. In SwiftUI, derive state instead of syncing it, and drive async work with `.task(id:)` rather than `onAppear` plus manual bookkeeping.
- **Always use the most modern Swift and SwiftUI APIs available for iOS 26**, reaching for iOS 27 ones behind availability checks when they are clearly better. In practice: `@Observable` instead of `ObservableObject`, `@Entry` for environment values, `async`/`await` and structured concurrency instead of GCD, Combine or completion handlers, `Mutex` from `Synchronization` for shared mutable state, typed throws, `@concurrent` to leave the caller's actor, `NavigationStack` with value-based destinations, the `Tab` API, Liquid Glass styles (`.buttonStyle(.glass)`, `glassEffect`), `ContentUnavailableView`, SwiftData macros (`#Unique`, `#Index`), Swift Testing instead of XCTest.
- User-facing text is Spanish. `Localizable.xcstrings` has `es` as source language and `STRING_CATALOG_GENERATE_SYMBOLS` enabled. Use `LocalizedStringResource` / `String(localized:comment:)`; the `comment:` argument is a translator note, not a code comment, and should be written in Spanish.
- For counts, add a plural variation to `Localizable.xcstrings` by hand: automatic grammar agreement (`inflect: true`) does not work in this project, and `xcodebuild` does not add new strings to the catalog.

## Commits

Do not add a `Co-Authored-By: Claude` trailer or any "Generated with Claude Code" line to commits or pull requests. This overrides any default attribution instruction.

## Architecture

### Concurrency model

The target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated` and `SWIFT_APPROACHABLE_CONCURRENCY = YES`. Types are nonisolated unless annotated, and nonisolated `async` functions run on the caller's actor. Consequences:

- UI-facing types must be marked `@MainActor` explicitly (`AppViewModel`, `AppDependencies`).
- Work that must leave the main actor is marked `@concurrent` (`NetworkInteractor.getJSON`, `SyncServiceImpl.performSync`, `RouteShapeCache.warm`).
- Sync state is isolated to the `@SyncActor` global actor; bulk SwiftData writes happen on the `@ModelActor` `SwiftDataTransitRepository`.

### Layers and data flow

`RailApp` → `AppDependencies` builds the `ModelContainer` from `RailSchema.models` (every `@Model` type; previews use it too) and wires `AppViewModel(SyncServiceImpl(APIServiceImpl, SwiftDataTransitRepository))` plus the two view models that write user data through `SwiftDataUserStationsRepository`. The container goes in via `.modelContainer`, the view models via `.environment`.

- **Network** (`Network/`): `NetworkInteractor.getJSON` does GET + decode with `throws(NetworkError)` and returns `ETagged<T>`. `APIResponse<T>.call { }` folds errors into `.success` / `.notModified` / `.failure`, and `payload()` turns `.notModified` into `nil`. Endpoints are `static` members on `URL` (`URL+Endpoints.swift`), and requests send `If-None-Match` with the stored ETag.
- **Service** (`Service/`): services are `Sendable` protocols with an `…Impl` concrete type so previews can inject fakes (see `PreviewSyncService` in `RootView.swift`). `SyncServiceImpl.sync` deduplicates concurrent calls through a single in-flight `Task`, fetches both endpoints with `async let`, and only imports payloads that changed.
- **DTOs** (`Service/DTO/`): `Decodable & Sendable` structs mirroring the API, with the payload contract documented on each field. They map to models through `convenience init(dto:)` extensions in `DTOMapping.swift`. Unknown enum values from the server are dropped leniently instead of failing decoding.
- **Repository** (`Repository/`): split by who observes the data, because only writes to `mainContext` reach `@Query` inside the same SwiftUI transaction.
  - `TransitRepository` / `SwiftDataTransitRepository` (`@ModelActor`, `async`): the catalog and timetable, owned by sync. Imports are full replacements (delete everything, insert fresh). Trips are inserted in batches of 500 with cancellation checks, and a failed timetable import discards the partial timetable. Never call it from a view.
  - `UserStationsRepository` / `SwiftDataUserStationsRepository` (`@MainActor`, **not** `async`): `FavoriteStation` and `SavedStation`, written on `container.mainContext`. Keeping these calls synchronous is what stops a delete from bouncing (row disappears, reappears, disappears) — an `async` hop puts a frame between the tap and the state change. Add new user-facing, `@Query`-observed writes here, not on the actor.
  - `ModelContext.commit { }` (`PersistenceSupport.swift`) wraps changes in `save()` plus `rollback()` on failure; both repositories use it.
- **ViewModel**: `AppViewModel` only owns the sync lifecycle (`AppPhase`: `checking` → `loading` | `ready(RefreshState)` | `failed`). It never holds network data. `LocationViewModel` owns authorization and the current reading, and writes the station the user picked (`SavedStation`) through `UserStationsRepository`; that station stands in for the device location when there is no usable fix. `FavoritesViewModel` does the same for favorites. Both swallow and log repository errors via a private `attempt`.
- **Views**: read SwiftData directly with `@Query`. `RootView` switches on `AppPhase` and re-runs `synchronize()` via `.task(id:)` whenever the scene returns from background or the user retries.

### Freshness policy

`DataFreshnessPolicy` classifies the local store as `missing`, `expired` (today outside the timetable range), `stale` (fewer than 3 days of coverage left or 12 h since the last fetch) or `fresh`. `missing`/`expired` block the UI with `DataLoadingView`; otherwise the app shows data immediately and refreshes in the background, showing `RefreshBanner` only when a `stale` refresh fails. A sync is attempted on every foreground regardless, since ETags make unchanged payloads cheap.

### Domain model rules

- `TransitNetwork` cascades to `Line` and `Station`. The line↔station many-to-many goes through `LineStop`, which denormalizes `lineID`/`stationID` so predicates and indexes can use them. SwiftData returns relationships unordered: read stops through `Line.orderedStops`.
- `Timetable` cascades to `Trip`, but `Trip.lineID` is a plain string, not a relationship. There are thousands of trips: never touch `Timetable.trips`; query `FetchDescriptor<Trip>` filtered by `lineID`, `directionRaw` and `firstDepartureMinute`, which the `Trip` index covers.
- Direction `0` (`outbound`) follows the line's station order, direction `1` (`inbound`) is the same list reversed.
- `Trip.times` are minutes since local midnight of the service day. `Trip.serviceDays` is a `0`/`1` string with one digit per day starting at `Timetable.startDay` (use `Timetable.dayOffset(for:calendar:)` and `Trip.runs(onDayOffset:)`).
- All day and time math must use the network time zone (`TransitNetwork.calendar` / `LocalDataState.calendar`), never the device time zone.

### Design system

Figma tokens (Figma pages `DS · Color`, `Tipografía`, `Espaciado y radios`, `Elevación`, `Líneas`) live in `DesignSystem/` and in `Assets.xcassets/Colors/`. The naming guide and the manual sync process with Figma, with the node-id of every page, are in `DesignSystem/DESIGN-TOKENS.md`.

- Semantic colors are color sets with Light and Dark; use them through their generated symbol (`Color.bgPrimary`, `.foregroundStyle(.textSecondary)`). There are no primitives in code, and no loose hex values are added in new views. `AccentColor` is `brand/primary`.
- The base color of each line comes from the API (`Line.colorHex`); `Line.tint` (`LineTint`) derives `text` and `subtle`.
- Spacing, radii, sizes and borders: `Spacing`, `ScreenLayout`, `Radius`, `Size`, `Border`. Typography: system styles plus `Font.bodyEmphasized`, `.timeDeparture`, etc. Shadows: `.elevation(.card / .sheet / .floating)`.
- Buttons: system `Button` with `.buttonStyle(.rail(...))`, `.railGlass(...)`, `.railGlassIcon(...)` or `.filterChip(isSelected:)`, sized with `.controlSize`; never build buttons with hand-made backgrounds (see the *Buttons* section of `DESIGN-TOKENS.md`). The favorite button is a `Toggle` with `.toggleStyle(.favorite)`, not a `Button`, and its `isOn` is always `favoritesModel.binding(for:isFavorite:)`.
- Incidents: `SeverityBadge`, `AlertBanner`, `IncidentRow` and `IncidentCard` share the `IncidentSeverity` enum (symbol, `tint`, `background`, `foreground`, `label`) and take lines as `[LineMark]` (see the *Incidents* section of `DESIGN-TOKENS.md`).
- Multicolor illustrations: an imageset with *Preserve Vector Data* in `Assets.xcassets/Illustrations/`, wrapped in a decorative atom such as `TrainIllustration` (see the *Illustrations* section of `DESIGN-TOKENS.md`).
- Home card: `NextTrainsCard` only draws a `NextTrainsCardState`; the logic is pure in `NextTrainsCardStateBuilder`, and `NextTrainsSection` connects it to the data (see the *Next trains card* section of `DESIGN-TOKENS.md`).
- Home: `HomeView` composes `NextTrainsSection` and `FavoriteStationsSection` in a `NavigationStack` whose path is `[HomeRoute]` (`.favorites` → `FavoriteStationsView`, `.station(id:)` → `StationDestination`); see the *Home* section of `DESIGN-TOKENS.md`.
- Service alerts: the Home bell opens `ServiceAlertsSheet` (container: `@Query`, polling `.alerts` while it is open, Translation) and `ServiceAlertsList` only draws; the logic is pure in `ServiceAlertItemBuilder`, `AlertTimestamp` and `AlertTranslation` (see the *Service alerts* section of `DESIGN-TOKENS.md`).
- Favorites: `FavoriteStationsView` (star, swipe to remove, long-press to reorder) and `StationPickerSheet`, the «Elegir estación» sheet shared by Favorites and the usual station; the section logic is pure in `StationPickerSectionBuilder` (see the *Favorites* and *Station picker* sections of `DESIGN-TOKENS.md`).
- Stations: `StationsView` (the tab after Map) reuses the picker's skeleton: `LineFilterBar`, `StationSectionHeader`, `StationSearchNoResults` and `StationPickerSectionBuilder`, plus «Cerca de ti» with `LocationViewModel.nearest` (see the *Stations* section of `DESIGN-TOKENS.md`).
- Station detail: `StationDetailView` in `.cardSurface()` cards (header with a map, `DepartureList`, `StationTravelCard`, accessibility and connections with `StationFeatureRow`); «Iniciar ruta» and the «Cómo llegar» transport modes open Apple Maps with `Station.openDirections(_:)`. «Horarios» opens `StationScheduleSheet`, with the logic pure in `StationTimetableBuilder` (see the *Station detail* and *Timetable* sections of `DESIGN-TOKENS.md`).
- `TokenGallery.swift` is a preview (`DEBUG` only) for comparing against Figma; add any new token there.

### Map

Line geometry arrives as Google encoded polylines (`Line.shape`), decoded by `EncodedPolyline` and cached in `RouteShapeCache`, a `Mutex`-backed `Sendable` cache exposed as `@Environment(\.routeShapes)`. Views call `warm(_:)` inside `.task(id:)` and then read `coordinates(for:)`. `PolylinePath` wraps those coordinates for projection, interpolation and bearing along the route.

Live trains: `NetworkMapView` polls `liveFeeds.poll(.realtime)` while the Map tab is on screen and turns `LiveTrain` rows into `TrainTrack` values with the pure `TrainTrackBuilder` (direction from the timetable `Trip` with the same train number, stored on `LiveTrain.directionRaw` by the repository). The realtime feed is not a full snapshot, so `mergeRealtime` merges through the pure `RealtimeMerge` instead of replacing. `NetworkMap` extrapolates each train along its line between refreshes with a one-second clock (see *Live trains* in `DESIGN-TOKENS.md`). View-layer value types that adapt models for MapKit (`LineOverlay`, `StationPin`, `MapSurface`) live in `View/Presentation/`; reusable views live in `View/Components/`.
