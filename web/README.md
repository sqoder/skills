# LiquidGlass TS 💧✨

> **Apple-style Liquid Glass Lens Refraction with Optical Inversion, 6-Tap Spectral Dispersion, and Continuous Squircle SDF in TypeScript & WebGL 2.0.**

A lightweight, zero-dependency TypeScript library delivering authentic physical glass refraction and optical inversion directly in the browser.

---

## 🌟 Key Features

1. **True Optical Inversion (`mode: 'opticalInversion'`)**
   * Emulates high-curvature physical convex lens behavior. When content passes beneath the lens rim, the UV sampling map folds over itself, causing underlying typography to invert upside down and icons to split into dual rows.
2. **Fold-Free Legible Mode (`mode: 'foldFree'`)**
   * Slope-clamped monotone mapping. Underlying text and UI remain 100% sharp and readable with continuous chromatic sheen.
3. **6-Tap Continuous Spectrum Dispersion**
   * Emulates continuous wavelength chromatic aberration (Red → Amber → Yellow-Green → Cyan → Blue → Violet), eliminating crude 3-channel red/green banding.
4. **20° Tangential Shear**
   * Refraction rays sweep along the edge contour, giving the glass an organic, liquid-like surface tension.
5. **iOS Squircle Continuous Curvature**
   * Analytic distance field using p-norm ($p \approx 4.2$) avoiding sharp curvature breaks.
6. **Blinn-Phong Specular Arc & Crisp Fresnel Hairline**
   * Thin, razor-sharp white rim highlight contour hugging the lens boundary.
7. **Responsive & Retina-Ready**
   * Automatic Device Pixel Ratio (DPR) adaptation with mouse and touch drag interactions.

---

## 🚀 Quick Start & Interactive Demo

```bash
git clone -b LiquidGlassKit https://github.com/sqoder/skills.git
cd skills/web
pnpm install
pnpm run dev
```

Open `http://localhost:5173` to interact with the live demo. Drag the liquid glass card over the typography and graphic cards to see real-time optical inversion, text flipping, and continuous spectrum dispersion in action!

---

## 📦 Installation

This package is **not published to npm** yet. Import the source directly from the repo:

```bash
git clone -b LiquidGlassKit https://github.com/sqoder/skills.git
# then copy web/src/ into your project, or add it as a local dependency
```

```bash
pnpm add /path/to/skills/web
```

---

## 🛠 Usage Examples

### 1. Basic Setup with Canvas

```typescript
import { LiquidGlassLens } from './src';

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

### 2. Dynamically Adjusting Optical Properties

```typescript
// Switch to fold-free mode for readable UI
lens.setOptions({
  mode: 'foldFree',
  bezel: 14,
  strength: 16,
  dispersion: 0.5
});
```

---

## 📄 License

MIT © 2026 [sqoder](https://github.com/sqoder)
