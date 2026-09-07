import { LiquidGlassLens } from './LiquidGlassLens';

// 1. 生成底层的测试画面（包含第二张截图里的 Glint 窗口标题栏与多彩半色调艺术背景）
function createTestBackdrop(width: number, height: number): HTMLCanvasElement {
  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext('2d')!;

  // 渐变底色
  const grad = ctx.createLinearGradient(0, 0, width, height);
  grad.addColorStop(0, '#2b3a67');
  grad.addColorStop(0.5, '#49609c');
  grad.addColorStop(1, '#8f5da5');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, width, height);

  // 模拟半色调（Halftone）点阵艺术底纹
  ctx.fillStyle = 'rgba(255, 255, 255, 0.12)';
  for (let x = 0; x < width; x += 16) {
    for (let y = 0; y < height; y += 16) {
      const rad = (Math.sin(x * 0.05) + Math.cos(y * 0.05) + 2) * 2;
      ctx.beginPath();
      ctx.arc(x, y, rad, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  // 绘制底部“Glint”窗口标题栏（完美还原第二张截图）
  const barW = Math.min(width - 80, 860);
  const barH = 54;
  const barX = (width - barW) / 2;
  const barY = height - 160;

  // 标题栏背景
  ctx.save();
  ctx.fillStyle = 'rgba(24, 28, 38, 0.94)';
  ctx.beginPath();
  ctx.roundRect(barX, barY, barW, barH, 16);
  ctx.fill();

  // 窗口红黄绿三灯
  const lights = ['#ff5f56', '#ffbd2e', '#27c93f'];
  lights.forEach((color, i) => {
    ctx.beginPath();
    ctx.arc(barX + 24 + i * 18, barY + barH / 2, 6, 0, Math.PI * 2);
    ctx.fillStyle = color;
    ctx.fill();
  });

  // 标题文字 "Glint"
  ctx.font = 'bold 17px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
  ctx.fillStyle = '#ffffff';
  ctx.fillText('Glint', barX + 110, barY + barH / 2 + 6);

  // 椭圆三点图标
  ctx.fillStyle = 'rgba(255, 255, 255, 0.15)';
  ctx.beginPath();
  ctx.arc(barX + 175, barY + barH / 2, 14, 0, Math.PI * 2);
  ctx.fill();

  ctx.fillStyle = '#ffffff';
  for (let j = -1; j <= 1; j++) {
    ctx.beginPath();
    ctx.arc(barX + 175 + j * 6, barY + barH / 2, 2, 0, Math.PI * 2);
    ctx.fill();
  }

  // 模拟右侧小图标 (铅笔、分屏、眼睛、对齐、分享、图钉、垃圾桶)
  ctx.font = '16px -apple-system, BlinkMacSystemFont, sans-serif';
  const symbols = ['✏️', '◫', '👁', '≡', '⇪', '📌', '🗑'];
  symbols.forEach((sym, idx) => {
    ctx.fillText(sym, barX + barW - 220 + idx * 30, barY + barH / 2 + 6);
  });

  ctx.restore();
  return canvas;
}

window.addEventListener('DOMContentLoaded', () => {
  const canvas = document.getElementById('webgl-canvas') as HTMLCanvasElement;
  const dpr = Math.min(window.devicePixelRatio || 1, 2);
  const displayW = window.innerWidth;
  const displayH = window.innerHeight;

  canvas.width = displayW * dpr;
  canvas.height = displayH * dpr;

  const backdrop = createTestBackdrop(canvas.width, canvas.height);

  // 实例化 WebGL 液态玻璃透镜
  const lens = new LiquidGlassLens(canvas, {
    width: 440 * dpr,
    height: 180 * dpr,
    initialX: canvas.width / 2,
    initialY: canvas.height - 230 * dpr, // 初始位置微压在 Glint 栏上方，直接展现倒像！
    bezel: 22 * dpr,
    strength: 32 * dpr,
    mode: 'opticalInversion',
    dispersion: 0.9,
    fresnelRim: 0.85
  });

  lens.setBackdrop(backdrop);

  // 绑定控制面板
  const modeSelect = document.getElementById('mode-select') as HTMLSelectElement;
  const bezelSlider = document.getElementById('bezel-slider') as HTMLInputElement;
  const strengthSlider = document.getElementById('strength-slider') as HTMLInputElement;
  const dispersionSlider = document.getElementById('dispersion-slider') as HTMLInputElement;
  const fresnelSlider = document.getElementById('fresnel-slider') as HTMLInputElement;

  modeSelect.addEventListener('change', () => {
    lens.setOptions({ mode: modeSelect.value as any });
  });

  bezelSlider.addEventListener('input', () => {
    lens.setOptions({ bezel: parseFloat(bezelSlider.value) * dpr });
  });

  strengthSlider.addEventListener('input', () => {
    lens.setOptions({ strength: parseFloat(strengthSlider.value) * dpr });
  });

  dispersionSlider.addEventListener('input', () => {
    lens.setOptions({ dispersion: parseFloat(dispersionSlider.value) });
  });

  fresnelSlider.addEventListener('input', () => {
    lens.setOptions({ fresnelRim: parseFloat(fresnelSlider.value) });
  });
});
