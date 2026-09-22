---
name: rail-figma-component
description: Pasa a SwiftUI un componente del design system de Rail desde Figma (badges, chips, botones, celdas, átomos y moléculas), con los tokens del proyecto, modo oscuro, Dynamic Type, accesibilidad y verificación en el simulador. Úsala siempre que en este proyecto aparezca una URL de figma.com con node-id, o que el usuario pida "crea/genera este componente", "sigue lo de Figma", "implementa este átomo", "pásalo a SwiftUI", "haz el botón/badge/chip de Figma", o que haya que añadir o sincronizar tokens de Figma (colores, tamaños, tipografía) en Assets.xcassets o DesignSystem/. Úsala aunque el usuario no diga "Figma" si está hablando de un componente del design system.
---

# Componente de Figma → SwiftUI en Rail

Esta skill recoge cómo se construyeron `LineBadge`, `StatusChip` y los tres estilos de botón, para que cada componente nuevo salga igual: fiel a Figma donde Figma tiene razón, idiomático en SwiftUI y verificado de verdad, no solo compilado.

Complementa dos skills genéricas que conviene tener cargadas:
- `figma:figma-swiftui` (y su `references/design-to-code.md`): reglas generales de Figma a SwiftUI (estilos de texto, SF Symbols, no copiar posiciones absolutas).
- `figma:figma-use`: obligatoria antes de llamar a `use_figma`.

Las reglas del proyecto están en `CLAUDE.md` (sin comentarios en código, programación declarativa, APIs de iOS 26, texto en español) y en `Rail/DesignSystem/DESIGN-TOKENS.md` (nombres de tokens). Esta skill no las repite: síguelas.

Antes de empezar, lee `references/decisiones.md`: tiene las medidas de los controles del sistema, qué componente existente sirve de patrón para cada caso y las trampas conocidas de Figma. Te ahorra redescubrirlas.

## Documentarse cuando haya dudas

No adivines APIs. Si dudas de si algo existe, de su disponibilidad (iOS 26 frente a 27, que exige `if #available(iOS 27, *)`), de su comportamiento o de lo que dicen las HIG, consulta la documentación:

1. **MCP de Xcode** (`xcrun mcpbridge`). Si hay herramientas `mcp__<servidor>__DocumentationSearch` en la sesión, úsala: `DocumentationSearch(query:, frameworks: ["SwiftUI"])`. Todas sus herramientas exigen que el usuario apruebe al agente: llama antes a `XcodeOpenWorkspace(path: "<ruta absoluta>/Rail.xcodeproj")` y avisa al usuario de que Xcode le pedirá permiso. Si el MCP no está registrado, sugiere (no lo hagas tú) `claude mcp add --transport stdio xcode -- xcrun mcpbridge`.
2. **Interfaz del SDK**, sin necesidad del MCP:
   ```bash
   SDK=$(xcrun --show-sdk-path --sdk iphonesimulator)
   grep -n "func labelIconToTitleSpacing" "$SDK"/System/Library/Frameworks/SwiftUI.framework/Modules/SwiftUI.swiftmodule/*.swiftinterface
   ```
   Las líneas `@available` encima de la declaración indican desde qué iOS existe.
3. **Compilar** es la prueba final de que una API existe con esa firma.

## 1. Leer el componente en Figma

De la URL `figma.com/design/<fileKey>/…?node-id=40-71` salen `fileKey` y `nodeId` (`40:71`).

1. `get_design_context` con `clientLanguages: "swift"` y `clientFrameworks: "swiftui"`. El React+Tailwind es una referencia estructural, no un código que copiar. Lo valioso es la **descripción del componente** (reglas de uso), los estilos de texto, la captura y los assets.
2. `scripts/read_figma_component.js` con `use_figma` (solo lectura): copia el fichero, pon el id en `NODE_IDS` y ejecútalo. Devuelve:
   - las variantes con su ancho y alto exactos;
   - la sección de documentación (id, página y los textos del frame `Doc/<Nombre>`: tamaños, tokens, props, accesibilidad y a menudo la **firma Swift esperada**);
   - todas las variables enlazadas, con su valor **Light y Dark** y su `codeSyntax.iOS`.

   Hace falta porque `get_variable_defs` solo da el modo claro y la tabla de semánticos de Figma no incluye los tokens nuevos.
3. Los assets SVG (puntos, iconos dibujados) se descargan con `curl` desde las URLs de `get_design_context`. Mira su `fill` y relaciónalo con un token existente en vez de copiar el hex. Los SF Symbols vienen como `Image(systemName:)`: usa el nombre tal cual.

