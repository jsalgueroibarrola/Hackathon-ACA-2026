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
| Mockups · 01 Inicio | `2:53` | Pantalla Home (`2:54`) y una pantalla por estado de la tarjeta de próximos trenes | `View/HomeView.swift`, `View/Components/NextTrainsSection.swift` |
| Mockups · 01 Inicio · Card | `2:53` | Organismo tarjeta de próximos trenes (`59:1450` y seis estados más, ver *Tarjeta de próximos trenes*) | `View/Components/Organisms/NextTrainsCard.swift` |
| Mockups · 01 Inicio · Station Container | `2:53` | Molécula nombre de estación y proximidad (`59:1452`) | `View/Components/Molecules/StationHeader.swift` |
| Mockups · 01 Inicio · Section Header | `2:53` | Molécula cabecera de sección con icono (`59:1455`) | `View/Components/Molecules/CardSectionHeader.swift` |
| Mockups · 01 Inicio · Permiso / Sin trenes | `2:53` | Molécula mensaje de tarjeta, regular (`220:1974`) y compacta (`220:3269`) | `View/Components/Molecules/CardMessage.swift` |
| Mockups · 01 Inicio · trenecito | `2:53` | Ilustración del tren (`60:3377`); en código se usa el SVG entregado por el usuario, no el de Figma | `View/Components/Atoms/TrainIllustration.swift` |
| Mockups · 01 Inicio · Favorite Stations Container | `2:53` | Organismo sección de estaciones favoritas (`59:1518`); estado vacío en la pantalla *Home sin favoritas* (`220:3329`) | `View/Components/Organisms/FavoriteStationsContainer.swift`, `View/Components/FavoriteStationsSection.swift` |
| Mockups · 01 Inicio · tarjeta de favorita | `2:53` | Molécula tarjeta de estación favorita (`60:2215`) | `View/Components/Molecules/FavoriteStationCard.swift` |
| Mockups · 01 Inicio · Favoritos vacíos | `2:53` | Molécula de estado vacío (`220:3525`) | `View/Components/Molecules/EmptyStateCard.swift` |
| Mockups · 01 Inicio · Imagen de fondo | `2:53` | Foto de cabecera (`60:3294`), 393×262 con relleno *Fill*; el original mide 786×442 | `Assets.xcassets/Photos/HomeHero.imageset`, `View/Components/Atoms/HomeHeroImage.swift` |
| Mockups · 01 Inicio · Logo | `2:53` | Logo de la barra superior (`143:5493`), 44×44 | `Assets.xcassets/Illustrations/RailLogo.imageset`, `View/Components/Atoms/RailLogo.swift` |

URL de cualquier nodo: `https://www.figma.com/design/WFoeo57elVOwmgKto1iwfq/?node-id=<id con guion>` (por ejemplo `node-id=30-2`).

Las filas de *Mockups* no son componentes de Figma: son frames de maqueta, sin variantes ni frame `Doc/`. Sus medidas se leen de los propios frames y hay que descartar las capas ocultas (`visible: false`).

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
| Title 2 | 22/28 · Bold | `.title2Emphasized` (el `.title2` del sistema es Regular) |
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

## Ilustraciones

- Van en `Assets.xcassets/Illustrations/` como imageset con un SVG y *Preserve Vector Data* (`preserves-vector-representation`). La carpeta no lleva *Provides Namespace*, igual que `Colors/`.
- No llevan *Render As Template* ni se convierten en SF Symbol: son multicolor y el color forma parte del dibujo.
- El SVG se normaliza antes de añadirlo. `width` y `height` pasan a ser numéricos, iguales al `viewBox`, y los estilos CSS (`style="fill:…"`) pasan a atributos (`fill="…"`). CoreSVG los interpreta mejor y el dibujo no cambia.
- Cada ilustración tiene un átomo que la envuelve y la oculta a VoiceOver. El alto lo decide quien la usa: `TrainIllustration().frame(height: 53)`.
- Pendiente de diseño: el tren es claro también en modo oscuro y destaca mucho sobre `bgPrimary` oscuro. Una versión oscura se añadiría como apariencia *Dark* del mismo imageset.
- **Logo (`RailLogo`).** Figma lo exporta con un PNG enmascarado de 508×508 como fondo, así que el SVG del proyecto es una composición: una tesela de 44×44 con radio 11 y el degradado casi blanco de ese PNG (`#FCFCFC` → `#EFEFEF` en diagonal) más el glifo de `AppIcon.icon/Assets/Logo tren app.svg`, escalado y colocado donde lo pone Figma. Es igual en claro y en oscuro, como en la maqueta.
- **Fotos.** Van en `Assets.xcassets/Photos/` (sin *Provides Namespace*) como JPEG. `HomeHero` se registra a 2x (786×442 px = 393×221 pt) y `HomeHeroImage` la pinta con `scaledToFill` recortada al marco que decide quien la usa. Pendiente de diseño: en iPad y Pro Max se verá blanda; hace falta una versión de más resolución.

