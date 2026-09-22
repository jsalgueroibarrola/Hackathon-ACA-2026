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

## Commits

Do not add a `Co-Authored-By: Claude` trailer or any "Generated with Claude Code" line to commits or pull requests. This overrides any default attribution instruction.

## Architecture

### Concurrency model

The target sets `SWIFT_DEFAULT_ACTOR_ISOLATION = nonisolated` and `SWIFT_APPROACHABLE_CONCURRENCY = YES`. Types are nonisolated unless annotated, and nonisolated `async` functions run on the caller's actor. Consequences:

- UI-facing types must be marked `@MainActor` explicitly (`AppViewModel`, `AppDependencies`).
- Work that must leave the main actor is marked `@concurrent` (`NetworkInteractor.getJSON`, `SyncServiceImpl.performSync`, `RouteShapeCache.warm`).
- Sync state is isolated to the `@SyncActor` global actor; SwiftData writes happen on the `@ModelActor` `SwiftDataRepository`.

### Layers and data flow

`RailApp` → `AppDependencies` builds the `ModelContainer` (schema roots `TransitNetwork` and `Timetable`) and wires `AppViewModel(SyncServiceImpl(APIServiceImpl, SwiftDataRepository))`. The container goes in via `.modelContainer`, the view model via `.environment`.

- **Network** (`Network/`): `NetworkInteractor.getJSON` does GET + decode with `throws(NetworkError)` and returns `ETagged<T>`. `APIResponse<T>.call { }` folds errors into `.success` / `.notModified` / `.failure`, and `payload()` turns `.notModified` into `nil`. Endpoints are `static` members on `URL` (`URL+Endpoints.swift`), and requests send `If-None-Match` with the stored ETag.
- **Service** (`Service/`): services are `Sendable` protocols with an `…Impl` concrete type so previews can inject fakes (see `PreviewSyncService` in `RootView.swift`). `SyncServiceImpl.sync` deduplicates concurrent calls through a single in-flight `Task`, fetches both endpoints with `async let`, and only imports payloads that changed.
- **DTOs** (`Service/DTO/`): `Decodable & Sendable` structs mirroring the API, with the payload contract documented on each field. They map to models through `convenience init(dto:)` extensions in `DTOMapping.swift`. Unknown enum values from the server are dropped leniently instead of failing decoding.
- **Repository** (`Repository/`): imports are full replacements (delete everything, insert fresh). Trips are inserted in batches of 500 with cancellation checks, and a failed timetable import discards the partial timetable.
- **ViewModel**: `AppViewModel` only owns the sync lifecycle (`AppPhase`: `checking` → `loading` | `ready(RefreshState)` | `failed`). It never holds network data.
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

Tokens de Figma (`DS · Color`, `Tipografía`, `Espaciado y radios`, `Elevación`, `Líneas`) viven en `DesignSystem/` y en `Assets.xcassets/Colors/`. La guía de nombres y de sincronización manual con Figma, con los node-id de cada página, está en `DesignSystem/DESIGN-TOKENS.md`.

- Colores semánticos son color sets con Light y Dark; úsalos por su símbolo generado (`Color.bgPrimary`, `.foregroundStyle(.textSecondary)`). No hay primitivas en código y no se añaden hex sueltos en vistas nuevas. `AccentColor` es `brand/primary`.
- El color base de cada línea viene de la API (`Line.colorHex`); `Line.tint` (`LineTint`) deriva `text` y `subtle`.
- Espaciado, radios, tamaños y bordes: `Spacing`, `ScreenLayout`, `Radius`, `Size`, `Border`. Tipografía: estilos de sistema más `Font.bodyEmphasized`, `.timeDeparture`, etc. Sombras: `.elevation(.card / .sheet / .floating)`.
- Botones: `Button` del sistema con `.buttonStyle(.rail(...))`, `.railGlass(...)` o `.railGlassIcon(...)` y tamaño con `.controlSize`; no se crean botones con fondos a mano (ver sección *Botones* de `DESIGN-TOKENS.md`).
- `TokenGallery.swift` es un preview (solo `DEBUG`) para comparar con Figma; añade ahí cualquier token nuevo.

### Map

Line geometry arrives as Google encoded polylines (`Line.shape`), decoded by `EncodedPolyline` and cached in `RouteShapeCache`, a `Mutex`-backed `Sendable` cache exposed as `@Environment(\.routeShapes)`. Views call `warm(_:)` inside `.task(id:)` and then read `coordinates(for:)`. View-layer value types that adapt models for MapKit (`LineOverlay`, `StationPin`, `MapSurface`) live in `View/Presentation/`; reusable views live in `View/Components/`.
