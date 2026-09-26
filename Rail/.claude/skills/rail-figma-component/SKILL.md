---
name: rail-figma-component
description: Ports a Rail design-system component from Figma to SwiftUI (badges, chips, buttons, cells, atoms and molecules), with the project's tokens, dark mode, Dynamic Type, accessibility and verification in the simulator. Use it whenever a figma.com URL with a node-id shows up in this project, or the user asks "crea/genera este componente", "sigue lo de Figma", "implementa este átomo", "pásalo a SwiftUI", "haz el botón/badge/chip de Figma", or Figma tokens (colors, sizes, typography) need to be added to or synced with Assets.xcassets or DesignSystem/. Use it even if the user doesn't say "Figma" when they are talking about a design-system component.
---

# Figma component → SwiftUI in Rail

This skill captures how `LineBadge`, `StatusChip` and the three button styles were built, so every new component comes out the same way: faithful to Figma where Figma is right, idiomatic in SwiftUI, and actually verified, not just compiled.

It complements two generic skills that are worth loading:
- `figma:figma-swiftui` (and its `references/design-to-code.md`): general Figma-to-SwiftUI rules (text styles, SF Symbols, don't copy absolute positions).
- `figma:figma-use`: mandatory before calling `use_figma`.

The project rules are in `CLAUDE.md` (no comments in code, declarative programming, iOS 26 APIs, user-facing text in Spanish) and in `Rail/DesignSystem/DESIGN-TOKENS.md` (token names). This skill doesn't repeat them: follow them.

Before starting, read `references/decisions.md`: it has the measurements of the system controls, which existing component serves as the pattern for each case, and the known Figma pitfalls. It saves you from rediscovering them.

## Look things up when in doubt

Don't guess APIs. If you're unsure whether something exists, about its availability (iOS 26 versus 27, which requires `if #available(iOS 27, *)`), its behavior or what the HIG say, check the documentation:

1. **Xcode MCP** (`xcrun mcpbridge`). If there are `mcp__<server>__DocumentationSearch` tools in the session, use them: `DocumentationSearch(query:, frameworks: ["SwiftUI"])`. All its tools require the user to approve the agent: call `XcodeOpenWorkspace(path: "<absolute path>/Rail.xcodeproj")` first and warn the user that Xcode will ask them for permission. If the MCP isn't registered, suggest (don't do it yourself) `claude mcp add --transport stdio xcode -- xcrun mcpbridge`.
2. **SDK interface**, without needing the MCP:
   ```bash
   SDK=$(xcrun --show-sdk-path --sdk iphonesimulator)
   grep -n "func labelIconToTitleSpacing" "$SDK"/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/*.swiftinterface
   ```
   The `@available` lines above the declaration say which iOS version it exists from.
3. **Building** is the final proof that an API exists with that signature.

## 1. Read the component in Figma

From the URL `figma.com/design/<fileKey>/…?node-id=40-71` you get `fileKey` and `nodeId` (`40:71`).

1. `get_design_context` with `clientLanguages: "swift"` and `clientFrameworks: "swiftui"`. The React+Tailwind output is a structural reference, not code to copy. The valuable parts are the **component description** (usage rules), the text styles, the screenshot and the assets.
2. `scripts/read_figma_component.js` with `use_figma` (read-only): copy the file, put the id in `NODE_IDS` and run it. It returns:
   - the variants with their exact width and height;
   - the documentation section (id, page and the texts of the `Doc/<Name>` frame: sizes, tokens, props, accessibility and often the **expected Swift signature**);
   - every bound variable, with its **Light and Dark** value and its `codeSyntax.iOS`.

   It's needed because `get_variable_defs` only gives the light mode and Figma's semantic colors table doesn't include the new tokens.
3. SVG assets (dots, drawn icons) are downloaded with `curl` from the URLs in `get_design_context`. Look at their `fill` and map it to an existing token instead of copying the hex. SF Symbols come as `Image(systemName:)`: use the name as is.

