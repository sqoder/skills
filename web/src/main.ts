import { LiquidGlassLens } from './LiquidGlassLens';

// 生成底层的现代测试画报（包含高对比度几何色块、波点阵列与精密排版，绝佳展现倒像与色散）
function createTestBackdrop(width: number, height: number): HTMLCanvasElement {
  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext('2d')!;

  // 1. 深邃的多色阶渐变底色
  const grad = ctx.createLinearGradient(0, 0, width, height);
  grad.addColorStop(0, '#101626');
  grad.addColorStop(0.4, '#1b2342');
  grad.addColorStop(0.7, '#2f214a');
  grad.addColorStop(1, '#481d3f');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, width, height);

  // 2. 半色调点阵艺术底纹
  ctx.fillStyle = 'rgba(255, 255, 255, 0.1)';
  for (let x = 20; x < width; x += 24) {
    for (let y = 20; y < height; y += 24) {
      const rad = (Math.sin(x * 0.04) + Math.cos(y * 0.04) + 2) * 1.8;
      ctx.beginPath();
      ctx.arc(x, y, rad, 0, Math.PI * 2);
      ctx.fill();
    }
  }

  // 3. 绘制大型现代排版海报卡片（测试倒立折射与色散）
  const cardW = Math.min(width - 100, 880);
  const cardH = 220;
  const cardX = (width - cardW) / 2;
  const cardY = height - 320;

  ctx.save();
  ctx.fillStyle = 'rgba(12, 16, 28, 0.75)';
  ctx.beginPath();
  ctx.roundRect(cardX, cardY, cardW, cardH, 24);
  ctx.fill();

  ctx.strokeStyle = 'rgba(255, 255, 255, 0.12)';
  ctx.lineWidth = 1.5;
  ctx.stroke();

  // 标题
  ctx.font = '900 32px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
  ctx.fillStyle = '#ffffff';
  ctx.fillText('LIQUID GLASS LENS REFRACTION', cardX + 36, cardY + 58);

  // 副标题与物理特性指标
  ctx.font = '500 15px -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif';
  ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
  ctx.fillText('Drag the physical convex lens over this area to witness UV folding inversion & 6-tap dispersion', cardX + 36, cardY + 92);

  // 彩色几何色带 (用于观察连续光谱蓝->青->紫微光色散)
  const bands = ['#ff3b30', '#ff9500', '#ffcc00', '#34c759', '#00c7be', '#32ade6', '#007aff', '#5856d6', '#af52de'];
  const bandW = (cardW - 72) / bands.length;
  bands.forEach((color, idx) => {
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.roundRect(cardX + 36 + idx * bandW, cardY + 124, bandW - 6, 14, 4);
    ctx.fill();
  });

  // 底部指标标注
  ctx.font = '600 13px -apple-system, BlinkMacSystemFont, monospace';
  ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
  ctx.fillText('PHYSICS: SNEIL LAW | 6-TAP SPECTRUM (380-750nm) | TANGENTIAL SHEAR 20° | SQUIRCLE p=4.2', cardX + 36, cardY + 180);

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
    initialY: canvas.height - 240 * dpr, // 初始位置微压在排版卡片上方，直观展现倒像！
    bezel: 22 * dpr,
    strength: 32 * dpr,
    mode: 'opticalInversion',
    dispersion: 0.9,
    fresnelRim: 0.85
  });

  lens.setBackdrop(backdrop);

  // 窗口缩放适配
  window.addEventListener('resize', () => {
    const newW = window.innerWidth;
    const newH = window.innerHeight;
    canvas.width = newW * dpr;
    canvas.height = newH * dpr;
    const newBackdrop = createTestBackdrop(canvas.width, canvas.height);
    lens.setBackdrop(newBackdrop);
  });

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
