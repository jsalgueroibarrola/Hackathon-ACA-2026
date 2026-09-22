# Design tokens · sincronización con Figma

Fuente de verdad: archivo de Figma **Diseño UX/UI ACA hackathon** (`WFoeo57elVOwmgKto1iwfq`).
Los tokens de este directorio y los color sets de `Assets.xcassets/Colors` se mantienen **a mano** a partir de esas páginas. Cuando la diseñadora cambie algo, se edita aquí; no hay script ni JSON intermedio.

| Página Figma | node-id | Qué define | Dónde vive en el proyecto |
|---|---|---|---|
| DS · Color | `19:307` | Primitivas (`29:2`), semánticos Light/Dark (`30:2`, grid `30:8`), reglas de uso (`32:2`) | `Assets.xcassets/Colors/*` y `AccentColor` |
| DS · Tipografía | `19:308` | Escala SF Pro + equivalente SwiftUI (`22:6`) | `Typography.swift` |
| DS · Espaciado y radios | `19:309` | `spacing/*`, `radius/*`, `size/*`, `border/*`, `layout/*` (`23:2`) | `Spacing.swift`, `Radius.swift`, `Size.swift`, `Border.swift` |
| DS · Elevación | `19:310` | Niveles de sombra (`23:152`) | `Elevation.swift` |
| DS · Líneas | `19:311` | Badges de línea, chips de estado, cómo añadir una línea (`24:2`) | `LineTint.swift` |
| Componentes · A2 LineBadge | `44:36` | Átomo badge de línea (`40:61`) | `View/Components/Atoms/LineBadge.swift` |
| Componentes · A3 StatusChip | `44:66` | Átomo estado del tren (`40:71`) | `View/Components/Atoms/StatusChip.swift` |
| Componentes · A4 Button | `44:96` | Botón Prominent / Bordered / Borderless (`48:314`) | `View/Components/Atoms/Button/RailButtonStyle.swift` |
| Componentes · A6 GlassButton | `51:18` | Botón Liquid Glass Clear / Tinted (`49:57`) | `View/Components/Atoms/Button/RailGlassButtonStyle.swift` |
| Componentes · A7 GlassIconButton | `51:48` | Botón de icono Liquid Glass (`49:76`) | `View/Components/Atoms/Button/RailGlassIconButtonStyle.swift` |
| Componentes · A8 SeverityBadge | `102:22` | Átomo gravedad de incidencia (`102:78`) | `View/Components/Atoms/SeverityBadge.swift` |
| Componentes · A9 FavoriteButton | `122:26` | Átomo estrella de favorito (`122:78`) | `View/Components/Atoms/FavoriteToggleStyle.swift` |
| Componentes · A10 FilterChip | `148:794` | Átomo chip de filtro (`148:42`) | `View/Components/Atoms/FilterChipStyle.swift` |
| Componentes · M1 DepartureRow | `56:153` | Molécula fila de salida (`54:125`) | `View/Components/Molecules/DepartureRow.swift` |
| Componentes · M2 StationRow | `56:183` | Molécula fila de estación (`54:161`) | `View/Components/Molecules/StationRow.swift` |
| Componentes · M7 AlertBanner | `102:220` | Molécula banda de aviso de incidencia (`103:188`) | `View/Components/Molecules/AlertBanner.swift` |
| Componentes · M8 IncidentRow | `103:189` | Molécula fila de incidencia (`104:316`) | `View/Components/Molecules/IncidentRow.swift` |
| Componentes · M9 IncidentCard | `104:317` | Molécula tarjeta de incidencia (`106:273`) | `View/Components/Molecules/IncidentCard.swift` |

URL de cualquier nodo: `https://www.figma.com/design/WFoeo57elVOwmgKto1iwfq/?node-id=<id con guion>` (por ejemplo `node-id=30-2`).

## Convención de nombres