Si el usuario pide algo distinto de Figma ("recibe el color, olvídate de las líneas"), manda el usuario: implementa lo que pide y menciona la diferencia al final.

## 2. Tokens

Comprueba qué existe antes de crear nada: `Rail/Assets.xcassets/Colors/<Grupo>/`, `Size.swift`, `Spacing.swift`, `Radius.swift`, `Typography.swift`.

- **Color que falta**: crea el color set con el nombre del `codeSyntax.iOS` sin `Color.` y los valores Light y Dark del script de lectura:
  ```bash
  python3 .claude/skills/rail-figma-component/scripts/add_colorset.py Brand brandTintFill 7A1E7824 B45FB02E
  ```
  La carpeta del grupo sale del segundo segmento del nombre de Figma (`color/glass/text` → `Glass`). El script se niega a pisar un color existente.
- **Tamaño, espaciado o tipografía que falta**: añade una constante con el nombre del `codeSyntax.iOS` (`Size.buttonLg`, `Font.bodyMedium`). Ese nombre no siempre sirve: la tabla de equivalencias está en `references/decisiones.md` (por ejemplo, `radius/full` es `.capsule`).
- **Valor en crudo sin variable en Figma** (`px-[10px]`, `w-[40px]`): constante privada del componente, no un token global. Un token global sin variable en Figma no se podría sincronizar.
- **Aproximaciones de Figma** (relleno blanco de `glass/fill`, sombras del efecto *Glass*): no se convierten en tokens. El cristal real las sustituye.
- Añade cada token nuevo a `TokenGallery.swift` y a `DESIGN-TOKENS.md`.

## 3. Decidir la forma del componente

La forma depende de qué es el componente, no de cómo está dibujado en Figma:

| Qué es | Forma en SwiftUI |
|---|---|
| Elemento que se pulsa (botón, botón de icono) | `ButtonStyle` aplicado a un `Button` normal. Nunca una `View` que envuelva un `Button`: se pierden accesibilidad, estados y la integración con toolbars. |
| Control con equivalente en el sistema (toggle, segmented, picker, slider) | El control del sistema con tokens (`.tint`) o, si el diseño se aparta, su protocolo de estilo (`ToggleStyle`, …). |
| Pieza que solo muestra algo (badge, chip, etiqueta, celda) | `struct … : View`. |

**Antes de hacer un estilo propio, comprueba si el sistema ya coincide.** Para los botones está medido en `references/decisiones.md`. Para cualquier otro control, mídelo con `scripts/simulator_preview.sh` (paso 5) y compara con las medidas de Figma. Si geometría y colores coinciden, usa el del sistema: gratis tendrás animaciones, accesibilidad y futuras versiones de iOS. Si no, estilo propio.

## 4. Escribir el código

Dónde: `Rail/View/Components/`. Si es una familia de componentes, en una carpeta (`Button/`). Sin cabecera de fichero y sin comentarios.

Cómo pasar cada propiedad de Figma:

| Propiedad de Figma | En código |
|---|---|
| `Size` de un control | `@Environment(\.controlSize)`; el usuario escribe `.controlSize(.large)`. Mapea `.mini/.small`, `.regular` y `.large/.extraLarge` a los tamaños de Figma. |
| `Size` de una pieza visual | Parámetro con un enum propio. No lo llames `Size`, porque tapa los tokens `Size.*`: usa `Scale`, `Metrics` o similar. |
| `State = Pressed` | `configuration.isPressed`; en cristal, `.interactive()`. |
| `State = Disabled` | `@Environment(\.isEnabled)`; el usuario escribe `.disabled(true)`. |
| `Label`, `Icon`, `Show icon` | La etiqueta del `Button`/`Label`. Si solo se ve el icono, `.labelStyle(.iconOnly)` con un título para VoiceOver. |
| Texto de interfaz editable | `LocalizedStringResource`. |
| Texto que es un dato (nombre de línea) | `String` pintado con `Text(verbatim:)`. |
| Color que llega de la API | Parámetro `Color`. |
| Firma Swift en el frame `Doc/` | Cópiala, salvo que el usuario pida otra. |

Patrones que se repiten:

