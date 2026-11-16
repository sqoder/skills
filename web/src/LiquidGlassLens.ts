import { LiquidGlassRenderer, LiquidGlassOptions } from './LiquidGlassRenderer';

export interface LiquidGlassLensConfig extends Partial<LiquidGlassOptions> {
  width?: number;
  height?: number;
  initialX?: number;
  initialY?: number;
  draggable?: boolean;
}

export class LiquidGlassLens {
  private canvas: HTMLCanvasElement;
  private renderer: LiquidGlassRenderer;
  private backdropSource: TexImageSource | null = null;

  public options: LiquidGlassOptions;
  public width: number;
  public height: number;
  public x: number;
  public y: number;
  public draggable: boolean;

  private isDragging = false;
  private dragStartX = 0;
  private dragStartY = 0;
  private lensStartX = 0;
  private lensStartY = 0;

  constructor(canvas: HTMLCanvasElement, config: LiquidGlassLensConfig = {}) {
    this.canvas = canvas;
    this.renderer = new LiquidGlassRenderer(canvas);

    this.width = config.width ?? 320;
    this.height = config.height ?? 160;
    this.x = config.initialX ?? canvas.width / 2;
    this.y = config.initialY ?? canvas.height / 2;
    this.draggable = config.draggable ?? true;

    this.options = {
      bezel: config.bezel ?? 18.0,
      strength: config.strength ?? 28.0,
      mode: config.mode ?? 'opticalInversion',
      dispersion: config.dispersion ?? 0.85,
      fresnelRim: config.fresnelRim ?? 0.75,
      specular: config.specular ?? 0.45,
      lightAngle: config.lightAngle ?? -0.785,
      cornerRadius: config.cornerRadius ?? 24.0,
      cornerExponent: config.cornerExponent ?? 4.2
    };

    if (this.draggable) {
      this.initDragHandlers();
    }
  }

  public setBackdrop(source: TexImageSource) {
    this.backdropSource = source;
    this.renderer.updateBackdrop(source);
    this.render();
  }

  public setOptions(newOptions: Partial<LiquidGlassOptions>) {
    Object.assign(this.options, newOptions);
    this.render();
  }

  public render() {
    if (!this.backdropSource) return;
    this.renderer.render(
      this.canvas.width,
      this.canvas.height,
      [this.x, this.y],
      [this.width, this.height],
      this.options
    );
  }

  private initDragHandlers() {
    const onPointerDown = (e: MouseEvent | TouchEvent) => {
      const rect = this.canvas.getBoundingClientRect();
      const clientX = 'touches' in e ? e.touches[0].clientX : e.clientX;
      const clientY = 'touches' in e ? e.touches[0].clientY : e.clientY;
      const mouseX = (clientX - rect.left) * (this.canvas.width / rect.width);
      const mouseY = (clientY - rect.top) * (this.canvas.height / rect.height);

      // Check if clicked inside lens bounds
      const halfW = this.width / 2;
      const halfH = this.height / 2;
      if (
        mouseX >= this.x - halfW &&
        mouseX <= this.x + halfW &&
        mouseY >= this.y - halfH &&
        mouseY <= this.y + halfH
      ) {
        this.isDragging = true;
        this.dragStartX = clientX;
        this.dragStartY = clientY;
        this.lensStartX = this.x;
        this.lensStartY = this.y;
        e.preventDefault();
      }
    };

    const onPointerMove = (e: MouseEvent | TouchEvent) => {
      if (!this.isDragging) return;
      const rect = this.canvas.getBoundingClientRect();
      const scaleX = this.canvas.width / rect.width;
      const scaleY = this.canvas.height / rect.height;

      const clientX = 'touches' in e ? e.touches[0].clientX : e.clientX;
      const clientY = 'touches' in e ? e.touches[0].clientY : e.clientY;

      const dx = (clientX - this.dragStartX) * scaleX;
      const dy = (clientY - this.dragStartY) * scaleY;

      this.x = this.lensStartX + dx;
      this.y = this.lensStartY + dy;
      this.render();
      e.preventDefault();
    };

    const onPointerUp = () => {
      this.isDragging = false;
    };

    this.canvas.addEventListener('mousedown', onPointerDown);
    window.addEventListener('mousemove', onPointerMove);
    window.addEventListener('mouseup', onPointerUp);

    this.canvas.addEventListener('touchstart', onPointerDown, { passive: false });
    window.addEventListener('touchmove', onPointerMove, { passive: false });
    window.addEventListener('touchend', onPointerUp);
  }
}
