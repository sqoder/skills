---
name: liquid-glass-lens
description: >-
  Design and implement authentic Apple-style Liquid Glass effects with realistic physical lens refraction,
  6-tap continuous spectrum dispersion, optical inversion (UV folding 倒像), continuous squircle SDF geometry,
  Blinn-Phong highlight arc, and Fresnel contour edge lighting across macOS, iOS (SwiftUI & Metal), and Web (WebGL 2.0 & TypeScript).
  Supports Desktop Floating Panels (NSPanel with WindowServer penetration), In-App UI Cards/Pills, and WebGL Canvas Refraction.
  Activate whenever the user asks for "liquid glass", "lens refraction", "optical inversion",
  "desktop floating bubble", "glassmorphism with real refraction", "dynamic island glass card", or macOS/iOS/Web refractive UI controls.
---

# Universal Liquid Glass & Lens Refraction Skill

This skill is the **Canonical Reference & Engineering Guide** for implementing authentic **Apple Liquid Glass** across platforms. It provides exact optical formulas, shader code, and architectural patterns for:
1. **macOS Desktop Floating Lens**: Cross-window hardware penetration at 120 FPS without screen recording permissions.
2. **In-App SwiftUI Components**: Readable glass cards, tab bars, navigation pills, and interactive backdrop refraction canvases.
3. **Web / Frontend (TypeScript & WebGL 2.0)**: Zero-dependency browser refraction over any DOM element, image, or canvas.

---

## 🏛 The 3-Layer Glass Architecture Rule

To maintain both authentic physical optics and user interface legibility, **always enforce 3 distinct layers**:

```
┌─────────────────────────────────────────────────────────────┐
│ 3. Foreground Content Layer (前景交互层)                     │
│    - Typography, icons, controls, click targets             │
│    - MUST remain 100% crisp, un-distorted & readable        │
├─────────────────────────────────────────────────────────────┤
│ 2. Lens & Physical Rim Layer (透镜折射与材质边缘层)          │
│    - Continuous squircle SDF (p-norm ~4.2)                  │
│    - 1.5px crisp white Fresnel rim contour                  │
│    - 6-tap continuous spectrum dispersion (Blue→Cyan→Violet)│
│    - Blinn-Phong specular arc highlight                     │
├─────────────────────────────────────────────────────────────┤
│ 1. Backdrop Layer (底层环境折射层)                          │
│    - Underlying desktop windows (macOS Desktop)             │
│    - Underlying app view hierarchy (SwiftUI Canvas)         │
│    - Underlying texture / image (WebGL Canvas)              │
└─────────────────────────────────────────────────────────────┘
```

> [!CAUTION]
> **Anti-Pattern**: Never wrap the entire card (including its own text and buttons) in a high-strength `opticalInversion` shader! Doing so flips the user's text upside-down. The lens refracts the *backdrop*; the *foreground content* floats safely on top.

---

## 🔬 Core Physics & Optical Parameters

### 1. Dual Refraction Modes
* **`foldFree` (Mode 0.0 - UI 控件防撕裂放大)**:
  * Slope is clamped: $m'(s) \in (-1, 0)$. Monotone inward mapping.
  * **Behavior**: Content magnifies smoothly at the rim with continuous spectrum dispersion, **never tears, never inverts, 100% readable**.
  * **Best For**: Tab bars, segmented controls, buttons, cards.
