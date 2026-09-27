# Design tokens · syncing with Figma

Source of truth: the Figma file **Diseño UX/UI ACA hackathon** (`WFoeo57elVOwmgKto1iwfq`).
The tokens in this directory and the color sets in `Assets.xcassets/Colors` are maintained **by hand** from those pages. When the designer changes something, it is edited here; there is no script or intermediate JSON.

| Figma page | node-id | What it defines | Where it lives in the project |
|---|---|---|---|
| DS · Color | `19:307` | Primitives (`29:2`), Light/Dark semantic colors (`30:2`, grid `30:8`), usage rules (`32:2`) | `Assets.xcassets/Colors/*` and `AccentColor` |
| DS · Tipografía | `19:308` | SF Pro scale + SwiftUI equivalent (`22:6`) | `Typography.swift` |
| DS · Espaciado y radios | `19:309` | `spacing/*`, `radius/*`, `size/*`, `border/*`, `layout/*` (`23:2`) | `Spacing.swift`, `Radius.swift`, `Size.swift`, `Border.swift` |
| DS · Elevación | `19:310` | Shadow levels (`23:152`) | `Elevation.swift` |
| DS · Líneas | `19:311` | Line badges, status chips, how to add a line (`24:2`) | `LineTint.swift` |
| Componentes · A2 LineBadge | `44:36` | Line badge atom (`40:61`) | `View/Components/Atoms/LineBadge.swift` |
| Componentes · A3 StatusChip | `44:66` | Train status atom (`40:71`) | `View/Components/Atoms/StatusChip.swift` |
| Componentes · A4 Button | `44:96` | Prominent / Bordered / Borderless button (`48:314`) | `View/Components/Atoms/Button/RailButtonStyle.swift` |
| Componentes · A6 GlassButton | `51:18` | Liquid Glass Clear / Tinted button (`49:57`) | `View/Components/Atoms/Button/RailGlassButtonStyle.swift` |
| Componentes · A8 SeverityBadge | `102:22` | Incident severity atom (`102:78`) | `View/Components/Atoms/SeverityBadge.swift` |
| Componentes · A9 FavoriteButton | `122:26` | Favorite star atom (`122:78`) | `View/Components/Atoms/FavoriteToggleStyle.swift` |
| Componentes · A10 FilterChip | `148:794` | Filter chip atom (`148:42`) | `View/Components/Atoms/FilterChipStyle.swift` |
| Componentes · M1 DepartureRow | `56:153` | Departure row molecule (`54:125`) | `View/Components/Molecules/DepartureRow.swift` |
| Componentes · M2 StationRow | `56:183` | Station row molecule (`54:161`) | `View/Components/Molecules/StationRow.swift` |
| Componentes · M7 AlertBanner | `102:220` | Incident alert banner molecule (`103:188`) | `View/Components/Molecules/AlertBanner.swift` |
| Componentes · M9 IncidentCard | `104:317` | Incident card molecule (`106:273`) | `View/Components/Molecules/IncidentCard.swift` |
| Mockups · 01 Inicio | `2:53` | Home screen (`2:54`) and one screen per state of the next trains card | `View/Home/HomeView.swift`, `View/Home/NextTrainsSection.swift` |
| Mockups · 01 Inicio · Card | `2:53` | Next trains card organism (`59:1450` and six more states, see *Next trains card*) | `View/Components/Organisms/NextTrainsCard.swift` |
| Mockups · 01 Inicio · Station Container | `2:53` | Station name and proximity molecule (`59:1452`) | `View/Components/Molecules/StationHeader.swift` |
| Mockups · 01 Inicio · Section Header | `2:53` | Section header with icon molecule (`59:1455`) | `View/Components/Molecules/CardSectionHeader.swift` |
| Mockups · 01 Inicio · Permiso / Sin trenes | `2:53` | Card message molecule, regular (`220:1974`) and compact (`220:3269`) | `View/Components/Molecules/CardMessage.swift` |
| Mockups · 01 Inicio · trenecito | `2:53` | Train illustration (`60:3377`); the code uses the SVG supplied by the user, not the one from Figma | `View/Components/Atoms/TrainIllustration.swift` |
| Mockups · 01 Inicio · Favorite Stations Container | `2:53` | Favorite stations section organism (`59:1518`); empty state on the *Home sin favoritas* screen (`220:3329`) | `View/Components/Organisms/FavoriteStationsContainer.swift`, `View/Home/FavoriteStationsSection.swift` |
| Mockups · 01 Inicio · tarjeta de favorita | `2:53` | Favorite station card molecule (`60:2215`) | `View/Components/Molecules/FavoriteStationCard.swift` |
| Mockups · 01 Inicio · Favoritos vacíos | `2:53` | Empty state molecule (`220:3525`) | `View/Components/Molecules/EmptyStateCard.swift` |
| Mockups · 01 Inicio · Imagen de fondo | `2:53` | Header photo (`60:3294`), 393×262 with a *Fill* fill; the original is 786×442 | `Assets.xcassets/Photos/HomeHero.imageset`, `View/Components/Atoms/HomeHeroImage.swift` |
| Mockups · 01 Inicio · Logo | `2:53` | Top bar logo (`143:5493`), 44×44 | `Assets.xcassets/Illustrations/RailLogo.imageset`, `View/Components/Atoms/RailLogo.swift` |
| Mockups · Notificaciones | — | Alerts sheet in Spanish (`389:4606`) and for other languages, with a language banner and «Traducir» (`207:11115`) | `View/Sheets/ServiceAlertsSheet.swift`, `View/Components/Organisms/ServiceAlertsList.swift` |
| Mockups · Favoritos | — | Screen with favorites (`464:8277`) and empty (`464:8524`) | `View/FavoriteStationsView.swift`, `View/Components/Molecules/IllustratedMessage.swift` |
| Mockups · Elegir estación | — | Station picker sheet (`389:5385`) and no results (`389:5417`) | `View/Sheets/StationPickerSheet.swift`, `View/Presentation/StationPickerSection.swift` |

URL of any node: `https://www.figma.com/design/WFoeo57elVOwmgKto1iwfq/?node-id=<id with a hyphen>` (for example `node-id=30-2`).

The *Mockups* rows are not Figma components: they are mockup frames, with no variants and no `Doc/` frame. Their measurements are read from the frames themselves, and hidden layers (`visible: false`) must be discarded.

## Naming convention

