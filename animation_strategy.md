# Animation Strategy Guide — Decisiones de Stack para la IA

> **Propósito:** Este documento define qué tecnologías y bibliotecas debe usar la IA al implementar animaciones en este proyecto. Es la guía de alto nivel para elegir el enfoque correcto según el tipo de animación.

---

## 1. Stack oficial para animaciones

**Proyecto:** Gestor Móvil de Salud para Mascotas  
**Framework:** Flutter (Android + iOS)  
**Objetivo de rendimiento:** 60 FPS estables, 120 FPS en dispositivos compatibles  

### Regla fundamental

**Flutter es el stack elegido.** No se usará React Native, motores de juego (Unity/Unreal), ni soluciones web/PWA para animaciones. Todo el código de animación debe implementarse con las herramientas nativas de Flutter.

### Justificación

Flutter usa su propio motor de renderizado (**Impeller** desde Flutter 3.22+, con Skia como fallback) que:
- Controla todo el pipeline de dibujo sin puente JS
- Soporta 120 FPS automáticamente en dispositivos compatibles (ProMotion, Android 120 Hz)
- Ofrece herramientas de diagnóstico integradas (Flutter DevTools)
- Elimina el "shader compilation jank" con Impeller

---

## 2. Árbol de decisión para animaciones

Usa este árbol para elegir la tecnología correcta según el caso:

```
┌─ ¿Es una transición entre pantallas?
│   ├─ Sí → Usa GoRouter con CustomTransitionPage + FadeTransition / SlideTransition
│   └─ No → Sigue al siguiente nivel
│
├─ ¿Es un cambio de estado simple (color, tamaño, opacidad, posición)?
│   ├─ Sí → Usa widgets de alto nivel: AnimatedContainer, AnimatedOpacity, 
│   │         AnimatedPositioned, AnimatedPadding, AnimatedAlign, AnimatedSwitcher
│   └─ No → Sigue al siguiente nivel
│
├─ ¿Es una animación controlada por gestos (arrastrar, deslizar, pellizcar)?
│   ├─ Sí → Usa AnimationController + AnimatedBuilder + GestureDetector
│   └─ No → Sigue al siguiente nivel
│
├─ ¿Es una animación compleja (partículas, físicas, gráficos 2D)?
│   ├─ Sí → Usa CustomPainter + Canvas + AnimationController
│   └─ No → Sigue al siguiente nivel
│
├─ ¿Es una animación compartida entre pantallas?
│   ├─ Sí → Usa Hero widget (prioridad alta para este caso)
│   └─ No → Sigue al siguiente nivel
│
├─ ¿Es una secuencia de varios pasos (ej. escalar → desvanecer → mover)?
│   ├─ Sí → Usa TweenSequence + TweenSequenceItem
│   └─ No → Usa AnimationController + Tween personalizado
│
└─ ¿Necesitas personalizar la duración de animaciones Material en toda la app?
    ├─ Sí → Usa AnimationStyle en el tema global (ThemeData)
    └─ No → Usa AnimationController con duración explícita
```

---

## 3. Tecnologías específicas y cuándo usarlas

### 3.1. Widgets de alto nivel (prioridad máxima)

Usar estos widgets **antes** de escribir animaciones personalizadas:

| Widget | Caso de uso | Rendimiento |
|---|---|---|
| `AnimatedContainer` | Transiciones de color, tamaño, padding, borde | Óptimo — GPU |
| `AnimatedOpacity` | Fade in/out | Óptimo — GPU |
| `AnimatedPositioned` | Movimiento dentro de Stack | Óptimo — GPU |
| `AnimatedPadding` | Espaciado animado | Óptimo — GPU |
| `AnimatedAlign` | Alineación animada | Óptimo — GPU |
| `AnimatedSwitcher` | Transición entre widgets diferentes | Óptimo — GPU |
| `Hero` | Transiciones compartidas entre pantallas | Óptimo — GPU |
| `AnimatedList` | Listas con inserciones/eliminaciones animadas | Bueno |
| `TweenAnimationBuilder` | Animaciones declarativas con interpolación | Óptimo — GPU |
| `AnimatedScale` | Escalado animado | Óptimo — GPU |
| `AnimatedSlide` | Deslizamiento animado por fracciones | Óptimo — GPU |
| `TweenSequence` | Secuencias multi-paso (escalar → fade → mover) | Óptimo — GPU |

### 3.2. AnimationController + AnimatedBuilder (control fino)

Usar cuando los widgets de alto nivel no cubran el caso exacto.

```dart
// Patrón correcto
AnimationController(
  duration: Duration(milliseconds: 300),
  vsync: this, // Siempre usar SingleTickerProviderStateMixin
);
```

