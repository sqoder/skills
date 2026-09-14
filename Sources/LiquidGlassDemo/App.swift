import AppKit
import SwiftUI
import LiquidGlassKit

@main
struct LiquidGlassDemoApp: App {
    var body: some Scene {
        WindowGroup {
            LiquidGlassStudioView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

/// LiquidGlassKit 视觉实验室与交互演示
struct LiquidGlassStudioView: View {
    @State private var config = LiquidGlassConfiguration.opticalInversionPreset
    @State private var lensPosition: CGPoint = CGPoint(x: 280, y: 220)
    @State private var lensSize: CGSize = CGSize(width: 320, height: 160)
    @State private var isDesktopLensActive = false
    @State private var activeTab = 0

    var body: some View {
        HStack(spacing: 0) {
            // 左侧：App 内交互视口 (In-App Interactive Viewport)
            ZStack {
                LiquidGlassCanvas(
                    lensCenter: lensPosition,
                    lensSize: lensSize,
                    config: config
                ) {
                    // 底层测试背景 (Graphic Backdrop)
                    BackdropGalleryView()
                } overlay: {
                    // 浮动在透镜上的交互轮廓与手柄
                    ZStack {
                        // 拖拽手柄圈
                        Circle()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white.opacity(0.08)))
                            .overlay {
                                Image(systemName: "hand.draw")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .position(lensPosition)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        lensPosition = value.location
                                    }
                            )

                        // 顶部浮动 TabBar 演示 (Liquid Glass Pill)
                        VStack {
                            LiquidGlassPill(config: .foldFreePreset) {
                                HStack(spacing: 24) {
                                    Button(action: { activeTab = 0 }) {
                                        Label("画报视口", systemImage: "photo.on.rectangle.angled")
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(activeTab == 0 ? .white : .white.opacity(0.5))

                                    Button(action: { activeTab = 1 }) {
                                        Label("排版测试", systemImage: "text.alignleft")
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundColor(activeTab == 1 ? .white : .white.opacity(0.5))
                                }
                                .font(.system(size: 13, weight: .medium))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                            }
                            .padding(.top, 24)

                            Spacer()
                        }
                    }
                }
            }
            .frame(width: 640, height: 560)
            .clipped()

            // 右侧：调参控制台与桌面模式启动器
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("LiquidGlassKit")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Text("Apple 物理液态透镜设计系统与渲染引擎")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }

                Divider().background(Color.white.opacity(0.15))

                // 桌面透镜全局启动器
                VStack(alignment: .leading, spacing: 10) {
                    Text("macOS 桌面全局悬浮透镜")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Button {
                        if isDesktopLensActive {
                            DesktopGlassLens.shared.hide()
                            isDesktopLensActive = false
                        } else {
                            DesktopGlassLens.shared.show(
                                width: 260,
                                height: 260,
                                cornerRadius: 130
                            ) {
                                VStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text("按住直接在桌面上拖拽")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                            isDesktopLensActive = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: isDesktopLensActive ? "stop.circle.fill" : "play.circle.fill")
                            Text(isDesktopLensActive ? "关闭桌面透镜" : "在桌面升起悬浮透镜")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isDesktopLensActive ? Color.red.opacity(0.8) : Color.blue.opacity(0.85))
                        )
                    }
                    .buttonStyle(.plain)

                    Text("支持在 Xcode、Safari、终端与桌面壁纸上方任意拖拽穿透折射。")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))

                // 参数实时调节
                VStack(alignment: .leading, spacing: 14) {
                    Text("光学透镜参数").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)

                    Picker("折射模式", selection: $config.mode) {
                        Text("物理倒像 (凸透镜)").tag(LiquidGlassRefractionMode.opticalInversion)
                        Text("防撕裂单调放大 (可读)").tag(LiquidGlassRefractionMode.foldFree)
                    }
                    .pickerStyle(.segmented)

                    ParameterSlider(name: "边缘倒角 (Bevel)", value: $config.bezel, range: 6...36, unit: "pt")
                    ParameterSlider(name: "折射强度 (Strength)", value: $config.strength, range: 0...50, unit: "pt")
                    ParameterSlider(name: "光谱色散 (Dispersion)", value: $config.dispersion, range: 0...2.0, unit: "x")
                    ParameterSlider(name: "菲涅尔光边 (Fresnel)", value: $config.fresnelRim, range: 0...1.0, unit: "")
                }

                Spacer()
            }
            .padding(24)
            .frame(width: 320)
            .background(Color(white: 0.12).ignoresSafeArea())
        }
        .frame(width: 960, height: 560)
        .background(Color.black)
    }
}

/// 参数滑块小组件
struct ParameterSlider: View {
    var name: String
    @Binding var value: CGFloat
    var range: ClosedRange<CGFloat>
    var unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name).font(.system(size: 11)).foregroundColor(.white.opacity(0.75))
                Spacer()
                Text(String(format: "%.1f%@", value, unit))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            Slider(value: $value, in: range)
        }
    }
}

/// 底层测试画报背景
struct BackdropGalleryView: View {
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.15, blue: 0.32), Color(red: 0.25, green: 0.18, blue: 0.42), Color(red: 0.45, green: 0.20, blue: 0.38)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // 点阵与几何图形
            Canvas { ctx, size in
                for x in stride(from: 20, to: size.width, by: 28) {
                    for y in stride(from: 20, to: size.height, by: 28) {
                        let r = (sin(x * 0.04) + cos(y * 0.04) + 2.0) * 1.6
                        ctx.fill(
                            Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                            with: .color(Color.white.opacity(0.15))
                        )
                    }
                }
            }

            // 测试文字排版 (用于检验物理倒像与色散)
            VStack(spacing: 24) {
                Spacer()

                HStack(spacing: 16) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.cyan)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("OPTICAL LENSING")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .tracking(2)

                        Text("Drag the lens over this text to witness real physical inversion")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.4))
                )

                HStack(spacing: 28) {
                    MetricBadge(icon: "waveform.path", title: "6-Tap Spectrum", value: "380-750nm")
                    MetricBadge(icon: "skew", title: "Shear Angle", value: "20.0°")
                    MetricBadge(icon: "sparkles", title: "Curvature", value: "p = 4.2")
                }
                .padding(.bottom, 60)
            }
        }
    }
}

struct MetricBadge: View {
    var icon: String
    var title: String
    var value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.cyan)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 10)).foregroundColor(.white.opacity(0.6))
                Text(value).font(.system(size: 12, weight: .bold)).foregroundColor(.white)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.white.opacity(0.08)))
    }
}