## Inicio

`HomeView(onShowMap:onShowStations:)` compone `NextTrainsSection` y `FavoriteStationsSection` dentro de `NavigationStack(path: [HomeRoute])` > `ScrollView`, sobre `bgSecondary`. Maquetas: con favoritas (`2:54`) y sin favoritas (`220:3329`).

- **Foto a sangre** (`HomeHeroImage`). Va en el `.background(alignment: .top)` del contenido, con alto `topInset + 80 + 76` y desplazada `-topInset`. Así cubre la barra de estado y la de navegación y termina 76 pt dentro de la tarjeta de próximos trenes, que empieza a `topInset + 80`: en un iPhone 16 Pro, 262 y 186, como en Figma. `topInset` es `ScrollGeometry.contentInsets.top`. Al tirar hacia abajo se estira con `.visualEffect` (escala anclada abajo según `frame(in: .global).minY`; con `.scrollView` no crece). La capa *Blur* de Figma (`60:3460`) es el efecto de borde de scroll del sistema: no se imita.
- **Alto visible** (`.fitsScrollViewport()`, en `ViewportFit.swift`). El contenido va dentro de un `Layout` de un solo hijo que le **propone** el alto visible pero reporta el alto **natural** que devuelva. Así Inicio ocupa exactamente una pantalla cuando cabe (sin scroll) y, cuando ni el mínimo de 3 favoritas cabe (ventana baja en iPad, iPhone en horizontal, tamaños de accesibilidad), el contenido crece y el `ScrollView` vuelve a desplazarse. Acotar con `.containerRelativeFrame(.vertical)` a secas no sirve: reporta siempre el alto del contenedor, así que el sobrante quedaba recortado e inalcanzable. El alto visible lo mide el propio modificador con una sonda `Color.clear.containerRelativeFrame(.vertical)` en el `background` (ya descuenta la barra de navegación y la de pestañas, y al ir en un `background` no afecta al layout); `ScrollGeometry.containerSize.height` da el mismo número. De `ScrollGeometry` solo se lee `contentInsets.top`, para la foto; nunca `contentOffset`, para no recalcular en cada frame.
- **Barra superior.** A la izquierda, `RailLogo` de 44 pt con `.sharedBackgroundVisibility(.hidden)` (sin cristal); VoiceOver lo lee como la cabecera «Inicio», porque dentro de la barra la imagen no respeta `accessibilityHidden` y se leía «RailLogo». A la derecha, un `ToolbarItemGroup` con «Avisos» (`bell.fill`) y «Ajustes» (`gearshape.fill`), sin estilo: iOS 26 los agrupa en una cápsula de cristal. Todavía no hacen nada. El título «Inicio» se declara con `.navigationTitle` (lo usa el botón atrás) y se oculta con `.toolbarTitleDisplayMode(.inline)` más `.toolbar(removing: .title)`; sin el modo inline, el título grande sigue apareciendo.
- **Ancho.** El contenido va centrado con un máximo de 640 pt (iPad, iPhone en horizontal); la foto sigue a sangre.
- **Navegación** por `HomeRoute`: `.favorites` abre `FavoriteStationsView` (borrar deslizando, `EditButton` para reordenar, `ContentUnavailableView` si no hay ninguna) y `.station(id:)` abre `StationDestination`, que busca la estación con `@Query` y muestra «Estación no disponible» si una reimportación la ha borrado.
- **«Ver estaciones»**, en el estado vacío de favoritas, no navega dentro de Inicio: `MainTabView` cambia a la pestaña Estaciones.
- **Estrellas.** Donde el usuario marca favoritas (filas de «Todas las estaciones» y barra del detalle de estación) se usa `Toggle(isOn: favoritesModel.binding(for:isFavorite:))` con `.toggleStyle(.favorite)`. Dentro de una fila con `NavigationLink`, el botón `.plain` del estilo basta para que tocar la estrella no navegue.