| Figma | Project |
|---|---|
| `color/<group>/<kebab-name>` | color set `<group><CamelName>` in `Assets.xcassets/Colors/<Group>/` → `Color.<group><CamelName>` (symbol generated by Xcode) |
| `color/bg/primary` | `bgPrimary` → `Color.bgPrimary`, `.foregroundStyle(.bgPrimary)` |
| `color/status/success-bg` | `statusSuccessBg` |
| `spacing/2xs · xs · sm · … · 4xl` | `Spacing.xxs · xs · sm · … · xxxxl` |
| `layout/margin · gutter` | `ScreenLayout.margin · gutter` (`Layout` already exists in SwiftUI); `ScreenLayout.maxContentWidth` (640) is the project's own, for iPad and landscape |
| `radius/sm … xl` | `Radius.sm … xl`; `radius/full` is expressed with `.capsule` / `.circle`, not with the number |
| `size/touch-min · row-min · icon-md · line-badge …` | `Size.touchMin · rowMin · iconMd · lineBadge …` |
| `border/hairline · thin · thick` | `Border.hairline · thin · thick` |
| Text styles | system styles (`.body`, `.headline`, …) or `Font.bodyEmphasized`, `.timeDeparture`, … |
| `Elevation/Card · Sheet · Floating` | `.elevation(.card / .sheet / .floating)` |

Only the tokens some view uses are in code: `spacing/3xl · 5xl`, `radius/none`, `size/icon-sm · glass-control-lg · navbar · tabbar` and `border/thin` exist in Figma but not in the project. Add them back when a view needs them.

The folders in `Assets.xcassets/Colors` do **not** have *Provides Namespace*: they only organize; the color set name is the symbol name. The SwiftUI name of each color appears in the "SwiftUI" column of the semantic colors page, and that of spacing/radius/size on their own page: copy it verbatim.

## How to update

### Change the value of an existing color
1. In Figma, page *DS · Color* → section *02 Color · Semánticos* → the token's row. The **Light** and **Dark** swatches are frames with an explicit mode.
2. In Xcode, `Assets.xcassets/Colors/<Group>/<name>.colorset` → edit *Any Appearance* (Light) and *Dark*. Values are sRGB hex; `bg/scrim` and `interactive/pressed-overlay` carry alpha.
3. With Claude and the Figma MCP: `get_variable_defs` on the row's **Light** frame returns the light value, and on the **Dark** frame the dark one (for example `30:26` and `30:29` for `bg/primary`). `get_design_context` on the grid `30:8` returns every row at once, with each mode's hex as the fallback of `var(--color/...)`.

### Add a new color
1. Create the color set in the group's folder with the name from Figma's SwiftUI column (or derive it with the convention above).
2. Add Any/Light and Dark. Xcode generates `Color.<name>` when building.
3. Add it to the matching list in `TokenGallery.swift` so it can be reviewed in the preview.

### Change spacing, radii, sizes, borders or typography
Edit the constant in the matching Swift file. If the designer adds a new step (for example `spacing/6xl`), add it with the name given in its SwiftUI column and reflect it in `TokenGallery.swift`.

### Change a shadow
`Elevation.swift`. Figma expresses the spread as *blur*; in SwiftUI `radius ≈ blur / 2`. Colors `black/alpha-8 · 12 · 16` = `.black.opacity(0.08 · 0.12 · 0.16)`.

| Level | Figma | SwiftUI |
|---|---|---|
| None | no shadow | `.elevation(.none)` |
| Card | 0 1 3 · black/alpha-8 | `shadow(0.08, radius 1.5, y 1)` |
| Sheet | 0 −2 12 · black/alpha-12 | `shadow(0.12, radius 6, y −2)` |
| Floating | 0 4 16 · alpha-16 + 0 1 3 · alpha-8 | two chained `shadow`s |

### Add a new line (C3, …)
The base color of each line **is sent by the API** (`Line.colorHex`), so there are no `line/c1`, `line/c2` color sets. `LineTint` derives from the base color what Figma defines as line tokens:

| Figma token | Figma value (C1) | In the project |
|---|---|---|
| `color/line/c1` | #DA291C / #DA291C | `line.tint.base` (API) |
| `color/line/c1-text` | #FFFFFF | `line.tint.text` |

Figma's `color/line/c1-subtle` has no counterpart in code because no view uses it; if one needs it, derive it in `LineTint.swift` from the base color. If the designer adds `color/line/c3*` in Figma, the project needs nothing more than a check in `TokenGallery`. Badge sizes and radii: `Size.lineBadgeSm` (20) / `Size.lineBadge` (28) with `Radius.sm` / `Radius.md`.

## Semantic colors (quick reference)

Full values live in the color sets themselves. Groups and usage, according to Figma:

- **bg** · surfaces and layers: `primary → secondary → elevated`; `scrim` for modal backdrops (black 40 %).
- **text** · hierarchy: `primary` content, `secondary` supporting, `tertiary` metadata; `onBrand` on purple; `link`; `disabled`.
- **border** · `default` fields and cards, `subtle` separators, `strong`, `focus`.
- **brand** · `primary` (+ `hover`, `pressed`, `subtle`, `onPrimary`) and `cercanias` (brand red, reference only).
- **status** · `success · warning · error · info`, each with `-bg` and `-text`.
- **transit** · alias of `status` for train status: `onTime · delayed · cancelled` (+ `-bg`, `-text`). Always use these, not `status/*`, for train status.
- **interactive** · `tabbarActive/Inactive`, `separator`, `icon`, `iconSubtle`, `pressedOverlay` (8 % alpha), `favorite` (+ `-bg`, `-text`, `-pressed`).
- **brand/tint-fill** · `brandTintFill`, primary at 14 % (Dark: purple/400 at 18 %): background of the Bordered button.
- **fill** · `fillTertiary` (gray/500 at 12 %, same in Light and Dark): background of disabled controls.
- **glass** · `glassFillTinted` (tint of the Tinted glass) and `glassText` (text on Clear glass). `glass/fill` has no color set: it is Figma's approximation of glass, and in code `glassEffect(.regular)` replaces it.