* **`opticalInversion` (Mode 1.0 - 真实物理凸透镜倒像)**:
  * Steep slope exceeding $-1$ ($m'(s) < -1$). The UV sampling map folds over itself.
  * **Behavior**: Thick convex lens optics. Underlying text sliding beneath the rim **inverts upside down**, horizontal dots split into dual rows, and shapes stretch along contour curves.
  * **Best For**: Magnifying lenses, desktop floating bubbles, playful interactive canvases.

### 2. 6-Tap Continuous Spectrum Dispersion
Instead of crude 3-tap RGB offsets (which produce harsh red/green chromatic fringing), sample 6 continuous spectral wavelengths from 380nm to 750nm (Red, Amber, Yellow-Green, Cyan, Blue, Violet). This produces Apple's signature smooth **Blue → Cyan → Violet** chromatic sheen.

### 3. 20° Tangential Shear
Refraction rays do not point strictly toward the center. Introducing a $20^\circ$ tangential component ($-\vec{N}\cos 20^\circ + \vec{T}\sin 20^\circ$) causes the distortion to sweep along the rim contour, creating an organic, fluid surface tension.

### 4. iOS Squircle Continuous Curvature
Use p-norm ($p \approx 4.2$) distance fields:
$$\|q\|_p = (|q_x|^p + |q_y|^p)^{1/p}$$
This eliminates tangent discontinuities where arcs meet straight edges.

---

## 🛠 Platform Implementation Recipes

### Recipe 1: macOS Desktop Floating Lens (`DesktopGlassLens`)
For a system-wide floating lens that hovers over other desktop apps (Xcode, Safari, Finder, Wallpaper) with **zero screen recording permissions**:

```swift
import LiquidGlassKit

// 1. Pure floating glass bubble
DesktopGlassLens.shared.showCircle(diameter: 220)

// 2. Custom floating panel with foreground content
DesktopGlassLens.shared.show(
    width: 320,
    height: 160,
    cornerRadius: 28
) {
    VStack(spacing: 6) {
        Image(systemName: "sparkles").font(.title)
        Text("Desktop Lens").font(.headline)
    }
    .foregroundColor(.white)
}
```

*Key Mechanics*:
* `NSPanel` with `.borderless, .nonactivatingPanel`, `level = .floating`.
* `isMovableByWindowBackground = true` for zero-code drag-and-drop anywhere on the desktop.
* Uses Apple's WindowServer compositor penetration via `NSGlassEffectView` + `CABackdropLayer.windowServerAware = true`.

---

### Recipe 2: In-App SwiftUI UI Components (Readable Cards & Pills)

```swift
import SwiftUI
import LiquidGlassKit

// Liquid Glass Card (Protects foreground text from distortion)
LiquidGlassCard(config: .cardPreset) {
    VStack(alignment: .leading, spacing: 10) {
        Text("Glass Card Title")
            .font(.headline)
            .foregroundColor(.white)
        Text("Foreground text remains crisp while edges refract.")
            .font(.caption)
            .foregroundColor(.white.opacity(0.8))
    }
    .padding(20)
}

// Liquid Glass Pill (TabBar / Capsule Button)
LiquidGlassPill(config: .foldFreePreset) {
    HStack(spacing: 20) {
        Image(systemName: "house.fill")
        Image(systemName: "magnifyingglass")
        Image(systemName: "person.crop.circle")
    }
    .foregroundColor(.white)
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
}
```

---

### Recipe 3: In-App SwiftUI True Backdrop Refraction Canvas

When you want an in-app lens to physically refract and invert background elements (images, typography, lists) as it moves:

```swift
LiquidGlassCanvas(
    lensCenter: lensPosition,
    lensSize: CGSize(width: 300, height: 160),
    config: .opticalInversionPreset
) {
    // Backdrop content (Images, text, color blocks)
    MyBackdropView()
} overlay: {
    // Controls floating above the lens (e.g. drag handle)
    MyOverlayView()
}
```

---

### Recipe 4: Web / Frontend (TypeScript & WebGL 2.0)

```typescript
import { LiquidGlassLens } from 'liquid-glass-ts';

const canvas = document.getElementById('webgl-canvas') as HTMLCanvasElement;

const lens = new LiquidGlassLens(canvas, {
  width: 360,
  height: 180,
  bezel: 22,
  strength: 32,
  mode: 'opticalInversion', // or 'foldFree'
  dispersion: 0.90,
  fresnelRim: 0.85,
  draggable: true
});

// Pass any image, canvas, or video frame as backdrop
const image = new Image();
image.src = '/assets/backdrop.jpg';
image.onload = () => lens.setBackdrop(image);
```

---

## 📐 Mathematical Reference: Metal & GLSL Shader

```metal
// Normal via central differences on Continuous Squircle SDF
const float e = 1.0;
float dx = sdContinuousBox(p + float2(e, 0.0), halfExtents, r, cornerExponent)
         - sdContinuousBox(p - float2(e, 0.0), halfExtents, r, cornerExponent);
float dy = sdContinuousBox(p + float2(0.0, e), halfExtents, r, cornerExponent)
         - sdContinuousBox(p - float2(0.0, e), halfExtents, r, cornerExponent);
float2 normalDir = normalize(float2(dx, dy) + float2(1e-6, 0.0));

// Dual displacement profile
float k = min(2.0 * strength / safeBezel, 0.88);
float magFoldFree = 0.5 * k * safeBezel * edge * edge;
float magInversion = strength * (pow(edge, 1.6) + 1.35 * pow(edge, 3.2));
float m = mix(magFoldFree, magInversion, clamp(mode, 0.0, 1.0));

// 20° Tangential shear
float2 inward = -normalDir;
float2 tangent = float2(-normalDir.y, normalDir.x);
float2 baseOffset = (inward * 0.9397 + tangent * 0.3420) * m;

// 6-Tap Spectral Dispersion
for (int i = 0; i < 6; ++i) {
    float u = float(i) / 5.0;
    float f = 1.0 + dispersion * 0.18 * edge * (2.0 * u - 1.0);
    half4 tap = layer.sample(position + baseOffset * f);
    col.rgb += tap.rgb * weights[i];
}

// Crisp Fresnel hairline (0.0 to 3.5px boundary)
half hairline = half((1.0 - smoothstep(0.0, 3.5, inside)) * fresnel * 0.95);
col.rgb += half3(specLobe + hairline);
```
