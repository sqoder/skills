import { VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE } from './shaders';

export interface LiquidGlassOptions {
  bezel: number;
  strength: number;
  mode: 'opticalInversion' | 'foldFree';
  dispersion: number;
  fresnelRim: number;
  specular: number;
  lightAngle: number;
  cornerRadius: number;
  cornerExponent: number;
}

export class LiquidGlassRenderer {
  private gl: WebGL2RenderingContext;
  private program: WebGLProgram;
  private texture: WebGLTexture;
  private vao: WebGLVertexArrayObject;
  private uniformLocations: Record<string, WebGLUniformLocation> = {};

  constructor(canvas: HTMLCanvasElement) {
    const gl = canvas.getContext('webgl2', { alpha: true, antialias: true });
    if (!gl) {
      throw new Error('WebGL 2.0 is required for LiquidGlassRenderer');
    }
    this.gl = gl;

    this.program = this.createProgram(VERTEX_SHADER_SOURCE, FRAGMENT_SHADER_SOURCE);
    this.initUniforms();
    this.vao = this.initGeometry();
    this.texture = this.initTexture();
  }

  private createShader(type: number, source: string): WebGLShader {
    const gl = this.gl;
    const shader = gl.createShader(type)!;
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      const info = gl.getShaderInfoLog(shader);
      gl.deleteShader(shader);
      throw new Error('Shader compilation error: ' + info);
    }
    return shader;
  }

  private createProgram(vsSource: string, fsSource: string): WebGLProgram {
    const gl = this.gl;
    const vs = this.createShader(gl.VERTEX_SHADER, vsSource);
    const fs = this.createShader(gl.FRAGMENT_SHADER, fsSource);
    const program = gl.createProgram()!;
    gl.attachShader(program, vs);
    gl.attachShader(program, fs);
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
      const info = gl.getProgramInfoLog(program);
      gl.deleteProgram(program);
      throw new Error('Program linking error: ' + info);
    }
    return program;
  }

  private initUniforms() {
    const gl = this.gl;
    const names = [
      'u_backdrop', 'u_resolution', 'u_lensCenter', 'u_lensSize',
      'u_cornerRadius', 'u_cornerExponent', 'u_bezel', 'u_strength',
      'u_mode', 'u_dispersion', 'u_fresnel', 'u_specular', 'u_lightAngle'
    ];
    for (const name of names) {
      const loc = gl.getUniformLocation(this.program, name);
      if (loc) this.uniformLocations[name] = loc;
    }
  }

  private initGeometry(): WebGLVertexArrayObject {
    const gl = this.gl;
    const vao = gl.createVertexArray()!;
    gl.bindVertexArray(vao);

    const posBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, posBuffer);
    const positions = new Float32Array([
      -1, -1,
       1, -1,
      -1,  1,
      -1,  1,
       1, -1,
       1,  1
    ]);
    gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);

    const posAttr = gl.getAttribLocation(this.program, 'a_position');
    gl.enableVertexAttribArray(posAttr);
    gl.vertexAttribPointer(posAttr, 2, gl.FLOAT, false, 0, 0);

    gl.bindVertexArray(null);
    return vao;
  }

  private initTexture(): WebGLTexture {
    const gl = this.gl;
    const tex = gl.createTexture()!;
    gl.bindTexture(gl.TEXTURE_2D, tex);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    return tex;
  }

  public updateBackdrop(source: TexImageSource) {
    const gl = this.gl;
    gl.bindTexture(gl.TEXTURE_2D, this.texture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, source);
  }

  public render(
    canvasWidth: number,
    canvasHeight: number,
    lensCenter: [number, number],
    lensSize: [number, number],
    options: LiquidGlassOptions
  ) {
    const gl = this.gl;
    gl.viewport(0, 0, canvasWidth, canvasHeight);
    gl.useProgram(this.program);
    gl.bindVertexArray(this.vao);

    gl.activeTexture(gl.TEXTURE0);
    gl.bindTexture(gl.TEXTURE_2D, this.texture);
    gl.uniform1i(this.uniformLocations['u_backdrop'], 0);

    gl.uniform2f(this.uniformLocations['u_resolution'], canvasWidth, canvasHeight);
    gl.uniform2f(this.uniformLocations['u_lensCenter'], lensCenter[0], lensCenter[1]);
    gl.uniform2f(this.uniformLocations['u_lensSize'], lensSize[0], lensSize[1]);

    gl.uniform1f(this.uniformLocations['u_cornerRadius'], options.cornerRadius);
    gl.uniform1f(this.uniformLocations['u_cornerExponent'], options.cornerExponent);
    gl.uniform1f(this.uniformLocations['u_bezel'], options.bezel);
    gl.uniform1f(this.uniformLocations['u_strength'], options.strength);
    gl.uniform1f(this.uniformLocations['u_mode'], options.mode === 'opticalInversion' ? 1.0 : 0.0);
    gl.uniform1f(this.uniformLocations['u_dispersion'], options.dispersion);
    gl.uniform1f(this.uniformLocations['u_fresnel'], options.fresnelRim);
    gl.uniform1f(this.uniformLocations['u_specular'], options.specular);
    gl.uniform1f(this.uniformLocations['u_lightAngle'], options.lightAngle);

    gl.drawArrays(gl.TRIANGLES, 0, 6);
    gl.bindVertexArray(null);
  }
}
