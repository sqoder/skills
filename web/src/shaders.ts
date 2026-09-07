// =============================================================================
// WebGL Shaders for Universal Liquid Glass Lens
// Features:
// 1. Continuous Curvature Squircle SDF (p-norm ~4.2)
// 2. Dual Displacement: Fold-Free (0.0) vs Optical Inversion (1.0)
// 3. 20° Tangential Shear
// 4. 6-Tap Continuous Spectrum Dispersion
// 5. Blinn-Phong Specular Arc & Crisp Fresnel Hairline
// =============================================================================

export const VERTEX_SHADER_SOURCE = `#version 300 es
in vec2 a_position;
out vec2 v_uv;

void main() {
    v_uv = a_position * 0.5 + 0.5;
    // Standard WebGL UV: (0,0) bottom-left, flip Y for canvas top-left orientation
    gl_Position = vec4(a_position.x, a_position.y, 0.0, 1.0);
}
`;

export const FRAGMENT_SHADER_SOURCE = `#version 300 es
precision highp float;

in vec2 v_uv;
out vec4 fragColor;

uniform sampler2D u_backdrop;
uniform vec2 u_resolution;    // Canvas size (px)
uniform vec2 u_lensCenter;    // Lens center in canvas px (from top-left)
uniform vec2 u_lensSize;      // Lens width/height (px)
uniform float u_cornerRadius; // Corner radius (px)
uniform float u_cornerExponent; // 2.0 = circle, 4.2 = iOS squircle
uniform float u_bezel;        // Bevel width (px)
uniform float u_strength;     // Refraction strength
uniform float u_mode;         // 0.0 = fold-free, 1.0 = optical inversion
uniform float u_dispersion;   // Chromatic dispersion (0.0 .. 2.0)
uniform float u_fresnel;      // Fresnel edge contour
uniform float u_specular;     // Highlight arc
uniform float u_lightAngle;   // Light direction in radians

// Continuous curvature squircle SDF
float sdContinuousBox(vec2 p, vec2 b, float r, float n) {
    vec2 q = abs(p) - b;
    if (n <= 2.02) {
        return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
    } else {
        vec2 m = max(q, 0.0);
        float s = pow(m.x, n) + pow(m.y, n);
        float outside = (s > 0.0) ? pow(s, 1.0 / n) : 0.0;
        return min(max(q.x, q.y), 0.0) + outside - r;
    }
}

void main() {
    // Current pixel coordinate in canvas pixels (top-left origin)
    vec2 pixelPos = vec2(v_uv.x, 1.0 - v_uv.y) * u_resolution;
    vec2 p = pixelPos - u_lensCenter;

    float minHalf = min(u_lensSize.x, u_lensSize.y) * 0.5;
    float r = (u_cornerRadius < 0.0) ? minHalf : min(u_cornerRadius, minHalf);
    vec2 halfExtents = max(u_lensSize * 0.5 - vec2(r), vec2(0.0));

    float d = sdContinuousBox(p, halfExtents, r, u_cornerExponent);

    // If outside the lens, sample backdrop unchanged
    if (d > 1.5) {
        fragColor = texture(u_backdrop, v_uv);
        return;
    }

    float inside = -d;
    float safeBezel = max(u_bezel, 1.0);
    float t = clamp(inside / safeBezel, 0.0, 1.0);
    float edge = 1.0 - t; // 1 at rim, 0 at flat center

    // 1. Surface normal via central differences
    const float e = 1.0;
    float dx = sdContinuousBox(p + vec2(e, 0.0), halfExtents, r, u_cornerExponent)
             - sdContinuousBox(p - vec2(e, 0.0), halfExtents, r, u_cornerExponent);
    float dy = sdContinuousBox(p + vec2(0.0, e), halfExtents, r, u_cornerExponent)
             - sdContinuousBox(p - vec2(0.0, e), halfExtents, r, u_cornerExponent);
    vec2 normalDir = normalize(vec2(dx, dy) + vec2(1e-6, 0.0));

    // 2. Dual displacement profile
    // Mode 0: Fold-free magnification (monotonic slope < 0.88)
    float k = min(2.0 * u_strength / safeBezel, 0.88);
    float magFoldFree = 0.5 * k * safeBezel * edge * edge;

    // Mode 1: Optical inversion (steep slope crossing fold limit -> real upside-down flip!)
    float magInversion = u_strength * (pow(edge, 1.6) + 1.35 * pow(edge, 3.2));

    float m = mix(magFoldFree, magInversion, clamp(u_mode, 0.0, 1.0));

    // 3. 20° Tangential shear
    const float ct = 0.9397; // cos(20 deg)
    const float st = 0.3420; // sin(20 deg)
    vec2 inward = -normalDir;
    vec2 tangent = vec2(-normalDir.y, normalDir.x);
    vec2 baseOffsetPx = (inward * ct + tangent * st) * m;

    // Normalize offset to UV space (flip Y for WebGL texture coords)
    vec2 baseOffsetUV = vec2(baseOffsetPx.x, -baseOffsetPx.y) / u_resolution;

    // 4. 6-Tap continuous spectrum dispersion
    float spread = u_dispersion * 0.18 * edge;
    const int TAPS = 6;
    vec3 weights[6] = vec3[6](
        vec3(1.00, 0.05, 0.00), // Red
        vec3(1.00, 0.58, 0.00), // Orange/Amber
        vec3(0.50, 1.00, 0.15), // Yellow-Green
        vec3(0.00, 1.00, 0.70), // Cyan
        vec3(0.12, 0.35, 1.00), // Blue
        vec3(0.65, 0.00, 0.85)  // Violet
    );
    const float sumR = 3.27;
    const float sumG = 2.93;
    const float sumB = 2.70;

    vec4 accCol = vec4(0.0);
    for (int i = 0; i < TAPS; ++i) {
        float u = float(i) / float(TAPS - 1);
        float f = 1.0 + spread * (2.0 * u - 1.0);
        vec2 sampleUV = clamp(v_uv + baseOffsetUV * f, 0.0, 1.0);
        vec4 tap = texture(u_backdrop, sampleUV);

        accCol.r += tap.r * weights[i].r;
        accCol.g += tap.g * weights[i].g;
        accCol.b += tap.b * weights[i].b;
        accCol.a += tap.a * (1.0 / float(TAPS));
    }
    accCol.r /= sumR;
    accCol.g /= sumG;
    accCol.b /= sumB;

    // 5. Specular Arc & Crisp Fresnel Hairline
    vec2 L = normalize(vec2(cos(u_lightAngle), sin(u_lightAngle)));
    float dotNL = max(dot(normalDir, -L), 0.0);
    float arcWindow = exp(-pow((edge - 0.22) / 0.18, 2.0));
    float specLobe = pow(dotNL, 18.0) * arcWindow * u_specular;

    // Crisp white Fresnel silhouette contour (~3.5px outer hairline)
    float hairline = (1.0 - smoothstep(0.0, 3.5, inside)) * u_fresnel * 0.95;

    // Subtle counter-rim shadow
    float counterRim = max(dot(normalDir, L), 0.0) * edge * 0.14;

    vec3 finalRgb = accCol.rgb + vec3(specLobe + hairline);
    finalRgb = max(finalRgb - vec3(counterRim * accCol.a), vec3(0.0));

    // Antialiased silhouette alpha blend
    float coverage = clamp(inside + 0.5, 0.0, 1.0);
    vec4 baseColor = texture(u_backdrop, v_uv);
    fragColor = mix(baseColor, vec4(finalRgb, accCol.a), coverage);
}
`;