- Siempre hacer `dispose()` del controller en `dispose()`
- Usar `CurvedAnimation` con curvas suaves (`Curves.easeInOut`, `Curves.easeOutCubic`, `Curves.fastEaseInToSlowEaseOut`)
- Duración recomendada: **200–350 ms** para transiciones de UI

### 3.3. CustomPainter + Canvas (máximo rendimiento)

Usar para:
- Escenas con partículas
- Gráficos 2D animados (charts, timelines)
- Fondos animados
- Cualquier cosa que requiera dibujar a bajo nivel

```dart
class MiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) { /* dibujar */ }
  
  @override
  bool shouldRepaint(covariant MiPainter old) {
    return old.prop != prop; // NUNCA true fijo
  }
}
```

### 3.4. Transiciones entre pantallas

Usar `GoRouter` + `CustomTransitionPage`:

```dart
GoRoute(
  path: '/detail',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: DetailScreen(),
    transitionsBuilder: (context, anim, secondaryAnim, child) {
      return FadeTransition(opacity: anim, child: child);
    },
  ),
)
```

### 3.5. AnimationStyle (Material 3 global)

Para personalizar la duración de animaciones Material en todo el tema:

```dart
ThemeData(
  useMaterial3: true,
  animationStyle: AnimationStyle(
    duration: Duration(milliseconds: 250),
    curve: Curves.easeInOut,
  ),
)
```

Esto evita tener que configurar la duración en cada widget Material individualmente.

### 3.6. TweenSequence (animaciones multi-paso)

Para secuencias de animación con varias fases:

```dart
final sequence = TweenSequence<double>([
  TweenSequenceItem(
    tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
    weight: 50, // 50% del tiempo total
  ),
  TweenSequenceItem(
    tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)),
    weight: 50,
  ),
]);
```

---

## 4. Optimizaciones obligatorias

Toda animación implementada por la IA debe incluir:

### 4.1. Aislar el repintado

```dart
RepaintBoundary(
  child: /* widget animado */,
)
```

### 4.2. Evitar rebuilds masivos

- ✅ Usar `const` constructores en widgets que no cambian
- ✅ Extraer widgets animados a componentes separados
- ✅ Pasar `child` a `AnimatedBuilder` para evitar reconstruir el subárbol
- ❌ No llamar `setState()` en cada frame de animación
- ❌ No poner lógica pesada dentro de `build()`

### 4.3. Optimizar imágenes en animaciones

- Usar `cacheWidth` y `cacheHeight` en `Image.asset()` al tamaño exacto de visualización
- Precargar imágenes con `precacheImage()` antes de animaciones que las usen

### 4.4. Gestos de alta frecuencia

```dart
GestureDetector(
  onPanUpdate: (details) {
    _controller.value += details.delta.dx / context.size!.width;
  },
  child: AnimatedBuilder(
    animation: _controller,
    builder: (context, child) => Transform.translate(
      offset: Offset(_controller.value * 100, 0),
      child: child,
    ),
    child: myWidget, // ← No se reconstruye en cada frame
  ),
)
```

---

## 5. Lo que la IA NO debe hacer

| ❌ No hacer | ✅ Alternativa |
|---|---|
| Usar `Opacity` widget en animaciones | Usar `AnimatedOpacity` o `FadeTransition` |
| Usar `ClipRRect` o `ClipPath` sin `RepaintBoundary` | Envolver clipping en `RepaintBoundary` |
| Anidar múltiples `AnimatedBuilder` | Un solo `AnimatedBuilder` con `Transform` |
| Llamar `setState()` dentro del builder de animación | Usar el valor del `Animation` directamente |
| Crear objetos `Paint`, `Path` en cada frame | Crearlos en `initState()` y reutilizarlos |
| Usar `LayoutBuilder` dentro de animaciones | Calcular layout fuera del ciclo de animación |

---

## 6. Verificación de calidad

Antes de dar una animación por terminada, la IA debe verificar:

1. ✅ `flutter analyze` — sin errores ni warnings
2. ✅ No hay widgets sin `const` donde sea posible
3. ✅ El `AnimationController` se dispone correctamente
4. ✅ No hay `setState()` innecesario en el ciclo de animación
5. ✅ Las duraciones están entre 200–350 ms para transiciones de UI
6. ✅ Las curvas de animación son suaves (no lineales)
7. ✅ Las animaciones se probaron en **profile mode** (`flutter run --profile`), no en debug mode (debug tiene rendimiento artificialmente bajo)

---

## 7. Referencias

- `animation_guidelines.md` — Guía técnica detallada con ejemplos de código
- Flutter DevTools para diagnóstico de rendimiento
- Impeller como motor de renderizado activo (Flutter 3.44.1+)
