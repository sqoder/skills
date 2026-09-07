---
name: liquid-glass-lens
description: >-
  Design and implement Apple-style Liquid Glass effects with realistic physical lens refraction,
  6-tap continuous spectrum dispersion, optical inversion (UV folding 倒像), continuous squircle SDF geometry,
  Blinn-Phong highlight arc, and Fresnel contour edge lighting in SwiftUI & Metal.
  Supports both In-App SwiftUI components AND Desktop Floating Panels/Bubbles (NSPanel with WindowServer penetration).
  Activate whenever the user asks for "liquid glass", "lens refraction", "optical inversion",
  "desktop floating bubble", "glassmorphism with real refraction", "dynamic island glass card", or macOS/iOS refractive UI controls.
---

# Universal Liquid Glass & Lens Refraction Skill

This skill provides the complete architecture, optical formulas, Metal shaders, and macOS/iOS APIs to produce authentic **Apple Liquid Glass** with realistic fluid-like lens refraction, 6-tap continuous spectrum dispersion, and optical inversion.

---

## 1. Dual Deployment Modes

### Mode 1: Desktop Floating Bubble / Overlay (`NSPanel` + WindowServer)
When you need a **floating bubble, floating pill, or Dynamic Island on the macOS desktop** that moves across the screen and **refracts real underlying windows (Safari, Xcode, Finder, Wallpaper)**:

* **No Screen Recording Permission Needed**: Uses Apple's hardware compositor bridge via `CABackdropLayer.windowServerAware = true`.
* **Hardware Compositor Performance**: Runs directly in macOS WindowServer at 120 FPS.
* **Panel Configuration**:
  ```swift
  let panel = NSPanel(
      contentRect: NSRect(x: x, y: y, width: size, height: size),
      styleMask: [.borderless, .nonactivatingPanel],
      backing: .buffered,
      defer: false
  )
  panel.isOpaque = false
  panel.backgroundColor = .clear
  panel.level = .floating
  panel.isMovableByWindowBackground = true
  panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
  ```
* **WindowServer Glass Penetration Core**:
  ```swift
  // NSGlassEffectView + windowServerAware
  let glass = NSClassFromString("NSGlassEffectView")!.init(frame: .zero)
  glass.setValue(cornerRadius, forKey: "cornerRadius")
  glass.perform(NSSelectorFromString("set_variant:"), with: 11) // v11: Apple Ultra Liquid Glass
  glass.perform(NSSelectorFromString("set_contentLensing:"), with: 1) // Content Lensing (Refraction & Inversion)

  // Activate hardware backdrop in layer tree
  func configureBackdrop(in layer: CALayer) {
      if NSStringFromClass(type(of: layer)).contains("CABackdropLayer") {
          layer.setValue(true, forKey: "windowServerAware")
          layer.setValue(1.0, forKey: "scale")
      }
      layer.sublayers?.forEach { configureBackdrop(in: $0) }
  }
  ```

---

### Mode 2: In-App SwiftUI Component (`layerEffect` + Metal Shader)
When you need an in-app card, button, or TabBar with custom refraction, 6-tap dispersion, and optical inversion:
* Apply `.liquidGlassLens(.opticalInversionPreset)` or `.liquidGlassLens(.foldFreePreset)`.
* Uses `LiquidGlassLens.metal` via `view.layerEffect(...)`.

---

## 2. Core Physics & Optical Concepts

### 2.1 Optical Inversion vs. Fold-Free Magnification
When light passes through a convex glass bevel (lens rim), the inward sampling offset $m(s)$ determines whether underlying content stays readable or inverts like a real thick magnifying glass:

* **Fold-Free Magnification (`mode = 0.0`)**
  * **Behavior**: Slope is strictly clamped: $m'(s) \in (-1, 0)$. Monotone inward mapping.
  * **Result**: Content magnifies smoothly at the rim with continuous spectrum dispersion, **never tears, never inverts, remains 100% legible**.
  * **Best For**: Tab bars, segmented controls, interactive buttons, navigation pills.