- **Colores por estado** con `switch` sobre una tupla, como expresión: `switch (isEnabled, variant, isPressed) { case (false, _, _): .textDisabled … }`. Queda declarativo y el compilador comprueba que no falte ningún caso.
- **Dynamic Type.** El texto usa estilos del sistema (`.caption`, `.headline`, `.captionEmphasized`), que ya escalan solos. Las cajas de tamaño fijo escalan con `@ScaledMetric`:
  - un solo estilo de texto: `@ScaledMetric(relativeTo: .caption) private var height = Size.chip`;
  - estilo que depende de un parámetro: `init` propio con `_height = ScaledMetric(wrappedValue:relativeTo:)`;
  - varios tamaños dentro de un `ButtonStyle`: `@ScaledMetric private var scale: CGFloat = 1` multiplicado por el token de altura.
- **Área táctil de 44 pt** cuando la altura visual es menor: `.contentShape(.rect.inset(by: -max(0, (Size.touchMin - height) / 2)))`.
- **Formas.** `.rect(cornerRadius: Radius.x, style: .continuous)`; `radius/full` es `.capsule` (o `.circle`).
- **Cristal.** `.glassEffect(.regular[.tint(token)].interactive(), in: forma)`. Sin sombras ni rellenos extra. Dentro de `.toolbar` no hace falta estilo: iOS 26 ya pone cristal.
- **Accesibilidad.** Los adornos llevan `.accessibilityHidden(true)`. Las piezas cortas que no deben truncarse llevan `.fixedSize()`.
- **Estilos reutilizables** con acceso estático: `extension ButtonStyle where Self == RailButtonStyle { static func rail(_:) -> Self }`.

**Previews**, siempre en español y con los tokens de fondo (`.bgPrimary`, `.bgSecondary`):
- `"Variantes Figma"`: la misma rejilla que el component set de Figma, para poder compararlas lado a lado.
- `"Modo oscuro"`: con `.preferredColorScheme(.dark)`.
- `"Dynamic Type"`: con `.dynamicTypeSize(.accessibility2)`.

Los hex solo se admiten en previews y únicamente para simular colores de la API (`Color(hex: "DA291C")`).

## 5. Verificar

1. **Compilar**:
   ```bash
   xcodebuild -project Rail.xcodeproj -scheme Rail -destination 'generic/platform=iOS Simulator' build -quiet
   ```
   Los errores de SourceKit en ficheros nuevos ("Cannot find 'Spacing' in scope") son falsos: vale lo que diga `xcodebuild`.
2. **Ver y medir.** Elige una opción:
   - **MCP de Xcode**, si está: `RenderPreview(sourceFilePath: "Rail/View/Components/<Fichero>.swift", previewDefinitionIndexInFile: n)` dibuja cada preview sin tocar la app.
   - **Simulador**: escribe en el scratchpad un fichero con `struct ZZHarness: View` que muestre las variantes y marque con `.measure("nombre")` lo que quieras medir. Después:
     ```bash
     .claude/skills/rail-figma-component/scripts/simulator_preview.sh <harness.swift> <carpeta-salida> [udid]
     ```
     Sustituye temporalmente `RootView()`, compila, instala, saca capturas en claro y oscuro, imprime las medidas y **siempre** restaura `RailApp.swift`. Aun así, comprueba después con `git status` que no quedan `ZZ*.swift` ni cambios en `RailApp.swift`.
3. **Comparar** las medidas con las variantes del paso 1 (alto exacto; ancho cuando Figma lo fija) y las capturas con la de Figma. Mira también el modo oscuro: es lo que más se escapa.
4. Lo que no puedas comprobar (estado pulsado, área táctil sin poder tocar) dilo en el informe; no lo des por verificado.

## 6. Documentar y cerrar

- `DESIGN-TOKENS.md`: una fila en la tabla de páginas (`Componentes · A3 StatusChip | 44:66 | … (40:71) | ruta`), los tokens nuevos en su lista y, si el componente introduce una forma de uso nueva, una sección corta como *Botones*.
- `TokenGallery.swift`: los tokens nuevos.
- `CLAUDE.md`: solo si hay una regla nueva que cualquier agente deba conocer siempre (por ejemplo, "los botones usan `.buttonStyle(.rail…)`"). Una línea.

**Informe final al usuario**, en español y breve:
1. Cómo se usa: 1 a 3 líneas de código.
2. Tabla Figma → código: tokens y propiedades.
3. Qué se verificó y cómo: medidas, capturas, modo oscuro, Dynamic Type.
4. Diferencias con Figma y por qué (errores de diseño detectados, anchos que no cuadran, decisiones del usuario), marcando lo que conviene confirmar con la diseñadora.