`AccentColor` = `brand/primary` (#7A1E78 / Dark #B45FB0): system controls inherit it without an explicit tint.

## Primitives (reference only)

Primitives do not exist in the project as an API: views always use semantic colors. This table explains which primitive each semantic color comes from when the designer talks about "moving up to purple/400 in Dark".

| Ramp | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 |
|---|---|---|---|---|---|---|---|---|---|---|
| purple (primary, inspired by Renfe) | FBF2FA | F3DEF2 | E6BEE4 | D08FCD | B45FB0 | 983A95 | **7A1E78** | 631561 | 4C0F4A | 340A33 |
| red (Cercanías · C-1) | FDF3F2 | FBE0DD | F7C1BC | F09489 | E8655A | E23F30 | **DA291C** | B51F14 | 8C170F | 62100A |
| blue (C-2) | EEF5FC | D6E6F8 | ADCDF1 | 7AACE6 | 4A8BD8 | 206EC3 | **0057A8** | 004689 | 003567 | 002446 |
| gray (warm neutrals) | F9F9F8 | F2F2F0 | E5E5E2 | D2D2CE | A8A8A3 | 7C7C77 | **5C5C58** | 44443F | 2C2C29 | 1C1C1A |
| green (success · on time) | EDF9F0 | D3F0DC | A8E1BA | 74CC91 | 43B46B | 249A4F | **1B7F40** | 166534 | 124F2A | 0C3A1F |
| amber (warning · delay) | FFF8E6 | FFEDBF | FFDD85 | FFC94A | F7B31C | E39A00 | **C07F00** | 986300 | 714900 | 4D3100 |

Others: `white` FFFFFF · `black` 000000 · `gray/950` 121211 · `ios/systemRed` FF3B30 · `ios/systemGreen` 34C759 · `ios/systemOrange` FF9500 · `ios/systemBlue` 007AFF · `ios/systemYellow` FFCC00 · `black/alpha-8 · 16 · 40` · `white/alpha-16`.

## Typography

SF Pro throughout the app, Dynamic Type scale (Large size by default). System styles are used; only the composite ones have their own constant.

| Figma | Size/line height · weight | SwiftUI |
|---|---|---|
| Large Title | 34/41 · Bold | `.largeTitle` |
| Title 1 | 28/34 · Bold | `.title` |
| Title 2 | 22/28 · Bold | `.title2Emphasized` (the system `.title2` is Regular) |
| Title 3 | 20/25 · Semibold | `.title3Emphasized` (the system `.title3` is Regular) |
| Headline | 17/22 · Semibold | `.headline` |
| Body | 17/22 · Regular | `.body` |
| Body Emphasized | 17/22 · Semibold | `.bodyEmphasized` |
| Body Medium | 17/22 · Medium | `.bodyMedium` |
| Callout | 16/21 · Regular | `.callout` |
| Subheadline | 15/20 · Regular | `.subheadline` |
| Subheadline Emphasized | 15/20 · Semibold | `.subheadlineEmphasized` |
| Footnote | 13/18 · Regular | `.footnote` |
| Caption 1 | 12/16 · Regular | `.caption` |
| Caption 1 Emphasized | 12/16 · Semibold · tracking 0.6 | `.captionEmphasized` (+ `.tracking(Tracking.wide)` on uppercase labels) |
| Caption 2 | 11/13 · Regular | `.caption2` |
| Time/Departure | 17/22 · Semibold · tabular figures | `.timeDeparture` |
| Time/Departure Large | 22/28 · Bold · tabular figures | `.timeDepartureLarge` |
| Time/Departure Hero | 34/41 · Bold · tabular figures | `.timeDepartureHero` |

Figma rules: times always with `Time/Departure`; Large Title in large navigation and Title 2 for station names in cards; section labels in uppercase `Caption 1 Emphasized` with `textSecondary`; never go below Caption 2; hierarchy within a line through weight, not color.

## Spacing, radii, sizes

- 4 pt base scale: `spacing/0 2xs xs sm md lg xl 2xl 3xl 4xl 5xl` = 0 2 4 8 12 16 20 24 32 40 48.
- `layout/margin` 16 (screen side margin) · `layout/gutter` 12 (between cards).
- Continuous radii: `sm` 6 small badges · `md` 10 large badges and cells · `lg` 14 cards · `xl` 20 bottom sheets · `full` buttons, chips, search and Liquid Glass controls (capsule).
- Sizes: `touch-min` 44 · `icon-sm/md/lg` 16/24/32 · `line-badge` 28 (`line-badge-sm` 20, from the LineBadge component) · `chip` 24 (StatusChip) · `button-sm/md/lg` 28/34/50 · `glass-control` 48 (`glass-control-lg` 62) · `navbar` 44 · `tabbar` 49.
- Borders: `hairline` 0.5 list separators · `thin` 1 fields and cards · `thick` 2 focus.

## Usage rules (Figma)

- Red only for the C-1 badge, `brand/cercanias` and errors. Never as the primary color.
- Primary purple for main buttons, the active tab, links and focus.
- Train status with `transit/*`, always accompanied by text.
- Lists and cells without shadow (`Elevation/None`), separated with a hairline `interactiveSeparator`; cards on `bgSecondary` with `Elevation/Card`; if the card sits on `bgPrimary`, no shadow and a `bgSecondary` fill; bottom sheet = `Elevation/Sheet` + `Radius.xl` at the top + `bgElevated`; floating elements = `Elevation/Floating`. Never two levels on the same element, and never a shadow on text or icons.

## Incidents

Figma's `Severity` property (Info · Warning · Critical · Resolved) is a single type in the project, `IncidentSeverity`, shared by `SeverityBadge`, `AlertBanner` and `IncidentCard`. It provides the SF Symbol and the three tokens of each severity:

| Severity | Symbol | `tint` (icon) | `background` | `foreground` (text) | `label` |
|---|---|---|---|---|---|
| `.info` | `info.circle.fill` | `statusInfo` | `statusInfoBg` | `statusInfoText` | Aviso |
| `.warning` | `exclamationmark.triangle.fill` | `statusWarning` | `statusWarningBg` | `statusWarningText` | Retrasos |
| `.critical` | `exclamationmark.circle.fill` | `statusError` | `statusErrorBg` | `statusErrorText` | Interrumpido |
| `.resolved` | `checkmark.circle.fill` | `statusSuccess` | `statusSuccessBg` | `statusSuccessText` | Resuelto |

- The icon always uses `tint` and the text `foreground`; they are never mixed.
- `label` is the default short label: `SeverityBadge(.warning)` and `IncidentCard` use it without it being passed. `label:` replaces it with a custom label, and VoiceOver reads that label, the same one that is shown. `IncidentCard(_:label:…)` passes it on to the badge.
- Affected lines are passed as `[LineMark]` (`LineMark("C-1", color:)`), the same type `StationRow` uses. The color is sent by the API (`Line.colorHex`), never a hand-written hex.
- `AlertBanner` derives its interaction from the closures: `onTap` draws the chevron and makes the banner tappable, `onDismiss` draws the X (with a 44 pt touch area). There are no `Show chevron` / `Show close` props.
- `IncidentCard` takes the action as content (`IncidentCard(...) { Button("Ver detalles") {} }`) and applies `.rail(.borderless)` at `.small` to it itself.

## Service alerts

The Home bell opens `ServiceAlertsSheet`, a *Large* sheet titled «Notificaciones» with the system close button (`Button(role: .close)`). Mockups: in Spanish (`389:4606`) and for other languages (`207:11115`).

- **Container and content.** `ServiceAlertsSheet` reads `@Query` (`ServiceAlert`, `ServiceAlertFeed`, `Line` and `TransitNetwork`), polls `liveFeeds.poll(.alerts)` while the sheet is open and the app is in the foreground, and handles translation. `ServiceAlertsList` only draws a `ServiceAlertsPhase` (`loading`, `unavailable`, `empty`, `content`). The phase, the items (`ServiceAlertItemBuilder`), the time (`AlertTimestamp`) and the translation (`AlertTranslation`) are pure logic in `View/Presentation/`.
- **The API sends no title.** The card title comes from the kind, and Renfe's `text` goes in full as the description:

  | `kind` | Severity | Badge | Title |
  |---|---|---|---|
  | `notice` | `.warning` | Aviso | Aviso en la red |
  | `info`, `other` | `.info` | Info | Información de la red |
- **Time.** Under 1 min, «Ahora»; under 24 h, Foundation's relative format («Hace 12 min», «Hace 3 h»); after that, «Desde 21/09», with «/2025» if it is from another year. Day and month follow the order of the device's first preferred language (`Locale.preferredLanguages[0]`, because the app only has `es.lproj`), always with two digits, and in the network time zone. CLDR Spanish gives «24/9» with no year; that is why the pattern comes from the locale's template and is forced to two digits (`AlertTimestamp.twoDigitPattern`). It is recomputed every minute with `TimelineView(.everyMinute)`.
- **Other languages.** Renfe only publishes in Spanish and the interface stays in Spanish. If the first preferred language is not Spanish and Translation supports the es→language pair (`AlertTranslationSupport.resolve()`), an `AlertBanner(.info)` with no chevron or close button appears and, on each card, «Traducir» (`sparkles`) in `.rail(.borderless)` `.small`. Tapping it switches to «Traduciendo…» (disabled) and then to «Ver original» (`arrow.uturn.backward`), with the translated text in the description. The title and the badge are not translated, because they are interface text.
- **Translation.** Done with `.translationTask(configuration)`. Each run translates all the missing active alerts in one go, with `clientIdentifier` = `ServiceAlert.id`, and stores each translation next to its source text: if Renfe edits the alert, the translation is no longer valid. If it fails (in the simulator, Translation reports `unsupported`), the card falls back to the original. The session is never stored, and the file uses `@preconcurrency import Translation` because `TranslationSession` is not `Sendable`.
- **`bgSecondary` background**, not the white of Figma's sheet *template*: the cards use `Elevation/Card`, and the rule puts them on `bgSecondary`.
- Line badges show the API id («C1») with the API color, as in the rest of the app.

## Buttons

The two Figma button components are `ButtonStyle`s on a plain `Button`. Figma properties translate like this:

| Figma | SwiftUI |
|---|---|
| `Style` | style variant: `.buttonStyle(.rail(.prominent / .bordered / .borderless))`, `.railGlass(.clear / .tinted)` |
| `Size` | `.controlSize(_:)`: Button `.small` 28 · `.regular` 34 · `.large` 50; GlassButton `.small` 34 · `.regular` 48 |
| `State = Pressed` | automatic (`configuration.isPressed`; on glass, `glassEffect(….interactive())`) |
| `State = Disabled` | `.disabled(true)` |
| `Label` / `Show icon` / `Icon` | the button's label: `Button("Ver horarios") {}` or `Button("Ver horarios", systemImage: "clock") {}` |

- Heights grow with Dynamic Type (`@ScaledMetric`). Button and GlassButton extend the touch area to `Size.touchMin` (44).
- Toolbars need no style: iOS 26 already applies glass to `.toolbar` buttons.

## Illustrations

- They go in `Assets.xcassets/Illustrations/` as an imageset with an SVG and *Preserve Vector Data* (`preserves-vector-representation`). The folder has no *Provides Namespace*, same as `Colors/`.
- They don't use *Render As Template* and aren't turned into SF Symbols: they are multicolor and the color is part of the drawing.
- The SVG is normalized before adding it. `width` and `height` become numeric, equal to the `viewBox`, and CSS styles (`style="fill:…"`) become attributes (`fill="…"`). CoreSVG interprets them better and the drawing doesn't change.
- Each illustration has an atom that wraps it and hides it from VoiceOver. The caller decides the height: `TrainIllustration().frame(height: 53)`.
- Pending design: the train is light in dark mode too and stands out a lot on a dark `bgPrimary`. A dark version would be added as the *Dark* appearance of the same imageset.
- **Logo (`RailLogo`).** Figma exports it with a masked 508×508 PNG as background, so the project's SVG is a composition: a 44×44 tile with radius 11 and that PNG's near-white gradient (`#FCFCFC` → `#EFEFEF` diagonally), plus the glyph from `AppIcon.icon/Assets/Logo tren app.svg`, scaled and placed where Figma puts it. It is the same in light and dark mode, as in the mockup.
- **Empty states** (`EmptyStateIllustration(.noFavorites / .noResults)`). `PosteFavoritos` and `SenalSinResultados` are 3x PNGs with a transparent background, cropped from the sprite Figma uses as an image fill (`464:8639` and `458:8230`); they work the same in light and dark mode. The sign is cropped with 38 pt of empty space on the right, the mockup's `pr-[38px]`, so the post ends up centered. The design height is in `Kind.height` (196 and 164). `IllustratedMessage` draws them.
- **Photos.** They go in `Assets.xcassets/Photos/` (no *Provides Namespace*) as JPEG. `HomeHero` is registered at 2x (786×442 px = 393×221 pt) and `HomeHeroImage` draws it with `scaledToFill`, cropped to whatever frame the caller chooses. Pending design: it will look soft on iPad and Pro Max; a higher-resolution version is needed.

## Home

`HomeView(path:onShowMap:)` composes `NextTrainsSection` and `FavoriteStationsSection` inside `NavigationStack(path: [AppRoute])` > `ScrollView`, on `bgSecondary`. Mockups: with favorites (`2:54`) and without favorites (`220:3329`).

- **Full-bleed photo** (`HomeHeroImage`). It goes in the content's `.background(alignment: .top)`, with height `topInset + 80 + 76` and offset by `-topInset`. That way it covers the status bar and the navigation bar and ends 76 pt inside the next trains card, which starts at `topInset + 80`: on an iPhone 16 Pro, 262 and 186, as in Figma. `topInset` is `ScrollGeometry.contentInsets.top`. When pulled down it stretches with `.visualEffect` (scale anchored at the bottom based on `frame(in: .global).minY`; with `.scrollView` it doesn't grow). Figma's *Blur* layer (`60:3460`) is the system scroll edge effect: it is not imitated.
- **Visible height** (`.fitsScrollViewport()`, in `ViewportFit.swift`). The content goes inside a single-child `Layout` that **proposes** the visible height to it but reports the **natural** height it returns. That way Home takes exactly one screen when it fits (no scrolling) and, when not even the minimum of 3 favorites fits (short window on iPad, iPhone in landscape, accessibility sizes), the content grows and the `ScrollView` scrolls again. Bounding it with a bare `.containerRelativeFrame(.vertical)` doesn't work: it always reports the container's height, so the overflow was clipped and unreachable. The modifier measures the visible height itself with a `Color.clear.containerRelativeFrame(.vertical)` probe in the `background` (it already subtracts the navigation bar and the tab bar, and being in a `background` it doesn't affect layout); `ScrollGeometry.containerSize.height` gives the same number. Only `contentInsets.top` is read from `ScrollGeometry`, for the photo; never `contentOffset`, to avoid recomputing on every frame.
- **Top bar.** On the left, a 44 pt `RailLogo` with `.sharedBackgroundVisibility(.hidden)` (no glass); VoiceOver reads it as the «Inicio» header, because inside the bar the image ignores `accessibilityHidden` and was read as «RailLogo». On the right, a `ToolbarItemGroup` with «Notificaciones» (`bell.fill`), which opens `ServiceAlertsSheet` in a sheet (see *Service alerts*). It has no style: iOS 26 draws it in a glass capsule. There is no «Ajustes» button until there is a settings screen. The «Inicio» title is declared with `.navigationTitle` (the back button uses it) and hidden with `.toolbarTitleDisplayMode(.inline)` plus `.toolbar(removing: .title)`; without the inline mode, the large title still shows.
- **Width.** The content is centered with a maximum of 640 pt (iPad, iPhone in landscape); the photo stays full-bleed.
- **Navigation** through `AppRoute`, whose destinations are registered with `.appRouteDestinations()` (shared with Stations): `.favorites` opens `FavoriteStationsView` (see *Favorites*) and `.station(id:)` opens `StationDestination`, which looks up the station with `@Query` and shows «Estación no disponible» if a reimport deleted it.
- **«Añade una estación»**, in the favorites empty state, opens `StationPickerSheet` from `FavoriteStationsSection`, like the «+» in Favorites.
- **Stars.** Wherever the user marks favorites (rows in «Todas las estaciones» and the station detail bar), `Toggle(isOn: favoritesModel.binding(for:isFavorite:))` with `.toggleStyle(.favorite)` is used. Inside a row with a `NavigationLink`, the style's `.plain` button is enough for a tap on the star not to navigate.

## Favorite stations

`FavoriteStationsContainer(items, onAction:)` reads no data: it draws `[StationRowItem]` and reports through a `FavoriteStationsAction` (`.open(id)`, `.showAll`, `.remove(id)`, `.addStation`). `FavoriteStationsSection` connects it to `@Query` (`FavoriteStation.order` and `Station`), the location from `LocationViewModel`, and `FavoritesViewModel`.

- **Pieces.** A `CardSectionHeader("Estaciones favoritas")` header without an icon; each favorite is a `FavoriteStationCard` (a `StationRow` without separator, with `Spacing.sm` padding on `bgPrimary`; with `isFavorite:` it draws the star on the left, as in Favorites) inside a `Button(.plain)`; with no favorites, an `EmptyStateCard` with `star` in `interactiveFavorite` and the «Añade una estación» button in `.rail(.bordered)` `.regular`. 8 of spacing between header and content, 12 between cards, and 16 of padding around.
- **Adapters.** `StationRow(item, isFavorite:favoriteEdge:accessory:showsSeparator:)` and `FavoriteStationCard(item, isFavorite:)` turn a `StationRowItem` into a view; `LineMark(tag)` converts the API `colorHex` into a `Color`.
- **Row** (`StationRow`, component `54:161`). Name in `headline` and below it a metadata line: badges, subtitle (truncates) and distance on the right, 6 apart. At accessibility sizes the metadata stacks and nothing truncates. Minimum height 60 with 8 of vertical padding: the text is 44 tall and Figma lets it overflow onto its 12 padding. Accessory `.chevron` (default), `.checkmark` or `.hidden`; the star goes on the right, as in the component, or on the left with `favoriteEdge: .leading`.
- **Subtitle and distance** (`StationRowItemBuilder.item`): the subtitle is the connections («Metro · Autobús urbano») or nothing; the distance («1,2 km», `distanceLabel`) is separate and only shown when there is a location.
- **«Ver más»** (footnote, `brandPrimary`, `chevron.right`, spacing 4) only appears if there is at least one favorite. It is a `.borderless` `Button` with a 44 pt touch area, and VoiceOver reads «Ver todas las estaciones favoritas». Since it doesn't depend on the number of visible rows, the header always has the same height.
- **Capacity.** As many cards are shown as fit without scrolling, between 3 and 12 (`FavoritesCapacity.minimumVisible` and `.maximumVisible`). There is no arithmetic or measured geometry: a `ViewThatFits(in: .vertical)` receives as candidates the `VStack`s of `n`, `n−1`, … , 3 cards (`FavoritesCapacity.candidateCounts(total:)`), and the layout itself picks the first one that fits, with each card's real height (subtitle, two-line name, Dynamic Type). List changes animate with `.smooth`. Whoever draws the section has to give it two things:
  - `.fitsScrollViewport()` on the content of its `ScrollView`, so the height proposal is finite (see *Home*).
  - `.layoutPriority(-1)` on the section, so the rest of the content takes its natural height and the favorites get what is left. Without that priority the `VStack` splits the height between the two and compresses the card above (the `NextTrainsCard` text got truncated) instead of dropping a card.
- **Context menu.** Each card has «Quitar de favoritos» (`star.slash`, destructive) with the same text as `FavoriteToggleStyle.removeLabel`, and a preview shaped like the card.
- **Radius 12.** The cards and the empty state use radius 12, which is not a token (it sits between `Radius.md` 10 and `Radius.lg` 14). It stays a private constant until the designer decides whether it becomes a new token or snaps to an existing one.
- **No shadow**: the Figma frames have no effects.
- **Writes.** Removing, adding and reordering go through `FavoritesViewModel`, which calls `UserStationsRepository` synchronously on `mainContext`; reads are always `@Query`. That is why the card disappears in the same transaction as the gesture, with no `Task` or optimistic state. For the star, `favoritesModel.binding(for: id, isFavorite:)` returns a `Binding<Bool>` whose setter calls `setFavorite`.

## Favorites

`FavoriteStationsView` opens from «Ver más» on Home (`AppRoute.favorites`). It hides the tab bar with `.toolbarVisibility(.hidden, for: .tabBar)`; the tab bar comes back on returning to Home. Mockups: with favorites (`464:8277`) and empty (`464:8524`).

- **List.** `List(.plain)` on `bgSecondary`. Each favorite is a `FavoriteStationCard(item, isFavorite:)` inside a `NavigationLink(value: .station(id:))`, with a transparent row background, no separator, and insets of 6 top and bottom, which leaves 12 (`ScreenLayout.gutter`) between cards. The first card sits 24 below the bar, as in Figma.
- **Remove.** With the star (the style's `.plain` button keeps it from navigating) or by swiping: `swipeActions` with «Quitar de favoritos» (`star.slash`, destructive), which VoiceOver offers as an action.
- **Reorder.** `onMove` without edit mode: in iOS 26, long-pressing a card and dragging it is enough. That is why there is no `EditButton`, and the footer note explains it. With VoiceOver, each card offers the «Subir» and «Bajar» actions (`accessibilityActions`, only the ones that apply for its position), which call `FavoritesViewModel.move` and announce «Posición 2 de 5» with `AccessibilityNotification.Announcement`.
- **Footer note.** Figma says «…en Inicio y en el mapa», but the map doesn't use favorites: «y en el mapa» was removed and an explanation of how to reorder was added.
- **Add.** The «+» in the bar (`ToolbarItem(.primaryAction)` with `.buttonStyle(.glassProminent)`, which picks up `AccentColor`) and «Añade una estación» in the empty state (`.railGlass(.tinted)` `.small`) open `StationPickerSheet` with the favorites checked.
- **Empty.** `IllustratedMessage(…, illustration: .noFavorites)`, centered with `.fitsScrollViewport()` inside a `ScrollView` so it can scroll with large Dynamic Type. Title `bodyEmphasized`, text `footnote`.

## Station picker

`StationPickerSheet(selection:onPick:header:)` is the «Elegir estación» sheet (`389:5385`; no results, `389:5417`). Favorites and the Home empty state use it to add stations, and the next trains card uses it for the usual station, with «Usar mi ubicación» as `header` if one is already saved. On pick it calls `onPick(id)` and dismisses; the stations in `selection` get a `checkmark` and the `.isSelected` trait.

- **No location section.** The mockup's «Sin acceso a tu ubicación…» text and «Activar ubicación» chip are not implemented: the user's decision.
- **System search.** `.searchable` without a placement: in iOS 26 the field sits at the bottom and moves up with the keyboard, not under the title as in the mockup. Also the user's decision.
- **Filters.** «Todas» and one chip per line (API id) with `.filterChip(isSelected:)` inside a `GlassEffectContainer`, pinned under the bar with `safeAreaBar(edge: .top)`.
- **Sections** (`StationPickerSectionBuilder`, pure). One section per line, in line order; interchange stations appear under every line that serves them. The mockup's «Sugeridas» section was removed: the user's decision. With a line filter on, only that line is shown. Search filters by name (`localizedStandardContains`) or by line: «c2», «C-2» and «C2» are equivalent.
- **Headers.** Uppercase `captionEmphasized` with `Tracking.wide`, height 32 and 12 down to the first row, with `listSectionSpacing(Spacing.md)`.
- **Rows.** `StationRow(item, accessory: .checkmark / .hidden)`, without a chevron because picking doesn't navigate. In Figma the rows are 12 apart (a 72 pitch); here they are contiguous (60), like a system list, with the separator aligned to the text.
- **No results.** `IllustratedMessage(…, illustration: .noResults, prominence: .large)` in an `overlay` when search finds nothing: title `title3Emphasized` («Sin resultados para «Sevilla»») and text `subheadline`.

## Stations

`StationsView` is the Stations tab (after Map). It follows the same structure as `StationPickerSheet` and shares with it the molecules `LineFilterBar`, `StationSectionHeader` and `StationSearchNoResults`, plus `StationRow.listRowInsets`.

- **Structure.** `List(.plain)` with `LineFilterBar` pinned in `safeAreaBar(edge: .top)`, `.searchable` and an inline title. The per-line sections come from `StationPickerSectionBuilder`, as in the picker.
- **Nearby («Cerca de ti»).** Only when there is no search or filter. With a location, the three nearest stations (`LocationViewModel.nearest`). If permission hasn't been requested yet, a `CardMessage(.compact)` «Activa la ubicación» with «Permitir ubicación»; while locating, `CardMessage(.progress)`. With permission denied the section doesn't appear: the prompt to go to Settings is already on the Home card. If no station is within `NextTrainsCardStateBuilder.nearbyRadius` (10 km, the same radius as the Home card), the section shows «Estás lejos de Cercanías Málaga» (`map.fill` in `textTertiary`) and the line rows stop showing distance.
- **Rows.** `StationRow(item, isFavorite:, favoriteEdge: .leading)` with the star on the left, as in Favorites, and a chevron, inside a `NavigationLink(value: AppRoute.station(id:))` that opens `StationDestination`. The system indicator is hidden with `.navigationLinkIndicatorVisibility(.hidden)`.

## Station detail

`StationDetailView` opens from Home, Favorites, Stations and the map (through `StationDestination`). It hides the tab bar with `.toolbarVisibility(.hidden, for: .tabBar)`. It is a `ScrollView` on `bgSecondary` with `.cardSurface()` cards (padding `Spacing.md`, `bgPrimary`, `Radius.md`) separated by `ScreenLayout.gutter`, with a maximum width of 640.

- **Bar.** A `ToolbarItemGroup` with «Horarios» (`calendar`, opens `StationScheduleSheet`) and the star (`Toggle` with `.favorite`).
- **Header.** A 160 pt non-interactive map with a `tram.fill` `Marker` in `brandPrimary`, `StationHeader` with the distance (only if the station is within `NextTrainsCardStateBuilder.nearbyRadius`), one row per line (`LineBadge` + name) and «Iniciar ruta» (`.railGlass(.tinted)`), which opens Apple Maps with `Station.openDirections()`.
- **Next trains.** `CardSectionHeader` with «Ver horarios» and `DepartureList`, the same molecule the Home card draws, with 4 departures from `NextTrainsCardStateBuilder.departures`.
- **Getting there** («Cómo llegar», `StationTravelCard`). With travel times, a grid (`Grid`, 2 columns; 1 at accessibility sizes) of `TravelModeTile`s; each one opens Maps in its transport mode. While computing, the same grid `redacted`. If permission hasn't been requested yet, `CardMessage(.compact)` with «Permitir ubicación» and «Abrir en Mapas»; with permission denied or no fix, «Mapas te lleva hasta aquí» with «Abrir en Mapas»; if Maps returns nothing, «No hemos podido calcular los tiempos» with «Abrir en Mapas» and «Reintentar».
- **Accessibility and connections.** `StationFeatureRow`: the icon in a `brandPrimarySubtle` circle with the symbol in `brandPrimary` (`StationAccessibilitySymbol`, `StationConnection.symbolName`). With no accessibility data, a dimmed row (`fillTertiary` / `textTertiary`). The connections card only appears if there are any.

## Timetable

`StationScheduleSheet(station:)` is the «Horarios» sheet, with the station name as subtitle. The logic is pure in `StationTimetableBuilder`.

- **Pickers.** A single row in the top bar with two `Menu`s (`.railGlass(.clear)`, `.controlSize(.small)`) that contain an inline `Picker`: «Hoy ⌃⌄» (the days in the downloaded timetable, from today to `Timetable.endDay`; in the menu, «Hoy, jueves 25») and, if the station has more than one direction, «Todos los destinos» / «C1 · Fuengirola».
- **List.** `TimetableRow`: time in `timeDeparture`, `LineBadge`, destination with the train number below it and, if it departs in under `StationTimetableBuilder.countdownLimit` minutes, a «5 min» / «Ahora» capsule. The builder computes the status (`StationTimetableRow.Status`): `.departed` is drawn in `textTertiary` with a desaturated `LineBadge`; `.next` (every departure at the first upcoming time) sits on `brandPrimarySubtle` with a `brandPrimary` bar on the left and a filled capsule.
- **Earlier departures.** Today's departures that have already left (`StationTimetable.departed`) collapse behind a «Ver N salidas anteriores» row (plural in the catalog), so the list always starts at the next train. If no departures are left, they are shown expanded.
- **After midnight.** Trips with minutes ≥ 1440 belong to the same service day: they go at the end, under the «Madrugada del sábado 27» header.
- **Empty.** `CardMessage` «No hay trenes este día».

## Journeys

`JourneyPlannerView` is the Journeys tab («Trayectos», after Home). Its path is `[AppRoute]`, and `.journey(JourneyQuery)` opens `JourneyResultsView`.

- **Planner.** A `ScrollView` on `bgSecondary` with a `brandPrimarySubtle → bgSecondary` gradient at the top, the heading «¿A dónde quieres ir?» (`title2Emphasized`) and `JourneySearchCard` (`.cardSurface()` + `Elevation/Card`). The card only draws: two `JourneyStationField`s (`.buttonStyle(.stationField)`: `bgSecondary`, `Radius.lg`, height `Size.buttonLg`) that open `StationPickerSheet`, a swap button between them (`.rail(.bordered)`, icon only, turns 180° on every tap), `ServiceDayMenu` (`.rail(.bordered)`) with the downloaded days, and «Buscar trenes» (`.rail(.prominent)`, `.large`). With no choice yet, the origin falls back to the nearest station within `NextTrainsCardStateBuilder.nearbyRadius`.
- **Recent searches.** `RecentJourney` rows (the `@Model` lives in `SavedStation.swift` because the widget compiles `RailSchema` and that file; the policy is in `RecentJourneyPolicy.swift`) (origin and destination, `lastSearchedAt`) drawn with `RecentJourneyRow` in a `bgPrimary` card; context menu «Eliminar» and «Borrar» in the header. `RecentJourneyPolicy` keeps at most 15 and drops the ones not looked up for 30 days; `RecentJourneyItemBuilder` hides expired ones before the next write prunes them. `JourneyResultsView` records the pair each time it shows it, so opening a recent search moves it to the top.
- **Results.** Same skeleton as the timetable sheet: `ServiceDayMenu` in `safeAreaBar` (`.railGlass(.clear)`, `.small`), `JourneyRouteHeader` (origin and destination with a connector, swap button, line badges and «N trenes», plural in the catalog) and `JourneyRow`s: departure → arrival in `timeDepartureLarge`, duration, badges with «Directo» or «Con transbordo», for transfers a «Cambio en Victoria Kent · 6 min» line, and «Tren 23104 hacia Fuengirola». Statuses, the «Ver N salidas anteriores» row (`DepartedToggleRow`) and «Madrugada del…» work as in the timetable.
- **Logic.** `JourneyBuilder` is pure: direct trips on every line that calls at both stations (direction from the stop order), or, when no line does, one transfer at a shared station with at least `minimumTransferMinutes` (3) to change, keeping only journeys that no other one beats on both departure and arrival. `JourneyTimetableBuilder` turns them into rows.

## Next trains card

`NextTrainsCard(state, onAction:)` reads no data: it draws a `NextTrainsCardState` and reports what the user taps through a `NextTrainsCardAction`. `NextTrainsSection` connects it to location, SwiftData and MapKit through the pure functions of `NextTrainsCardStateBuilder`.

| State | Mockup (screen) | What it draws | Actions |
|---|---|---|---|
| `.station`, proximity `.walking` | `59:1450` (Home `2:54`) | Name, «A N minutos a pie», train, «Próximos trenes» and two `DepartureRow`s | none |
| `.station`, proximity `.distance` | `220:1589` (Modo sin conexión `220:1560`) | The same with «A 1,2 km» | none |
| `.station`, proximity `.saved` | no mockup | The same with «Tu estación habitual» and «Cambiar» in the section header | Cambiar → `.chooseStation` |
| `.station`, departures `.finished` | `220:3121` (Sin trenes hoy `220:3092`) | «No quedan trenes hoy» and tomorrow's first departure, with a compact `CardMessage` | none |
| `.station`, departures `.loading` | no mockup | Two rows with `.redacted(reason: .placeholder)` | none |
| `.permissionNeeded` | `220:1838` (Sin permiso `220:1809`) | Only `CardMessage`, with no header or train | Permitir ubicación · Elegir estación |
| `.permissionDenied` | `220:2074` (Ubicación denegada `220:2045`) | Only `CardMessage` | Elegir estación · Abrir Ajustes |
| `.locationUnavailable` | `220:2252` (No te ubicamos `220:2223`) | Only `CardMessage` | Reintentar · Elegir estación |
| `.noStationNearby` | `220:2430` (Fuera de zona `220:2401`) | Only `CardMessage`, with the nearest station in whole kilometers | Ver en el mapa · Elegir estación |
| `.locating` | no mockup | Progress indicator and «Buscando tu ubicación…» | Elegir estación |

- **Which station is shown** (`NextTrainsCardStateBuilder.target`), in this order:
  1. the one nearest to the device location, if it is 10 km away or less;
  2. the saved station (`SavedStation`, read with `@Query(SavedStation.current)` and written by `LocationViewModel` through `UserStationsRepository`), resolved by station id or, if that id no longer exists, by its coordinates;
  3. "no station nearby", if there is a location but no station within 10 km;
  4. the message that matches the location permission.
- **Proximity:** MapKit walking time if it is under an hour, rounded up and at least 1 minute. Without a walking time, the distance (`distanceLabel`). The saved station doesn't request a walking time.
- **Departures:** the next two today across all lines and directions, in the network time zone. The line identifier is drawn exactly as it comes from the API. With no more departures today, tomorrow's first one is shown if tomorrow falls within the downloaded timetable.
- **Plural:** «A 1 minuto a pie» comes from a plural variation in `Localizable.xcstrings` (key `A %lld minutos a pie`). `inflect: true` doesn't work in this project.
- **Shadow:** the card sits on `bgSecondary` without a shadow, because the mockup's shadow is disabled. It is an exception to the general rule of cards with `Elevation/Card`.
- **«Cambiar» goes in the section header**, not next to the name, because the train takes the top-right corner.
- **«Próximos trenes · programados» header:** `CardSectionHeader(detail:)` supports it, but it only appears in the *Modo sin conexión* mockup. The app doesn't detect being offline yet, so the card doesn't use it.
- **GlassButton inside the card:** used because the mockups draw it that way, even though the component's documentation advises against it on opaque cards.

## Map

`MapScreen` is the Map tab: `TransitMap` with `LineFilterBar` on top and, at the bottom, the nearby stations carousel (`NearbyStations`), the controls (`MapControls`) and the station sheet (`StationSheet`). There is no Figma mockup.

- **Nearby card.** `NearbyStationCard` loads the station's `nextTrains` inside a `TimelineView(.everyMinute)` and `NearbyStationCardContent` only draws: name (`headline`, one line), line badges, `figure.roll` if the station is accessible and the distance on the right, then the next train of up to two destinations (one per destination, soonest first, from the pure `NearbyDeparturesBuilder`). Each row is an arrow in the line color, the destination and the wait («Ahora», «4 min», or the clock time from 60 min on). When the realtime feed has the same train with a delay, the wait includes it and a «+3 min» in `transitDelayedText` sits next to it. The live train also filters the timetable: `NearbyDeparturesBuilder.liveTrains(from:lines:fetchedAt:)` works out the stations it has already left from `stopID`/`nextStopID`, its status and the line order, and a departure at one of those stations is skipped even if the delay would still put it in the future; readings older than `TrainTrack.maximumAge` are ignored, like on the map. There is no «Puntual» chip, since without live data we don't know the train is on time. Two hidden rows reserve the height, so every card is the same size while loading, with one destination or with «No quedan trenes hoy».
- **Controls.** One glass capsule (`glassEffect(.regular.interactive(), in: .capsule)`) with two icon buttons of `Size.glassControl`, in `.title3` and `glassText`: «Mi ubicación» and «Ver toda la red». It always rests `Spacing.sm` above whatever takes the bottom (the carousel or the sheet), so it rides on the sheet as in the reference project. `glassEffectUnion` over `.buttonStyle(.glass)` was tried and drew both icons over a single circle.
- **Own sheet.** It is not a system `.sheet`: it is drawn in the tab, floating `Spacing.sm` above the tab bar, with `glassEffect(.regular, in: .rect(cornerRadius: Radius.xl))`, the same radius as the card. It has a single height and no detents: header + content, between the card + `Spacing.xxxxl` and 60 % of the height. It opens at that height from a card, a pin or «Ver en el mapa», and it can't go higher or rest lower. If the content doesn't fit, the body scrolls with the header pinned in `safeAreaBar(edge: .top)`.
- **Header.** A decorative grabber (36×5, `textTertiary`, hidden from VoiceOver); title `title2Emphasized`, the `.favorite` star and a close `Button(role: .close)` in `.glass`, a circle and `.large`. VoiceOver closes it with the escape gesture.
- **Gestures.** The sheet is dragged with `onVerticalDrag` (a `DragGesture` in `.global`, locked to the vertical axis). While dragging down, the sheet shrinks toward its card (or slides down if it came from the bottom). On release it closes if the projected translation passes 25 % of its height (`MapSheetLayout.shouldClose`); otherwise it goes back up. The carousel opens the centered card when you pull up on it: it sits inside a vertical `ScrollView` that always bounces, read with `onScrollGeometryChange`. A drag gesture on the cards is not used, because it blocks horizontal scrolling.
- **Card ↔ sheet.** If the station is in the carousel, the card grows into the sheet and, on closing, shrinks back into it: the rect comes from an `anchorPreference`, and the content crossfades (`NearbyStationCardContent` → the sheet). If it is not in the carousel, the sheet comes up from the bottom. With *Reduce Motion* it only fades.
- **Full station.** «Ver estación completa» pushes `StationDestination` onto the tab's `NavigationStack`; on return the sheet is still open.

## Live trains

The Map tab draws the trains from the `/realtime` feed on their lines. There is no Figma mockup: the marker is provisional.

- **Container and content.** `MapScreen` reads `@Query` (`LiveTrain`, `RealtimeFeed`), polls `liveFeeds.poll(.realtime)` while the tab is on screen and the app is in the foreground, and builds the `TrainTrack`s with `TrainTrackBuilder`, pure logic in `View/Presentation/TrainTrack.swift`. `TransitMap` only draws and animates.
- **Direction.** The feed has no heading. `SwiftDataLiveFeedRepository` takes the direction from the timetable `Trip` with the same `lineID` and train number and stores it in `LiveTrain.directionRaw`; if there is no `Trip`, `TrainTrackBuilder` infers it from the `sequence` of `stopID` → `nextStopID`. It is not inferred from the terminal stations: a train `approaching` the last station may be arriving or waiting to depart in the opposite direction. The arrow follows the route's bearing (`PolylinePath.bearing`) minus the camera heading.
- **The feed is not continuous.** Each train repeats `at` → `left` → `approaching` at every station, and in `approaching` it arrives with `stop == next` and no `lat/lon`. On top of that, the API drops trains for one or more samples. That is why `mergeRealtime` doesn't replace: `RealtimeMerge` (pure, in `Sync/`) keeps the direction and the last known position (`positionSampledAt`) while the train stays on the same segment, and holds on for up to 120 s to a missing train that hasn't finished its trip (`nextStopID != nil`). Without a previous position, an `approaching` train starts 400 m before the next station.
- **Movement between refreshes.** From `positionSampledAt` (or `sampledAt`), and at most until 90 s after the last sample, the train advances along the route toward the next station at `TrainTrack.nominalSpeed` (50 km/h), without passing it; with `status == .at` it doesn't move. `TransitMap` updates the clock every second with `withAnimation(.linear(duration: 1))`, or every 5 s without animation when *Reduce Motion* is on. When a new sample arrives, the train jumps to its real position.
- **Age.** After 90 s without a new sample the marker dims; after 5 min it disappears.
- **Marker.** `TrainMarker`: a scalable `Size.iconMd` circle in the line color (`LineTint`), `tram.fill` in `tint.text`, a `Border.thick` border in the background color, `Elevation/Floating`, and a triangle outlined in the background color so it stands out on top of the line itself. VoiceOver reads «Tren 23501 de la línea C1 hacia Fuengirola, con 3 minutos de retraso»; the delay is a plural variation in `Localizable.xcstrings` (key `con %lld minutos de retraso`).
