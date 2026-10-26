# LiquidGlassKit 💧✨

> **Canonical Apple-style Liquid Glass Lens Refraction, 6-Tap Spectral Dispersion, and Optical Inversion.**
> 
> Available for **Swift & Metal (macOS & iOS)** and **TypeScript & WebGL 2.0 (Web & Frontend)**.
> Designed as the **Golden Reference Repository** for developers and AI agents to implement liquid glass effects across platforms.

---

## 🌟 The 3-Layer Glass Architecture

To ensure both realistic physical optics and interface usability, LiquidGlassKit enforces a strict 3-layer separation:

```
┌─────────────────────────────────────────────────────────────┐
│ 3. Foreground Content Layer (前景交互层)                     │
│    - Typography, icons, and action buttons                  │
│    - 100% crisp, sharp, un-distorted & interactive         │
├─────────────────────────────────────────────────────────────┤
│ 2. Lens & Physical Rim Layer (透镜与材质边缘层)             │
│    - Continuous squircle curvature (p-norm ~4.2)            │
│    - Crisp Fresnel white hairline contour (~1.5px)          │
│    - 6-tap continuous spectrum dispersion (Blue→Cyan→Violet)│
│    - Blinn-Phong specular highlight arc                     │
├─────────────────────────────────────────────────────────────┤
│ 1. Backdrop Layer (底层折射环境层)                          │
│    - Underlying desktop windows / wallpaper (macOS)         │
│    - Underlying app view hierarchy (SwiftUI Canvas)         │
│    - Underlying image / canvas element (WebGL 2.0)          │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
LiquidGlassKit/
├── Package.swift                 # Swift Package Manager manifest
├── Sources/
│   ├── LiquidGlassKit/          # Core Native Library (macOS & iOS)
│   │   ├── DesktopGlassBubble.swift   # DesktopGlassLens (macOS WindowServer floating lens)
│   │   ├── LiquidGlassCard.swift      # 3-Layer LiquidGlassCard & LiquidGlassPill
│   │   ├── LiquidGlassContainer.swift # LiquidGlassCanvas (In-app backdrop refraction)
│   │   ├── LiquidGlassConfiguration.swift # Config presets (card, tabBar, opticalInversion)
│   │   ├── LiquidGlassModifier.swift  # SwiftUI ViewModifier (.liquidGlassLens)
│   │   └── Shaders/LiquidGlassLens.metal # MSL Core Shader (SDF, Snell's Law, 6-Tap Dispersion)
│   └── LiquidGlassDemo/         # Standalone Native macOS Studio & Desktop Launcher
├── web/                         # TypeScript + WebGL 2.0 Web Engine
│   ├── src/
│   │   ├── shaders.ts           # WebGL 2.0 GLSL Shaders (1:1 with Metal Shader)
│   │   ├── LiquidGlassRenderer.ts # WebGL 2.0 multi-pass pipeline
│   │   ├── LiquidGlassLens.ts   # Interactive TypeScript controller
│   │   └── main.ts              # Interactive Web gallery demo
│   ├── index.html
│   └── package.json
└── skills/
    └── liquid-glass-lens/
        └── SKILL.md             # Canonical AI Agent specification & code recipes
```

---

## 🍏 1. Swift & Metal (macOS / iOS)

### 🚀 Run the Native macOS Demo
```bash
swift run LiquidGlassDemo
```
Launches the **LiquidGlassKit Studio**:
1. **In-App Canvas**: Drag the lens over rich typography and geometric graphics to witness real-time optical inversion and 6-tap dispersion.
2. **Desktop Floating Lens**: Click "在桌面升起悬浮透镜" to launch a crystal-clear glass lens that hovers over Xcode, Safari, Terminal, and desktop wallpaper with real-time hardware compositor penetration.

### 📦 Installation
```swift
dependencies: [
    .package(url: "https://github.com/sqoder/skills.git", branch: "LiquidGlassKit")
]
```

### 🔧 Modifying the Shader

`Shaders/default.metallib` is a **precompiled** binary that SwiftPM copies verbatim (it does not compile `.metal` files). After editing `LiquidGlassLens.metal` you must regenerate it, otherwise the app keeps loading the stale shader:

```bash
./scripts/build-metallib.sh          # regenerate default.metallib
./scripts/build-metallib.sh --check  # verify it is in sync (exit 1 if not)
```

### 🛠 Core Recipes for Swift

#### Recipe A: macOS Desktop Floating Lens
```swift
import LiquidGlassKit

// 1. Pure magnifying bubble
DesktopGlassLens.shared.showCircle(diameter: 240)

// 2. Or a floating lens panel with custom foreground content
DesktopGlassLens.shared.show(width: 320, height: 160, cornerRadius: 28) {
    HStack {
        Image(systemName: "waveform.circle.fill").font(.title)
        Text("Playing Audio").font(.headline)
    }
    .foregroundColor(.white)
}
```

#### Recipe B: In-App UI Card / Pill (Readable UI Controls)
```swift
import SwiftUI
import LiquidGlassKit

// Liquid Glass Card (Protects foreground text from distortion)
LiquidGlassCard(config: .cardPreset) {
    VStack(alignment: .leading, spacing: 8) {
        Text("Glass Card").font(.headline)
        Text("Text remains 100% crisp while borders refract.")
            .font(.caption).opacity(0.8)
    }
    .padding(20)
}

// Liquid Glass Pill (Perfect for TabBars & Floating Action Buttons)
LiquidGlassPill(config: .foldFreePreset) {
    HStack(spacing: 16) {
        Image(systemName: "house.fill")
        Image(systemName: "magnifyingglass")
        Image(systemName: "gearshape.fill")
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
}
```

#### Recipe C: In-App True Backdrop Refraction
```swift
LiquidGlassCanvas(
    lensCenter: lensPosition,
    lensSize: CGSize(width: 240, height: 140),
    config: .opticalInversionPreset
) {
    // Backdrop content being refracted (Images, text, lists)
    MyBackdropView()
} overlay: {
    // Controls floating above the lens
    MyHandleView()
}
```

---

## 🌐 2. TypeScript & WebGL 2.0 (Web / Frontend)

A zero-dependency TypeScript implementation bringing the exact same physical lens refraction, optical inversion, and 6-tap spectral dispersion directly to Web apps (React, Vue, HTML5 Canvas).

### 🚀 Run the Web Demo
```bash
cd web
pnpm install
pnpm run dev
```
Open `http://localhost:5173` to interact with the live browser demo. Drag the liquid glass lens over typography and graphic cards to see real-time optical inversion, text flipping, and continuous spectrum dispersion in action!

### 🛠 Usage in TypeScript
```typescript
import { LiquidGlassLens } from './src';

const canvas = document.getElementById('my-canvas') as HTMLCanvasElement;

const lens = new LiquidGlassLens(canvas, {
  width: 360,
  height: 180,
  bezel: 22,
  strength: 32,
  mode: 'opticalInversion', // 'opticalInversion' (lens flip) | 'foldFree' (readable)
  dispersion: 0.90,
  fresnelRim: 0.85,
  draggable: true
});

// Provide any backdrop image, video, or canvas
const image = new Image();
image.src = '/backdrop.png';
image.onload = () => lens.setBackdrop(image);
```

---

## 🔬 Optical Physics Specifications

1. **Dual Refraction Modes**:
   - **`opticalInversion` (1.0)**: Steep slope crossing the fold threshold ($m'(s) < -1$), causing real physical optical inversion (upside-down mirroring of underlying content).
   - **`foldFree` (0.0)**: Monotonic slope clamp ($m'(s) \in (-1, 0)$), ensuring UI legibility for buttons and navigation bars while delivering chromatic edge sheen.
2. **6-Tap Continuous Spectrum Dispersion**:
   - Samples 6 spectral wavelengths from 380nm to 750nm (Red, Amber, Yellow-Green, Cyan, Blue, Violet) to produce Apple's signature smooth Blue → Cyan → Violet sheen without harsh RGB fringing.
3. **20° Tangential Shear**:
   - Inward displacement is rotated by 20° along the boundary tangent ($-\vec{N}\cos 20^\circ + \vec{T}\sin 20^\circ$), giving fluid-like surface tension.
4. **iOS Squircle Continuous Curvature**:
   - Analytic distance field using p-norm ($p \approx 4.2$) for continuous curvature without corner seams.

---

## 📄 License

MIT © 2026 [sqoder](https://github.com/sqoder)