| Figma | Proyecto |
|---|---|
| `color/<grupo>/<nombre-kebab>` | color set `<grupo><NombreCamel>` en `Assets.xcassets/Colors/<Grupo>/` → `Color.<grupo><NombreCamel>` (símbolo generado por Xcode) |
| `color/bg/primary` | `bgPrimary` → `Color.bgPrimary`, `.foregroundStyle(.bgPrimary)` |
| `color/status/success-bg` | `statusSuccessBg` |
| `spacing/2xs · xs · sm · … · 5xl` | `Spacing.xxs · xs · sm · … · xxxxxl` |
| `layout/margin · gutter` | `ScreenLayout.margin · gutter` (`Layout` ya existe en SwiftUI) |
| `radius/sm … xl` | `Radius.sm … xl`; `radius/full` se expresa con `.capsule` / `.circle`, no con el número |
| `size/touch-min · row-min · icon-sm · line-badge …` | `Size.touchMin · rowMin · iconSm · lineBadge …` |
| `border/hairline · thin · thick` | `Border.hairline · thin · thick` |
| Estilos de texto | estilos de sistema (`.body`, `.headline`, …) o `Font.bodyEmphasized`, `.timeDeparture`, … |
| `Elevation/Card · Sheet · Floating` | `.elevation(.card / .sheet / .floating)` |

Las carpetas de `Assets.xcassets/Colors` **no** llevan *Provides Namespace*: solo organizan; el nombre del color set es el nombre del símbolo. El nombre SwiftUI de cada color aparece en la columna "SwiftUI" de la página de semánticos, y el de spacing/radius/size en su página: copiar tal cual.

## Cómo actualizar

### Cambiar el valor de un color existente
1. En Figma, página *DS · Color* → sección *02 Color · Semánticos* → fila del token. Las muestras **Light** y **Dark** son frames con modo explícito.
2. En Xcode, `Assets.xcassets/Colors/<Grupo>/<nombre>.colorset` → editar *Any Appearance* (Light) y *Dark*. Los valores son sRGB hex; `bg/scrim` y `interactive/pressed-overlay` llevan alpha.
3. Con Claude y el MCP de Figma: `get_variable_defs` sobre el frame **Light** de la fila devuelve el valor claro y sobre el frame **Dark** el oscuro (por ejemplo `30:26` y `30:29` para `bg/primary`). `get_design_context` sobre el grid `30:8` devuelve todas las filas de una vez, con el hex de cada modo como fallback de `var(--color/...)`.

### Añadir un color nuevo
1. Crear el color set en la carpeta del grupo con el nombre de la columna SwiftUI de Figma (o derivarlo con la convención de arriba).
2. Añadir Any/Light y Dark. Xcode genera `Color.<nombre>` al compilar.
3. Añadirlo a la lista correspondiente en `TokenGallery.swift` para poder revisarlo en el preview.

### Cambiar spacing, radios, tamaños, bordes o tipografía
Editar la constante en el fichero Swift correspondiente. Si la diseñadora añade un paso nuevo (por ejemplo `spacing/6xl`), añadirlo con el nombre que indique su columna SwiftUI y reflejarlo en `TokenGallery.swift`.

### Cambiar una sombra
`Elevation.swift`. Figma expresa el desenfoque como *blur*; en SwiftUI `radius ≈ blur / 2`. Colores `black/alpha-8 · 12 · 16` = `.black.opacity(0.08 · 0.12 · 0.16)`.

| Nivel | Figma | SwiftUI |
|---|---|---|
| None | sin sombra | `.elevation(.none)` |
| Card | 0 1 3 · black/alpha-8 | `shadow(0.08, radius 1.5, y 1)` |
| Sheet | 0 −2 12 · black/alpha-12 | `shadow(0.12, radius 6, y −2)` |
| Floating | 0 4 16 · alpha-16 + 0 1 3 · alpha-8 | dos `shadow` encadenados |

