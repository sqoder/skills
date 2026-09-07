# LiquidGlassKit 💧✨

> **Apple-style Liquid Glass Lens Refraction with Optical Inversion, 6-Tap Spectral Dispersion, and macOS Desktop WindowServer Penetration.**
> 
> Available for **Swift & Metal (macOS & iOS)** and **TypeScript & WebGL 2.0 (Web & Frontend)**.

---

## 🌟 Repository Structure

This repository provides authentic physical liquid glass lens refraction across platforms:

```
LiquidGlassKit/
├── Package.swift                 # Swift Package Manager manifest
├── Sources/
│   ├── LiquidGlassKit/          # Swift / Metal Core Library (macOS & iOS)
│   │   ├── DesktopGlassBubble.swift   # WindowServer hardware penetration floating bubble
│   │   ├── LiquidGlassModifier.swift  # SwiftUI ViewModifier (.liquidGlassLens)
│   │   ├── LiquidGlassCard.swift      # Floating Dynamic Island Card container & Demo
│   │   └── Shaders/LiquidGlassLens.metal # MSL Core Shader (SDF, Snell's Law, 6-Tap Dispersion)
│   └── LiquidGlassDemo/         # Standalone native macOS Desktop executable
├── web/                         # TypeScript + WebGL 2.0 implementation
│   ├── src/
│   │   ├── shaders.ts           # WebGL 2.0 GLSL Shaders (1:1 translation of Metal Shader)
│   │   ├── LiquidGlassRenderer.ts # WebGL 2.0 rendering pipeline
│   │   └── LiquidGlassLens.ts   # High-level TypeScript controller with drag support
│   ├── index.html               # Interactive Web demo page
│   └── package.json
└── skills/
    └── liquid-glass-lens/       # Antigravity / AI Agent Skill specification
```

---

## 🍏 1. Swift & Metal (macOS / iOS)

### 🌟 Features
* **Desktop Floating Bubble (`NSPanel` + WindowServer)**: Real-time 120 FPS hardware compositor penetration across all desktop windows with **ZERO screen recording permissions**.
* **Optical Inversion**: High-curvature physical convex lens mode where the UV sampling map folds over itself, causing text underneath to invert upside down and horizontal dots to split into dual rows.
* **Fold-Free Legible Mode**: Monotone slope clamping for readable UI controls (TabBar, buttons).
* **6-Tap Continuous Spectrum Dispersion**: Smooth blue → cyan → magenta chromatic sheen.
* **iOS Squircle Continuous Curvature**: Analytic distance field using p-norm ($p \approx 4.2$).

### 🚀 Run the macOS Desktop Glass Bubble Demo
```bash
swift run LiquidGlassDemo
```
A crystal-clear liquid glass bubble will float on your Mac desktop. Click and drag it over any open window (Safari, Xcode, Finder, Wallpaper) to see real-time physical lens refraction and optical inversion!

### 📦 Installation
```swift
dependencies: [
    .package(url: "https://github.com/sqoder/LiquidGlassKit.git", from: "1.0.0")
]
```

### 🛠 Usage in SwiftUI
```swift
import SwiftUI
import LiquidGlassKit

// 1. Launch a floating desktop bubble
DesktopGlassBubble.shared.show(size: 220)

// 2. Or apply to any in-app SwiftUI view
MyCardView()
    .liquidGlassLens(.opticalInversionPreset)
```

---

## 🌐 2. TypeScript & WebGL 2.0 (Web / Frontend)

A zero-dependency TypeScript implementation bringing the exact same physical lens refraction, optical inversion, and 6-tap spectral dispersion directly to HTML5 Canvas and React/Vue apps.

### 🚀 Run the Web Demo
```bash
cd web
pnpm install
pnpm run dev
```
Open `http://localhost:5173` to interact with the live browser demo. Drag the liquid glass card over the "Glint" title bar to see real-time optical inversion, text flipping, and continuous spectrum dispersion!

### 🛠 Usage in TypeScript
```typescript
import { LiquidGlassLens } from './web/src';

const canvas = document.getElementById('my-canvas') as HTMLCanvasElement;

const lens = new LiquidGlassLens(canvas, {
  width: 320,
  height: 180,
  bezel: 20,
  strength: 30,
  mode: 'opticalInversion', // 'opticalInversion' | 'foldFree'
  dispersion: 0.85,
  fresnelRim: 0.75,
  draggable: true
});

// Provide a backdrop image or canvas
const image = new Image();
image.src = '/backdrop.png';
image.onload = () => lens.setBackdrop(image);
```

---

## 📄 License

MIT © 2026 [sqoder](https://github.com/sqoder)
