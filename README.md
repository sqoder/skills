# LiquidGlassKit 💧✨

> **Apple-style Liquid Glass Lens Refraction with Optical Inversion, 6-Tap Spectral Dispersion, and macOS Desktop WindowServer Penetration.**

A production-grade Swift Package and Metal Shader engine delivering authentic physical glass refraction for **macOS** and **iOS**.

---

## 🌟 Key Features

1. **Desktop Floating Bubble (`NSPanel` + WindowServer)**
   * Draggable floating bubble on the macOS desktop that floats above all apps.
   * **Direct WindowServer hardware composition**: Real-time 120 FPS refraction over Safari, Xcode, Finder, and wallpaper.
   * **Zero screen recording permissions required!**
2. **True Optical Inversion & Dual Displacement Modes**
   * **Mode A (`.opticalInversion`)**: High-curvature convex lens. The sampling map folds over itself, causing text underneath to invert upside down and horizontal dots to split into dual rows.
   * **Mode B (`.foldFree`)**: Slope-clamped monotone mapping for readable UI controls (TabBars, buttons, segmented controls).
3. **6-Tap Continuous Spectrum Dispersion**
   * Smooth blue → cyan → magenta chromatic sheen along the rim contour, eliminating crude red/green banding.
4. **20° Tangential Shear**
   * Refraction rays sweep along the edge contour, giving the glass an organic, fluid-like surface tension.
5. **iOS Squircle & Capsule Geometry**
   * Continuous curvature distance fields ($p \approx 4.2$) avoiding sharp curvature breaks.
6. **Built-in Antigravity / AI Skill**
   * Ready-to-use `SKILL.md` in `skills/liquid-glass-lens/` so AI assistants can automatically generate and configure liquid glass components in any project.

---

## 🚀 Quick Start & Live Desktop Demo

Clone the repo and launch the desktop glass bubble immediately:

```bash
git clone https://github.com/sqoder/LiquidGlassKit.git
cd LiquidGlassKit
swift run LiquidGlassDemo
```

A crystal-clear liquid glass bubble will rise on your Mac desktop. Click and drag it over any open window to see real-time physical lens refraction and optical inversion!

---

## 📦 Installation

Add **LiquidGlassKit** via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/sqoder/LiquidGlassKit.git", from: "1.0.0")
]
```

---

## 🛠 Usage Examples

### 1. Launch a Real macOS Desktop Floating Bubble
```swift
import AppKit
import LiquidGlassKit

// Elevate a floating glass bubble on your Mac desktop
DesktopGlassBubble.shared.show(size: 220)
```

### 2. Apply to Any In-App SwiftUI View
```swift
import SwiftUI
import LiquidGlassKit

struct MyGlassCard: View {
    var body: some View {
        Text("Dynamic Island Card")
            .padding()
            .background(RoundedRectangle(cornerRadius: 24).fill(.ultraThinMaterial))
            // Apply authentic liquid glass lens effect
            .liquidGlassLens(.opticalInversionPreset)
    }
}
```

### 3. Custom Optical Tuning
```swift
MyView()
    .liquidGlassLens(
        bezel: 18.0,              // Rim thickness in points
        strength: 28.0,           // Refraction amplitude
        mode: .opticalInversion,  // .opticalInversion (lens flip) or .foldFree (legible)
        dispersion: 0.85,         // 6-tap spectral dispersion
        fresnelRim: 0.75,         // Crisp white rim highlight
        cornerRadius: 28.0
    )
```

---

## 📄 License

MIT © 2026 [sqoder](https://github.com/sqoder)