## Estaciones favoritas

`FavoriteStationsContainer(items, onAction:)` no lee datos: pinta `[StationRowItem]` y avisa con un `FavoriteStationsAction` (`.open(id)`, `.showAll`, `.remove(id)`, `.browseStations`). `FavoriteStationsSection` lo conecta con `@Query` (`FavoriteStation.order` y `Station`), la ubicación de `LocationViewModel` y `FavoritesViewModel`.

- **Piezas.** Cabecera `CardSectionHeader("Estaciones favoritas")` sin icono; cada favorita es un `FavoriteStationCard` (un `StationRow` sin separador con padding `Spacing.sm` sobre `bgPrimary`) dentro de un `Button(.plain)`; sin favoritas, un `EmptyStateCard` con `star` en `interactiveFavorite` y el botón «Ver estaciones» en `.rail(.bordered)` `.regular`. Separación de 8 entre cabecera y contenido, 12 entre tarjetas y padding 16 alrededor.
- **Adaptadores.** `StationRow(item, isFavorite:showsSeparator:)` y `FavoriteStationCard(item)` convierten `StationRowItem` en vista; `LineMark(tag)` pasa el `colorHex` de la API a `Color`.
- **Subtítulo** (`StationRowItemBuilder.subtitle`): «A 1,2 km» si hay ubicación; si no, las conexiones («Metro · Autobús urbano»); si tampoco hay, ninguno.
- **«Ver más»** (footnote, `brandPrimary`, `chevron.right`, separación 4) solo aparece si hay al menos una favorita. Es un `Button` `.borderless` con área táctil de 44 pt y VoiceOver lee «Ver todas las estaciones favoritas». Al no depender del número de filas visibles, la cabecera tiene siempre el mismo alto.
- **Capacidad.** Se muestran tantas tarjetas como quepan sin hacer scroll, entre 3 y 12 (`FavoritesCapacity.minimumVisible` y `.maximumVisible`). No hay cuentas ni geometría medida: un `ViewThatFits(in: .vertical)` recibe como candidatos los `VStack` de `n`, `n−1`, … , 3 tarjetas (`FavoritesCapacity.candidateCounts(total:)`) y el propio layout elige el primero que cabe, con los altos reales de cada tarjeta (subtítulo, nombre en dos líneas, Dynamic Type). Los cambios de la lista se animan con `.smooth`. Quien pinte la sección tiene que darle dos cosas:
  - `.fitsScrollViewport()` al contenido de su `ScrollView`, para que la propuesta de alto sea finita (ver *Inicio*).
  - `.layoutPriority(-1)` a la sección, para que el resto del contenido tome su alto natural y favoritas se quede con lo que sobra. Sin esa prioridad el `VStack` reparte el alto entre los dos y comprime la tarjeta de arriba (el texto de `NextTrainsCard` se truncaba) en vez de quitar una tarjeta.
- **Menú contextual.** Cada tarjeta tiene «Quitar de favoritos» (`star.slash`, destructivo) con el mismo texto que `FavoriteToggleStyle.removeLabel` y una previsualización con la forma de la tarjeta.
- **Radio 12.** Las tarjetas y el estado vacío usan radio 12, que no es un token (está entre `Radius.md` 10 y `Radius.lg` 14). Va como constante privada hasta que la diseñadora decida si es un token nuevo o se ajusta a uno existente.
- **Sin sombra**: los frames de Figma no tienen efectos.
- **Escrituras.** Quitar, añadir y reordenar pasan por `FavoritesViewModel`, que llama de forma síncrona a `UserStationsRepository` sobre `mainContext`; la lectura es siempre `@Query`. Por eso la tarjeta desaparece en la misma transacción que el gesto, sin `Task` ni estado optimista. Para la estrella, `favoritesModel.binding(for: id, isFavorite:)` devuelve un `Binding<Bool>` cuyo setter llama a `setFavorite`.

