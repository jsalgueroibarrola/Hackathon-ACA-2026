# Previous decisions and findings

What was already discovered while implementing `LineBadge`, `StatusChip` and the buttons. Read it before repeating a measurement or doubting a pattern.

## Contents

1. Measured system controls
2. Existing components as patterns
3. Figma quirks
4. Tooling quirks

## 1. Measured system controls

iOS 27 SDK, iPhone, default text size, single-line label. If the SDK changes, measure again with `scripts/simulator_preview.sh`.

| Control | `.small` | `.regular` | `.large` / `.extraLarge` | Look |
|---|---|---|---|---|
| `.borderedProminent` + `.buttonBorderShape(.capsule)` | 28 | 34 | 50 | `AccentColor` background, white text |
| `.bordered` + capsule | 28 | 34 | 50 | **Gray** background, tinted text |
| `.borderless` | 18 | 20 | 20 | No background or padding |
| `.glass` / `.glassProminent` | 28 | 34 | 50 | Real glass; regular text weight |
| `.glass` + `.buttonBorderShape(.circle)` (icon only) | 28 | 34 | 50 | Circle |

Conclusion reached: the Figma kit (Button 28/34/50) matches the system in geometry, but not in colors (Bordered with the brand color at 14 %, pressed with `brandPrimaryPressed`/`brandPrimarySubtle`), nor in the capsule Borderless, nor in the glass sizes (48/62). That's why the three buttons are custom `ButtonStyle`s that read `controlSize`.

## 2. Existing components as patterns

Before writing a new one, open the most similar one and copy its structure.

| File | What it demonstrates |
|---|---|
| `View/Components/LineBadge.swift` | A `View` atom that takes a `Color` (API data) and a `String` drawn with `Text(verbatim:)`. A size enum named `Scale` so it doesn't clash with `Size`. `@ScaledMetric` with a variable `relativeTo`, initialized in a custom `init` (`_height = ScaledMetric(wrappedValue:relativeTo:)`). `.fixedSize()` so it doesn't truncate. |
| `View/Components/StatusChip.swift` | A `View` atom with a state enum whose properties (`dotColor`, `textColor`, `backgroundColor`) are `switch`es to tokens. Interface text as `LocalizedStringResource`. `@ScaledMetric(relativeTo: .caption)` in short form. Decorative element with `.accessibilityHidden(true)`. Signature copied from the Figma documentation: `StatusChip(.delayed, label: "+5 min")`. |
| `View/Components/Button/RailButtonStyle.swift` | A `ButtonStyle` with `@Environment(\.controlSize)`, `@Environment(\.isEnabled)` and `configuration.isPressed`. Colors via `switch` over `(isEnabled, variant, isPressed)` tuples. A single `@ScaledMetric var scale = 1` multiplied by the height token. Touch area extended with `.contentShape(.rect.inset(by: -touchInset))`. Static access `.buttonStyle(.rail(.prominent))`. |
| `View/Components/Button/RailGlassButtonStyle.swift` | Real glass with `.glassEffect(.regular.tint(token).interactive(), in: .capsule)`. Glass and color logic in an extension of the `Variant` enum, shared with the icon button. |
| `View/Components/Button/RailGlassIconButtonStyle.swift` | Icon-only button: `.labelStyle(.iconOnly)` on a `Label`, so VoiceOver still reads the title. |
| `View/Components/Atoms/TrainIllustration.swift` | Multicolor illustration: an imageset with preserved vector data and no template rendering, not a symbolset. The atom hides it from VoiceOver and leaves the height to the caller. |
| `View/Components/Molecules/CardMessage.swift` | A message block with icon, title, text and up to two actions (`CardMessage.Action`). Metrics per `Prominence` in an extension with a `switch`. Icon size with `ScaledMetric(wrappedValue:relativeTo:)` in the `init`. |
| `View/Components/Organisms/NextTrainsCard.swift` | An organism with no data: it takes a state enum and returns actions through a single `onAction` closure. The logic that decides the state lives outside, in pure functions (`NextTrainsCardStateBuilder`). |
| `View/Components/Molecules/IllustratedMessage.swift` | An empty state with illustration, title, text and optional actions (an `init` without actions using `where Actions == EmptyView`). Typography per `Prominence` in a `fileprivate` extension. |
| `View/StationPickerSheet.swift` | A generic sheet (`<Header: View>`) with `List(.plain)`, the system `.searchable`, chips in `safeAreaBar(edge: .top)` and sections produced by a pure builder. A generic type can't hold `static let`: use `static var { }`. |

