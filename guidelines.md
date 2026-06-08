# Design Guidelines

## Referencia visual

[image:1]

Esta guía toma como referencia un sistema visual tipo dashboard con estilo limpio, tarjetas redondeadas, jerarquía clara y una paleta sobria con acentos cálidos.

## Identidad visual

- Estilo general: interfaz moderna, minimalista y orientada a producto.
- Sensación buscada: profesional, amigable y confiable.
- Uso principal: panel administrativo, sistema de gestión o app de monitoreo.
- Composición: bloques modulares con bastante espacio en blanco.

## Paleta de color

### Colores principales observados

| Rol | Color aproximado | Uso sugerido |
|---|---|---|
| Primary | `#1A3C40` | Botones principales, iconos activos, encabezados, estados destacados |
| Secondary | `#D4A373` | Acentos secundarios, badges, líneas de apoyo, elementos informativos |
| Tertiary | `#E99497` | Estados suaves, highlights, tags complementarios |
| Neutral | `#767777` | Texto secundario, bordes, fondos neutros, iconografía pasiva |
| Surface | `#F6F4EF` | Fondo de tarjetas y contenedores |
| Background dark | `#1E1F26` | Fondo general oscuro del lienzo o área de presentación |
| Accent glow | `#7C6CFF` | Resaltes, focus ring, borde de énfasis visual |

### Reglas de uso

- Mantener el color `Primary` como eje de acciones importantes.
- Reservar `Secondary` y `Tertiary` para apoyo visual, no para competir con la acción principal.
- Usar neutros para equilibrio visual y para reducir ruido en pantallas con mucha información.
- Aplicar fondos claros dentro de tarjetas para mejorar legibilidad sobre contenedores oscuros.

## Tipografía

### Estilo tipográfico

- Fuente sugerida: sans-serif geométrica o neo-grotesca.
- Alternativas recomendadas: Inter, Manrope, Plus Jakarta Sans, Poppins o Outfit.
- La interfaz muestra contraste entre títulos grandes y texto funcional pequeño.

### Jerarquía recomendada

| Nivel | Tamaño sugerido | Peso | Uso |
|---|---|---|---|
| Heading XL | 40–56 px | 600–700 | Portadas, métricas clave, nombres de módulo |
| Heading L | 28–36 px | 600 | Encabezados de sección |
| Body | 14–16 px | 400–500 | Texto general y formularios |
| Label | 12–14 px | 500–600 | Inputs, tags, controles |
| Caption | 11–12 px | 400 | Ayudas, metadatos, notas secundarias |

## Componentes

### Botones

- Variantes recomendadas: primary, secondary, outline e inverted.
- Bordes suavemente redondeados: 8 a 12 px.
- Altura sugerida: 36 a 44 px.
- El botón principal debe usar fondo `Primary` con texto claro.
- El botón outline debe mantener borde fino y alto contraste.

### Inputs y búsqueda

- Fondo claro con borde tenue.
- Radio de borde: 10 a 14 px.
- Icono alineado a la izquierda en campos de búsqueda.
- Placeholder con color neutral suave.
- Estados necesarios: default, hover, focus, error, disabled.

### Tarjetas

- Superficies claras sobre layout oscuro o neutro.
- Radio de borde amplio: 16 a 24 px.
- Separación interna generosa: 16 a 24 px.
- Sombra sutil o borde tenue para mantener profundidad sin recargar.

### Iconografía

- Íconos lineales o duotono simple.
- Grosor uniforme para toda la librería.
- Mantener consistencia entre navegación, estados y acciones rápidas.

### Etiquetas y chips

- Usar fondos sólidos de bajo contraste o tonos oscuros con texto claro.
- Ideal para estados, categorías o filtros rápidos.
- Padding horizontal generoso para legibilidad.

## Layout

### Estructura

- Usar grid modular con tarjetas independientes.
- Mantener una retícula visual tipo 12 columnas o módulos equivalentes.
- Priorizar espacios amplios entre bloques.
- Diseñar con zonas claramente separadas: navegación, acciones, contenido, estados.

### Espaciado sugerido

| Token | Valor |
|---|---|
| XS | 4 px |
| SM | 8 px |
| MD | 12 px |
| LG | 16 px |
| XL | 24 px |
| 2XL | 32 px |
| 3XL | 40 px |

## Estilo de interacción

- Hover suave con cambios sutiles de color o elevación.
- Focus visible, preferiblemente con halo o borde de acento violeta.
- Transiciones cortas entre 150 y 220 ms.
- Evitar animaciones pesadas; la estética pide fluidez discreta.

## Accesibilidad

- Garantizar contraste suficiente entre texto y fondo.
- No depender solo del color para comunicar estado.
- Mantener áreas táctiles mínimas de 40x40 px.
- Usar labels visibles o accesibles en botones e inputs.

## Aplicación práctica

Este estilo funciona especialmente bien para productos SaaS, dashboards administrativos, apps de salud, gestión de mascotas, inventarios o paneles de operación.

## Tokens base sugeridos

```json
{
  "colors": {
    "primary": "#1A3C40",
    "secondary": "#D4A373",
    "tertiary": "#E99497",
    "neutral": "#767777",
    "surface": "#F6F4EF",
    "background": "#1E1F26",
    "accent": "#7C6CFF"
  },
  "radius": {
    "sm": "8px",
    "md": "12px",
    "lg": "16px",
    "xl": "24px"
  },
  "shadow": {
    "soft": "0 4px 14px rgba(0,0,0,0.08)"
  }
}
```