If the user asks for something different from Figma ("recibe el color, olvídate de las líneas"), the user wins: implement what they ask for and mention the difference at the end.

## 2. Tokens

Check what exists before creating anything: `Rail/Assets.xcassets/Colors/<Group>/`, `Size.swift`, `Spacing.swift`, `Radius.swift`, `Typography.swift`.

- **Missing color**: create the color set with the `codeSyntax.iOS` name without `Color.`, and the Light and Dark values from the read script:
  ```bash
  python3 .claude/skills/rail-figma-component/scripts/add_colorset.py Brand brandTintFill 7A1E7824 B45FB02E
  ```
  The group folder comes from the second segment of the Figma name (`color/glass/text` → `Glass`). The script refuses to overwrite an existing color.
- **Missing size, spacing or typography**: add a constant named after the `codeSyntax.iOS` (`Size.buttonLg`, `Font.bodyMedium`). That name doesn't always work: the equivalence table is in `references/decisions.md` (for example, `radius/full` is `.capsule`).
- **Raw value with no Figma variable** (`px-[10px]`, `w-[40px]`): a private constant in the component, not a global token. A global token with no Figma variable couldn't be synced.
- **Figma approximations** (the white fill of `glass/fill`, the *Glass* effect's shadows): they don't become tokens. Real glass replaces them.
- Add every new token to `TokenGallery.swift` and to `DESIGN-TOKENS.md`.

## 3. Decide the component's shape

The shape depends on what the component is, not on how it's drawn in Figma:

| What it is | SwiftUI shape |
|---|---|
| Something you tap (button, icon button) | A `ButtonStyle` applied to a plain `Button`. Never a `View` that wraps a `Button`: you lose accessibility, states and toolbar integration. |
| A control with a system equivalent (toggle, segmented, picker, slider) | The system control with tokens (`.tint`) or, if the design departs from it, its style protocol (`ToggleStyle`, …). |
| A piece that only displays something (badge, chip, label, cell) | `struct … : View`. |

**Before writing a custom style, check whether the system one already matches.** For buttons it's measured in `references/decisions.md`. For any other control, measure it with `scripts/simulator_preview.sh` (step 5) and compare with Figma's measurements. If geometry and colors match, use the system one: you get animations, accessibility and future iOS versions for free. If not, a custom style.

## 4. Write the code

Where: `Rail/View/Components/`. If it's a family of components, in a folder (`Button/`). No file header and no comments.

How to carry over each Figma property:

| Figma property | In code |
|---|---|
| `Size` of a control | `@Environment(\.controlSize)`; the caller writes `.controlSize(.large)`. Map `.mini/.small`, `.regular` and `.large/.extraLarge` to the Figma sizes. |
| `Size` of a visual piece | A parameter with its own enum. Don't call it `Size`, because it shadows the `Size.*` tokens: use `Scale`, `Metrics` or similar. |
| `State = Pressed` | `configuration.isPressed`; on glass, `.interactive()`. |
| `State = Disabled` | `@Environment(\.isEnabled)`; the caller writes `.disabled(true)`. |
| `Label`, `Icon`, `Show icon` | The `Button`/`Label` label. If only the icon shows, `.labelStyle(.iconOnly)` with a title for VoiceOver. |
| Editable interface text | `LocalizedStringResource`. |
| Text that is data (line name) | A `String` drawn with `Text(verbatim:)`. |
| Color that comes from the API | A `Color` parameter. |
| Swift signature in the `Doc/` frame | Copy it, unless the user asks for a different one. |

Recurring patterns:

- **Per-state colors** with a `switch` over a tuple, as an expression: `switch (isEnabled, variant, isPressed) { case (false, _, _): .textDisabled … }`. It stays declarative and the compiler checks that no case is missing.
- **Dynamic Type.** Text uses system styles (`.caption`, `.headline`, `.captionEmphasized`), which already scale on their own. Fixed-size boxes scale with `@ScaledMetric`:
  - a single text style: `@ScaledMetric(relativeTo: .caption) private var height = Size.chip`;
  - a style that depends on a parameter: a custom `init` with `_height = ScaledMetric(wrappedValue:relativeTo:)`;
  - several sizes inside a `ButtonStyle`: `@ScaledMetric private var scale: CGFloat = 1` multiplied by the height token.
- **44 pt touch area** when the visual height is smaller: `.contentShape(.rect.inset(by: -max(0, (Size.touchMin - height) / 2)))`.
- **Shapes.** `.rect(cornerRadius: Radius.x, style: .continuous)`; `radius/full` is `.capsule` (or `.circle`).
- **Glass.** `.glassEffect(.regular[.tint(token)].interactive(), in: shape)`. No extra shadows or fills. Inside `.toolbar` no style is needed: iOS 26 already adds glass.
- **Accessibility.** Decorations get `.accessibilityHidden(true)`. Short pieces that must not truncate get `.fixedSize()`.
- **Reusable styles** with static access: `extension ButtonStyle where Self == RailButtonStyle { static func rail(_:) -> Self }`.

**Previews**, always in Spanish and with the background tokens (`.bgPrimary`, `.bgSecondary`):
- `"Variantes Figma"`: the same grid as the Figma component set, so they can be compared side by side.
- `"Modo oscuro"`: with `.preferredColorScheme(.dark)`.
- `"Dynamic Type"`: with `.dynamicTypeSize(.accessibility2)`.

Hex values are only allowed in previews, and only to simulate API colors (`Color(hex: "DA291C")`).

## 5. Verify

1. **Build**:
   ```bash
   xcodebuild -project Rail.xcodeproj -scheme Rail -destination 'generic/platform=iOS Simulator' build -quiet
   ```
   SourceKit errors in new files ("Cannot find 'Spacing' in scope") are false: what `xcodebuild` says is what counts.
2. **Look and measure.** Pick one option:
   - **Xcode MCP**, if available: `RenderPreview(sourceFilePath: "Rail/View/Components/<File>.swift", previewDefinitionIndexInFile: n)` renders each preview without touching the app.
   - **Simulator**: write a file in the scratchpad with a `struct ZZHarness: View` that shows the variants and tags whatever you want to measure with `.measure("name")`. Then:
     ```bash
     .claude/skills/rail-figma-component/scripts/simulator_preview.sh <harness.swift> <output-folder> [udid]
     ```
     It temporarily replaces `RootView()`, builds, installs, takes light and dark screenshots, prints the measurements and **always** restores `RailApp.swift`. Even so, check afterwards with `git status` that no `ZZ*.swift` files or changes to `RailApp.swift` are left behind.
3. **Compare** the measurements with the variants from step 1 (exact height; width when Figma fixes it) and the screenshots with Figma's. Check dark mode too: it's what slips through most often.
4. Whatever you can't check (pressed state, touch area without being able to tap), say so in the report; don't claim it as verified.

## 6. Document and wrap up

- `DESIGN-TOKENS.md`: a row in the pages table (`Componentes · A3 StatusChip | 44:66 | … (40:71) | path`), the new tokens in their list and, if the component introduces a new way of using it, a short section like *Buttons*.
- `TokenGallery.swift`: the new tokens.
- `CLAUDE.md`: only if there's a new rule every agent must always know (for example, "buttons use `.buttonStyle(.rail…)`"). One line.

**Final report to the user**, in Spanish and brief:
1. How to use it: 1 to 3 lines of code.
2. Figma → code table: tokens and properties.
3. What was verified and how: measurements, screenshots, dark mode, Dynamic Type.
4. Differences from Figma and why (design errors detected, widths that don't add up, user decisions), flagging what should be confirmed with the designer.