* **Optical Inversion (`mode = 1.0`, 截图同款倒立翻转)**
  * **Behavior**: Slope exceeds $-1$ at the rim ($m'(s) < -1$). The UV sampling map folds over itself.
  * **Result**: Real thick convex lens behavior. Text sliding beneath the bevel **inverts upside-down**, horizontal dots **split into double rows**, and shapes stretch into curved contours.
  * **Best For**: Dynamic Island overlays, desktop floating bubbles, status bar lenses.

### 2.2 6-Tap Continuous Spectrum Dispersion
Instead of crude 3-tap RGB offsets (which produce unnatural harsh pure green/red fringes), use a 6-tap continuous spectrum from red through orange, amber, yellow-green, cyan, blue, to violet. This delivers Apple's smooth **blue → cyan → magenta** chromatic sheen.

### 2.3 20° Tangential Shear
Refraction rays do not point strictly toward the center. Introducing a $20^\circ$ tangential component ($-\vec{N} \cos 20^\circ + \vec{T} \sin 20^\circ$) causes the distortion to visibly **sweep along the rim contour**, making the glass feel alive and fluid.

### 2.4 iOS Continuous Curvature (Squircle)
Standard Euclidean rounded rectangles have discontinuous curvature where arcs meet straight edges. Use p-norm ($p \approx 4.2$) distance fields:
$$\|q\|_p = (|q_x|^p + |q_y|^p)^{1/p}$$

---

## 3. Production Metal Shader (`LiquidGlassLens.metal`)

```metal
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

static float sdContinuousBox(float2 p, float2 b, float r, float n) {
    float2 q = abs(p) - b;
    if (n <= 2.02) {
        return length(max(q, float2(0.0))) + min(max(q.x, q.y), 0.0) - r;
    } else {
        float2 m = max(q, float2(0.0));
        float s = pow(m.x, n) + pow(m.y, n);
        float outside = (s > 0.0) ? pow(s, 1.0 / n) : 0.0;
        return min(max(q.x, q.y), 0.0) + outside - r;
    }
}

[[ stitchable ]] half4 liquidGlassLens(
    float2 position,
    SwiftUI::Layer layer,
    float2 boundsSize,
    float cornerRadius,
    float cornerExponent,
    float bezel,
    float strength,
    float mode,
    float dispersion,
    float fresnel,
    float specular,
    float lightAngle
) {
    float2 center = boundsSize * 0.5;
    float2 p = position - center;

    float minHalf = min(boundsSize.x, boundsSize.y) * 0.5;
    float r = (cornerRadius < 0.0) ? minHalf : min(cornerRadius, minHalf);
    float2 halfExtents = max(boundsSize * 0.5 - float2(r), float2(0.0));

    float d = sdContinuousBox(p, halfExtents, r, cornerExponent);
    if (d > 1.5) return layer.sample(position);

    float inside = -d;
    float safeBezel = max(bezel, 1.0);
    float t = clamp(inside / safeBezel, 0.0, 1.0);
    float edge = 1.0 - t;

    // Normal via central difference
    const float e = 1.0;
    float dx = sdContinuousBox(p + float2(e, 0.0), halfExtents, r, cornerExponent)
             - sdContinuousBox(p - float2(e, 0.0), halfExtents, r, cornerExponent);
    float dy = sdContinuousBox(p + float2(0.0, e), halfExtents, r, cornerExponent)
             - sdContinuousBox(p - float2(0.0, e), halfExtents, r, cornerExponent);
    float2 normalDir = normalize(float2(dx, dy) + float2(1e-6, 0.0));

    // Profile selection
    float k = min(2.0 * strength / safeBezel, 0.88);
    float magFoldFree = 0.5 * k * safeBezel * edge * edge;
    float magInversion = strength * (pow(edge, 1.6) + 1.35 * pow(edge, 3.2));
    float m = mix(magFoldFree, magInversion, clamp(mode, 0.0, 1.0));

    // Tangential shear
    float2 inward = -normalDir;
    float2 tangent = float2(-normalDir.y, normalDir.x);
    float2 baseOffset = (inward * 0.9397 + tangent * 0.3420) * m;

    // 6-Tap continuous spectrum
    float spread = dispersion * 0.18 * edge;
    constexpr int TAPS = 6;
    const float3 weights[TAPS] = {
        float3(1.00, 0.05, 0.00),
        float3(1.00, 0.58, 0.00),
        float3(0.50, 1.00, 0.15),
        float3(0.00, 1.00, 0.70),
        float3(0.12, 0.35, 1.00),
        float3(0.65, 0.00, 0.85)
    };
    const float sumR = 3.27, sumG = 2.93, sumB = 2.70;

    half4 col = half4(0.0);
    for (int i = 0; i < TAPS; ++i) {
        float u = float(i) / float(TAPS - 1);
        float f = 1.0 + spread * (2.0 * u - 1.0);
        half4 tap = layer.sample(position + baseOffset * f);
        col.r += tap.r * half(weights[i].r);
        col.g += tap.g * half(weights[i].g);
        col.b += tap.b * half(weights[i].b);
        col.a += tap.a * half(1.0 / float(TAPS));
    }
    col.r /= half(sumR);
    col.g /= half(sumG);
    col.b /= half(sumB);

    // Specular arc & Fresnel rim hairline
    float2 L = normalize(float2(cos(lightAngle), sin(lightAngle)));
    float dotNL = max(dot(normalDir, -L), 0.0);
    float arcWindow = exp(-pow((edge - 0.22) / 0.18, 2.0));
    half specLobe = half(pow(dotNL, 18.0) * arcWindow * specular);
    half hairline = half((1.0 - smoothstep(0.0, 3.5, inside)) * fresnel * 0.95);
    float counterRim = max(dot(normalDir, L), 0.0) * edge * 0.14;

    col.rgb += half3(specLobe + hairline);
    col.rgb = max(col.rgb - half3(counterRim * col.a), half3(0.0));

    float coverage = clamp(inside + 0.5, 0.0, 1.0);
    return mix(layer.sample(position), col, half(coverage));
}
```

---

## 4. Quick API Reference

```swift
// 1. Launch a real desktop floating bubble
DesktopGlassBubble.shared.show(size: 220)

// 2. Or apply to any SwiftUI in-app view
MyCard()
    .liquidGlassLens(.opticalInversionPreset)
```