## Tarjeta de próximos trenes

`NextTrainsCard(state, onAction:)` no lee datos: pinta un `NextTrainsCardState` y avisa de lo que pulsa el usuario con un `NextTrainsCardAction`. `NextTrainsSection` la conecta con la ubicación, SwiftData y MapKit a través de las funciones puras de `NextTrainsCardStateBuilder`.

| Estado | Maqueta (pantalla) | Qué pinta | Acciones |
|---|---|---|---|
| `.station`, proximidad `.walking` | `59:1450` (Home `2:54`) | Nombre, «A N minutos a pie», tren, «Próximos trenes» y dos `DepartureRow` | ninguna |
| `.station`, proximidad `.distance` | `220:1589` (Modo sin conexión `220:1560`) | Lo mismo con «A 1,2 km» | ninguna |
| `.station`, proximidad `.saved` | sin maqueta | Lo mismo con «Tu estación habitual» y «Cambiar» en la cabecera de sección | Cambiar → `.chooseStation` |
| `.station`, salidas `.finished` | `220:3121` (Sin trenes hoy `220:3092`) | «No quedan trenes hoy» y la primera salida de mañana, con `CardMessage` compacto | ninguna |
| `.station`, salidas `.loading` | sin maqueta | Dos filas con `.redacted(reason: .placeholder)` | ninguna |
| `.permissionNeeded` | `220:1838` (Sin permiso `220:1809`) | Solo `CardMessage`, sin cabecera ni tren | Permitir ubicación · Elegir estación |
| `.permissionDenied` | `220:2074` (Ubicación denegada `220:2045`) | Solo `CardMessage` | Elegir estación · Abrir Ajustes |
| `.locationUnavailable` | `220:2252` (No te ubicamos `220:2223`) | Solo `CardMessage` | Reintentar · Elegir estación |
| `.noStationNearby` | `220:2430` (Fuera de zona `220:2401`) | Solo `CardMessage`, con la estación más próxima en kilómetros enteros | Ver en el mapa · Elegir estación |
| `.locating` | sin maqueta | Indicador de progreso y «Buscando tu ubicación…» | Elegir estación |

- **Qué estación se muestra** (`NextTrainsCardStateBuilder.target`), en este orden:
  1. la más cercana a la ubicación del dispositivo, si está a 10 km o menos;
  2. la estación guardada (`SavedStation`, leída con `@Query(SavedStation.current)` y escrita por `LocationViewModel` a través de `UserStationsRepository`), resuelta por id de estación o, si ese id ya no existe, por sus coordenadas;
  3. «sin estación cerca», si hay ubicación pero ninguna estación a 10 km;
  4. el mensaje que corresponda al permiso de ubicación.
- **Proximidad:** tiempo andando de MapKit si es menor de una hora, redondeado hacia arriba y como mínimo 1 minuto. Si no hay tiempo andando, la distancia (`distanceLabel`). La estación guardada no pide tiempo andando.
- **Salidas:** las dos siguientes de hoy entre todas las líneas y sentidos, en la zona horaria de la red. El identificador de línea se pinta tal como llega de la API. Sin más salidas hoy, se muestra la primera de mañana si mañana entra en el horario descargado.
- **Plural:** «A 1 minuto a pie» sale de una variación de plural en `Localizable.xcstrings` (clave `A %lld minutos a pie`). `inflect: true` no funciona en este proyecto.
- **Sombra:** la tarjeta va sobre `bgSecondary` sin sombra, porque la sombra de la maqueta está desactivada. Es una excepción a la regla general de tarjetas con `Elevation/Card`.
- **«Cambiar» va en la cabecera de sección**, no junto al nombre, porque el tren ocupa la esquina superior derecha.
- **Cabecera «Próximos trenes · programados»:** `CardSectionHeader(detail:)` la soporta, pero solo aparece en la maqueta *Modo sin conexión*. La app aún no detecta la falta de conexión, así que la tarjeta no la usa.
- **GlassButton dentro de la tarjeta:** se usa porque así lo dibujan las maquetas, aunque la documentación del componente lo desaconseja en tarjetas opacas.