## 3. Figma quirks

- **`get_variable_defs` only returns one mode** (light). The semantic colors table on the *DS · Color* page doesn't list the tokens added later (`fill/*`, `glass/*`, `brand/tint-fill`). For dark mode use `scripts/read_figma_component.js`.
- **The variables' `codeSyntax.iOS` is a hint, not the truth.** It matches for colors (`Color.brandTintFill`) and sizes (`Size.buttonLg`). It doesn't match for: `Radius.full` → the project uses `.capsule` or `.circle`; `Font.TextStyle.caption.size` and the like → system text styles; `Font.Tracking.wide` → `Tracking.wide`; `Font.family.*` and `Font.Weight.*` → ignored, the text style covers them.
- **The `var(--token, value)` fallback** in the React output of `get_design_context` is the Light value.
- **Fixed widths that don't fit.** `LineBadge` has `w-[40px]` in every variant, but in Large the text plus the padding (12+12) doesn't fit in 40 and Figma eats the padding. It was solved with a `minWidth` of 40 plus the token padding (Large measures ~51), and the user was told.
- **Icon colors inside instances.** In GlassIconButton Tinted, Figma leaves the icon in `text/primary` (dark on purple). `brandOnPrimary` was used instead, same as the GlassButton Tinted text, and the user was told.
- **`brandOnPrimary` is dark in dark mode** (#121211), because there `brandPrimary` is a light purple (#B45FB0). It's intentional; don't "fix" it to white.
- **"Clear" in Figma is `Glass.regular`**, not `Glass.clear`. `glass/fill` (white at 65 %) and the `0 8 40` shadow of the *Glass/Regular* effect are Figma's approximation of glass: no tokens or shadows are created for them.
- **Figma states.** `Pressed` and `Disabled` are variants in Figma, but in code they come from `configuration.isPressed` and `.disabled(_:)`. They aren't exposed as parameters.
- **Documentation next to the component.** Each component lives in a section (`A3 StatusChip`, …) of the *CI · Átomos* page (`40:2`) with a `Doc/<Name>` frame that lists sizes, tokens, props, accessibility rules and sometimes the expected Swift signature. If the user asks for something else (for example, `LineBadge` takes a `Color` instead of `line:`), the user wins.
- **Screen mockups aren't components.** The home card only exists as `Card` frames on the *Mockups* page: no `Doc/` and no variants. Measure on the frames and discard hidden layers (`visible: false`), which are plentiful in the mockups.
- **The screen name explains the variant.** «Próximos trenes · programados» only makes sense once you see that its screen is called *Inicio - Modo sin conexión*. Walk up the parents to the screen frame before interpreting a variant.
- **Figma's fixed line height.** Figma fixes the line height of each style (Title 2 28, Headline 22, Subheadline 20, Footnote 18) and SwiftUI uses the natural one. Text blocks measure a few points less than in Figma: the station card 235.7 versus 236 and the permission card 258.7 versus 264. Don't compensate with hand-tuned margins.
- **Disabled effects.** A shadow with `visible: false` in Figma isn't implemented. The home card has one.
- **Illustrations as image fills.** Sometimes the node is a rectangle with a PNG sprite (`w-[323%] left-[-116%]`). Crop the PNG with `sips -c <height> <width> --cropOffset <y> <x>`: scale = PNG width ÷ (node width × percentage), and the offset comes from `left`/`top`. If the container adds padding to center the drawing (`pr-[38px]`), add that transparent margin to the crop.
- **Rows spaced by auto-layout.** In *Elegir estación* the list rows have `gap 12` and the separator stuck to the bottom, so it ends up off-center. In code the rows are contiguous, like a system list.
- **Content of mockups with a bar.** The `content` frame starts at y = 132 with `pt 8`: the first element sits 24 below the navigation bar, not 8.
- **Line colors.** Figma paints C-1 red and C-2 blue, but the API sends other colors. The API wins.

## 4. Tooling quirks

- **SourceKit reports false errors in new files** ("Cannot find 'Spacing' in scope", "Type 'Color' has no member 'bgPrimary'"). They come from indexing: the source of truth is `xcodebuild`.
- **The built-in simulator tools can fail** if Xcode isn't selected with `xcode-select`. `scripts/simulator_preview.sh` only uses `xcrun simctl`.
- **Taps can't be simulated** with `simctl`: the pressed state and the extended touch area can't be checked that way. If the Xcode MCP is connected, `DeviceInteractionSynthesize` can tap; if not, say so in the final report.
- **The Xcode MCP needs approval, including for `DocumentationSearch`.** Until it's approved, every tool answers "This agent isn't approved to use Xcode's tools yet". Call `XcodeOpenWorkspace` first with the absolute path of `Rail.xcodeproj`: Xcode shows the user the permission dialog. The approval lasts the whole session.
- **SVG illustrations.** The `sf-symbols-from-svg` skill turns silhouettes into symbolsets; a multicolor illustration goes in as an imageset. Normalize the SVG (numeric dimensions and `style` moved to attributes) and compare the original and the copy with `qlmanage -t` before building.
- **Verifying logic without a test target.** A `ZZHarness` that prints `CHECK <name> OK|FAIL`, followed by `grep CHECK <output>/console.log`. The harness only replaces `RootView`: it has the real `ModelContainer` and the environment's view models. `WAIT=45` gives it time to sync real data.
- **Localization.** `inflect: true` doesn't do agreement in Spanish in this project, and `xcodebuild` doesn't add new strings to `Localizable.xcstrings`. Plurals are added by hand as plural variations.
- **`DeviceInteractionSynthesize` commands.** Tap: `t x y`; long press: `t x y 1.5` (context menu). Swipe: `t x1 y1 f x2 y2 0.3`; with 1.5 s instead of 0.3 there's barely any momentum, and you have to take a new screenshot before tapping, because a tap during momentum lands on another row. Drag to reorder: `drag x1 y1 x2 y2 0.6 1.5` (hold, travel). Rotate: `orientation portrait` or `orientation landscapeLeft`. After reinstalling the app the session closes and you have to open another one.
- **`ScrollGeometry.containerSize` already subtracts the insets** (bars and `safeAreaInset`): on a Pro Max, `containerSize.height` 757 with `contentInsets` of 116 at the top and 83 at the bottom on a 956 screen. The visible height is `containerSize.height`; subtracting the insets again leaves 199 pt too few.
- **`List(.plain)` on iOS 26.** `onMove` allows reordering by long-pressing and dragging, with no edit mode or `EditButton`. Section headers come with a large top margin: adjust it with `.listSectionSpacing(_:)`, `.contentMargins(.top, 0, for: .scrollContent)` and `.padding(.bottom)` on the header itself, which accepts `.listRowInsets`.
- **Purple «+» button in the bar.** `ToolbarItem(placement: .primaryAction)` with `.buttonStyle(.glassProminent)` draws Figma's tinted circle with `AccentColor`; no custom style needed.
- **Built-in simulator tool.** Since 25/09/2026 it works (`attach`, `tap`, `swipe`, `touch_path`, `text`). Always pass `device` with the UDID: without it, the screenshot may come from another booted simulator. The screenshot sometimes arrives before the animation finishes; `sleep 1` and `xcrun simctl io <udid> screenshot` give a reliable image.
- **Permission and location in the simulator.** `xcrun simctl privacy <udid> grant|revoke|reset location <bundle>` and `xcrun simctl location <udid> set <lat>,<lon>` or `clear` cover every state without touching the screen. With the app open, `clear` doesn't erase the last known position: relaunch the app to see «No hemos podido ubicarte».
