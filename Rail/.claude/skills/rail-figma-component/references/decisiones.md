# Decisiones y hallazgos previos

Lo que ya se descubrió implementando `LineBadge`, `StatusChip` y los botones. Léelo antes de repetir una medición o de dudar de un patrón.

## Índice

1. Controles del sistema medidos
2. Componentes existentes como patrón
3. Peculiaridades de Figma
4. Peculiaridades de las herramientas

## 1. Controles del sistema medidos

SDK iOS 27, iPhone, tamaño de texto por defecto, etiqueta de una línea. Si cambia el SDK, vuelve a medir con `scripts/simulator_preview.sh`.

| Control | `.small` | `.regular` | `.large` / `.extraLarge` | Aspecto |
|---|---|---|---|---|
| `.borderedProminent` + `.buttonBorderShape(.capsule)` | 28 | 34 | 50 | Fondo `AccentColor`, texto blanco |
| `.bordered` + cápsula | 28 | 34 | 50 | Fondo **gris**, texto con tinte |
| `.borderless` | 18 | 20 | 20 | Sin fondo ni padding |
| `.glass` / `.glassProminent` | 28 | 34 | 50 | Cristal real; peso de texto regular |
| `.glass` + `.buttonBorderShape(.circle)` (solo icono) | 28 | 34 | 50 | Círculo |

Conclusión que se tomó: el kit de Figma (Button 28/34/50) coincide en geometría con el sistema, pero no en colores (Bordered con la marca al 14 %, pressed con `brandPrimaryPressed`/`brandPrimarySubtle`), en el Borderless con cápsula ni en los tamaños de cristal (48/62). Por eso los tres botones son `ButtonStyle` propios que leen `controlSize`.

## 2. Componentes existentes como patrón

Antes de escribir uno nuevo, abre el que más se parezca y copia su estructura.

| Fichero | Qué demuestra |
|---|---|
| `View/Components/LineBadge.swift` | Átomo `View` que recibe un `Color` (dato de la API) y un `String` con `Text(verbatim:)`. Enum de tamaño llamado `Scale` para no chocar con `Size`. `@ScaledMetric` con `relativeTo` variable, inicializado en un `init` propio (`_height = ScaledMetric(wrappedValue:relativeTo:)`). `.fixedSize()` para que no se trunque. |
| `View/Components/StatusChip.swift` | Átomo `View` con un enum de estado cuyas propiedades (`dotColor`, `textColor`, `backgroundColor`) son `switch` a tokens. Texto de interfaz como `LocalizedStringResource`. `@ScaledMetric(relativeTo: .caption)` en forma corta. Elemento decorativo con `.accessibilityHidden(true)`. Firma copiada de la documentación de Figma: `StatusChip(.delayed, label: "+5 min")`. |
| `View/Components/Button/RailButtonStyle.swift` | `ButtonStyle` con `@Environment(\.controlSize)`, `@Environment(\.isEnabled)` y `configuration.isPressed`. Colores con `switch` sobre tuplas `(isEnabled, variant, isPressed)`. Un solo `@ScaledMetric var scale = 1` multiplicado por el token de altura. Área táctil ampliada con `.contentShape(.rect.inset(by: -touchInset))`. Acceso estático `.buttonStyle(.rail(.prominent))`. |
| `View/Components/Button/RailGlassButtonStyle.swift` | Cristal real con `.glassEffect(.regular.tint(token).interactive(), in: .capsule)`. Lógica de cristal y color en una extensión del enum `Variant`, compartida con el botón de icono. |
| `View/Components/Button/RailGlassIconButtonStyle.swift` | Botón solo icono: `.labelStyle(.iconOnly)` sobre un `Label`, así VoiceOver sigue leyendo el título. |

## 3. Peculiaridades de Figma

- **`get_variable_defs` solo devuelve un modo** (el claro). La tabla de semánticos de la página *DS · Color* no lista los tokens añadidos después (`fill/*`, `glass/*`, `brand/tint-fill`). Para el modo oscuro usa `scripts/read_figma_component.js`.
- **El `codeSyntax.iOS` de las variables es una pista, no la verdad.** Coincide para colores (`Color.brandTintFill`) y tamaños (`Size.buttonLg`). No coincide en: `Radius.full` → en el proyecto se usa `.capsule` o `.circle`; `Font.TextStyle.caption.size` y parecidos → estilos de texto del sistema; `Font.Tracking.wide` → `Tracking.wide`; `Font.family.*` y `Font.Weight.*` → se ignoran, los cubre el estilo de texto.
- **El fallback de `var(--token, valor)`** en el React de `get_design_context` es el valor Light.
- **Anchos fijos que no caben.** `LineBadge` tiene `w-[40px]` en todas las variantes, pero en Large el texto más el padding (12+12) no cabe en 40 y Figma se come el padding. Se resolvió con `minWidth` 40 más el padding del token (el Large mide ~51) y se avisó al usuario.
- **Colores de icono dentro de instancias.** En GlassIconButton Tinted, Figma deja el icono en `text/primary` (oscuro sobre morado). Se usó `brandOnPrimary`, igual que el texto del GlassButton Tinted, y se avisó.
- **`brandOnPrimary` es oscuro en modo oscuro** (#121211), porque ahí `brandPrimary` es un morado claro (#B45FB0). Es intencionado; no lo "arregles" a blanco.
- **"Clear" en Figma es `Glass.regular`**, no `Glass.clear`. `glass/fill` (blanco al 65 %) y la sombra `0 8 40` del efecto *Glass/Regular* son la aproximación de Figma al cristal: no se crean tokens ni sombras para ellos.
- **Estados de Figma.** `Pressed` y `Disabled` son variantes en Figma, pero en código salen de `configuration.isPressed` y de `.disabled(_:)`. No se exponen como parámetros.
- **Documentación junto al componente.** Cada componente vive en una sección (`A3 StatusChip`, …) de la página *CI · Átomos* (`40:2`) con un frame `Doc/<Nombre>` que lista tamaños, tokens, props, reglas de accesibilidad y a veces la firma Swift esperada. Si el usuario pide otra cosa (por ejemplo, `LineBadge` recibe un `Color` en vez de `line:`), manda el usuario.

## 4. Peculiaridades de las herramientas

- **SourceKit da errores falsos en ficheros nuevos** ("Cannot find 'Spacing' in scope", "Type 'Color' has no member 'bgPrimary'"). Son de indexado: la fuente de verdad es `xcodebuild`.
- **Las herramientas del simulador integradas pueden fallar** si Xcode no está seleccionado con `xcode-select`. `scripts/simulator_preview.sh` solo usa `xcrun simctl`.
- **No se pueden simular toques** con `simctl`: el estado pulsado y el área táctil ampliada no se pueden comprobar así. Si el MCP de Xcode está conectado, `DeviceInteractionSynthesize` sí puede tocar; si no, dilo en el informe final.
- **El MCP de Xcode necesita aprobación, también para `DocumentationSearch`.** Mientras no se apruebe, todas las herramientas responden "This agent isn't approved to use Xcode's tools yet". Llama primero a `XcodeOpenWorkspace` con la ruta absoluta de `Rail.xcodeproj`: Xcode muestra al usuario el diálogo de permiso. La aprobación dura toda la sesión.