### Añadir una línea nueva (C3, …)
El color base de cada línea **lo envía la API** (`Line.colorHex`), así que no hay color sets `line/c1`, `line/c2`. `LineTint` deriva del color base lo que Figma define como tokens de línea:

| Token Figma | Valor Figma (C1) | En el proyecto |
|---|---|---|
| `color/line/c1` | #DA291C / #DA291C | `line.tint.base` (API) |
| `color/line/c1-text` | #FFFFFF | `line.tint.text` |
| `color/line/c1-subtle` | #FDF3F2 (50) / #62100A (900) | `line.tint.subtle` (mezcla con blanco 92 % / negro 55 %) |

Si la diseñadora añade `color/line/c3*` en Figma, en el proyecto no hay que hacer nada más que comprobar en `TokenGallery` que la derivación se parece a sus valores; si se alejan, ajustar los factores de mezcla en `LineTint.swift`. Tamaños y radios del badge: `Size.lineBadgeSm` (20) / `Size.lineBadge` (28) con `Radius.sm` / `Radius.md`.

## Semánticos (referencia rápida)

Valores completos en los propios color sets. Grupos y uso, según Figma:

- **bg** · superficies y capas: `primary → secondary → elevated`; `scrim` para fondos de modal (negro 40 %).
- **text** · jerarquía: `primary` contenido, `secondary` apoyo, `tertiary` metadatos; `onBrand` sobre morado; `link`; `disabled`.
- **border** · `default` campos y tarjetas, `subtle` separadores, `strong`, `focus`.
- **brand** · `primary` (+ `hover`, `pressed`, `subtle`, `onPrimary`) y `cercanias` (rojo de marca, solo referencia).
- **status** · `success · warning · error · info`, cada uno con `-bg` y `-text`.
- **transit** · alias de `status` para el estado del tren: `onTime · delayed · cancelled` (+ `-bg`, `-text`). Usar siempre estos, no `status/*`, para el estado del tren.
- **interactive** · `tabbarActive/Inactive`, `separator`, `icon`, `iconSubtle`, `pressedOverlay` (8 % alpha), `favorite` (+ `-bg`, `-text`, `-pressed`).
- **brand/tint-fill** · `brandTintFill`, primario al 14 % (Dark: purple/400 al 18 %): fondo del botón Bordered.
- **fill** · `fillTertiary` (gray/500 al 12 %, igual en Light y Dark): fondo de controles deshabilitados.
- **glass** · `glassFillTinted` (tinte del cristal Tinted) y `glassText` (texto sobre cristal Clear). `glass/fill` no tiene color set: es la aproximación de Figma al cristal y en código lo sustituye `glassEffect(.regular)`.

`AccentColor` = `brand/primary` (#7A1E78 / Dark #B45FB0): los controles del sistema lo heredan sin tinte explícito.

## Primitivas (solo referencia)

Las primitivas no existen en el proyecto como API: las vistas usan siempre semánticos. Esta tabla sirve para entender de qué primitiva sale cada semántico cuando la diseñadora habla de "subir a purple/400 en Dark".

| Rampa | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 |
|---|---|---|---|---|---|---|---|---|---|---|
| purple (primario, inspirado en Renfe) | FBF2FA | F3DEF2 | E6BEE4 | D08FCD | B45FB0 | 983A95 | **7A1E78** | 631561 | 4C0F4A | 340A33 |
| red (Cercanías · C-1) | FDF3F2 | FBE0DD | F7C1BC | F09489 | E8655A | E23F30 | **DA291C** | B51F14 | 8C170F | 62100A |
| blue (C-2) | EEF5FC | D6E6F8 | ADCDF1 | 7AACE6 | 4A8BD8 | 206EC3 | **0057A8** | 004689 | 003567 | 002446 |
| gray (neutros cálidos) | F9F9F8 | F2F2F0 | E5E5E2 | D2D2CE | A8A8A3 | 7C7C77 | **5C5C58** | 44443F | 2C2C29 | 1C1C1A |
| green (éxito · puntual) | EDF9F0 | D3F0DC | A8E1BA | 74CC91 | 43B46B | 249A4F | **1B7F40** | 166534 | 124F2A | 0C3A1F |
| amber (aviso · retraso) | FFF8E6 | FFEDBF | FFDD85 | FFC94A | F7B31C | E39A00 | **C07F00** | 986300 | 714900 | 4D3100 |

Otros: `white` FFFFFF · `black` 000000 · `gray/950` 121211 · `ios/systemRed` FF3B30 · `ios/systemGreen` 34C759 · `ios/systemOrange` FF9500 · `ios/systemBlue` 007AFF · `ios/systemYellow` FFCC00 · `black/alpha-8 · 16 · 40` · `white/alpha-16`.

## Tipografía

SF Pro en toda la app, escala Dynamic Type (tamaño Large por defecto). Se usan los estilos del sistema; solo los compuestos tienen constante propia.

| Figma | Tamaño/interlineado · peso | SwiftUI |
|---|---|---|
| Large Title | 34/41 · Bold | `.largeTitle` |
| Title 1 | 28/34 · Bold | `.title` |
| Title 2 | 22/28 · Bold | `.title2` |
| Title 3 | 20/25 · Semibold | `.title3` |
| Headline | 17/22 · Semibold | `.headline` |
| Body | 17/22 · Regular | `.body` |
| Body Emphasized | 17/22 · Semibold | `.bodyEmphasized` |
| Body Medium | 17/22 · Medium | `.bodyMedium` |
| Callout | 16/21 · Regular | `.callout` |
| Subheadline | 15/20 · Regular | `.subheadline` |
| Subheadline Emphasized | 15/20 · Semibold | `.subheadlineEmphasized` |
| Footnote | 13/18 · Regular | `.footnote` |
| Caption 1 | 12/16 · Regular | `.caption` |
| Caption 1 Emphasized | 12/16 · Semibold · tracking 0.6 | `.captionEmphasized` (+ `.tracking(Tracking.wide)` en etiquetas en mayúsculas) |
| Caption 2 | 11/13 · Regular | `.caption2` |
| Time/Departure | 17/22 · Semibold · cifras tabulares | `.timeDeparture` |
| Time/Departure Large | 22/28 · Bold · cifras tabulares | `.timeDepartureLarge` |

Reglas de Figma: horas siempre con `Time/Departure`; Large Title en navegación grande y Title 2 para nombres de estación en tarjetas; etiquetas de sección en `Caption 1 Emphasized` mayúsculas con `textSecondary`; no bajar de Caption 2; jerarquía dentro de una línea por peso, no por color.

## Espaciado, radios, tamaños

- Escala base 4 pt: `spacing/0 2xs xs sm md lg xl 2xl 3xl 4xl 5xl` = 0 2 4 8 12 16 20 24 32 40 48.
- `layout/margin` 16 (margen lateral de pantalla) · `layout/gutter` 12 (entre tarjetas).
- Radios continuos: `sm` 6 badges pequeños · `md` 10 badges grandes y celdas · `lg` 14 tarjetas · `xl` 20 bottom sheets · `full` botones, chips, búsqueda y controles Liquid Glass (cápsula).
- Tamaños: `touch-min` 44 · `icon-sm/md/lg` 16/24/32 · `line-badge` 28 (`line-badge-sm` 20, del componente LineBadge) · `chip` 24 (StatusChip) · `button-sm/md/lg` 28/34/50 · `glass-control` 48 (`glass-control-lg` 62) · `navbar` 44 · `tabbar` 49.
- Bordes: `hairline` 0.5 separadores de lista · `thin` 1 campos y tarjetas · `thick` 2 foco.

## Reglas de uso (Figma)

- Rojo solo para el badge C-1, `brand/cercanias` y errores. Nunca como primario.
- Morado primario para botones principales, tab activo, enlaces y foco.
- Estado del tren con `transit/*`, siempre acompañado de texto.
- Listas y celdas sin sombra (`Elevation/None`) separadas con `interactiveSeparator` hairline; tarjetas sobre `bgSecondary` con `Elevation/Card`; si la tarjeta va sobre `bgPrimary`, sin sombra y con `bgSecondary` de relleno; bottom sheet = `Elevation/Sheet` + `Radius.xl` arriba + `bgElevated`; flotantes = `Elevation/Floating`. Nunca dos niveles en el mismo elemento ni sombra en texto o iconos.

## Incidencias

La propiedad `Severity` de Figma (Info · Warning · Critical · Resolved) es en el proyecto un único tipo, `IncidentSeverity`, que comparten `SeverityBadge`, `AlertBanner`, `IncidentRow` e `IncidentCard`. De ahí salen el símbolo SF y los tres tokens de cada gravedad:

| Gravedad | Símbolo | `tint` (icono) | `background` (fondo) | `foreground` (texto) | `label` |
|---|---|---|---|---|---|
| `.info` | `info.circle.fill` | `statusInfo` | `statusInfoBg` | `statusInfoText` | Aviso |
| `.warning` | `exclamationmark.triangle.fill` | `statusWarning` | `statusWarningBg` | `statusWarningText` | Retrasos |
| `.critical` | `exclamationmark.circle.fill` | `statusError` | `statusErrorBg` | `statusErrorText` | Interrumpido |
| `.resolved` | `checkmark.circle.fill` | `statusSuccess` | `statusSuccessBg` | `statusSuccessText` | Resuelto |

- El icono va siempre en `tint` y el texto en `foreground`; no se mezclan.
- `label` es la etiqueta corta por defecto: `SeverityBadge(.warning)` e `IncidentCard` la usan sin que haya que pasarla. Con `label:` se sustituye por una descripción propia y VoiceOver lee "gravedad, descripción".
- Las líneas afectadas se pasan como `[LineMark]` (`LineMark("C-1", color:)`), el mismo tipo que usa `StationRow`. El color lo envía la API (`Line.colorHex`), nunca un hex escrito a mano.
- `AlertBanner` deriva su interacción de los cierres: `onTap` pinta el chevron y hace tocable la banda, `onDismiss` pinta la X (con área táctil de 44 pt). No hay props `Show chevron` / `Show close`.
- `IncidentCard` recibe la acción como contenido (`IncidentCard(...) { Button("Ver detalles") {} }`) y le aplica ella misma `.rail(.borderless)` en `.small`.

## Botones

Los tres componentes de botón de Figma son `ButtonStyle` sobre un `Button` normal. Las propiedades de Figma se traducen así:

| Figma | SwiftUI |
|---|---|
| `Style` | variante del estilo: `.buttonStyle(.rail(.prominent / .bordered / .borderless))`, `.railGlass(.clear / .tinted)`, `.railGlassIcon(.clear / .tinted)` |
| `Size` | `.controlSize(_:)`: Button `.small` 28 · `.regular` 34 · `.large` 50; GlassButton `.small` 34 · `.regular` 48; GlassIconButton `.regular` 48 · `.large` 62 |
| `State = Pressed` | automático (`configuration.isPressed`; en cristal, `glassEffect(….interactive())`) |
| `State = Disabled` | `.disabled(true)` |
| `Label` / `Show icon` / `Icon` | la etiqueta del botón: `Button("Ver horarios") {}` o `Button("Ver horarios", systemImage: "clock") {}` |

- GlassIconButton usa `Button("Mi ubicación", systemImage: "location.fill")`: solo pinta el icono, pero VoiceOver lee el título.
- Las alturas crecen con Dynamic Type (`@ScaledMetric`). Button y GlassButton amplían el área táctil hasta `Size.touchMin` (44).
- En toolbars no hace falta estilo: iOS 26 ya aplica cristal a los botones de `.toolbar`.

