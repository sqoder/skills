import SwiftUI

/// 通用液态玻璃悬浮卡片 / 灵动岛容器
public struct LiquidGlassCard<Content: View>: View {
    public var config: LiquidGlassConfiguration
    public var content: () -> Content

    public init(
        config: LiquidGlassConfiguration = .opticalInversionPreset,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.config = config
        self.content = content
    }

    public var body: some View {
        ZStack {
            // 半透明微黑色底板（配合 Apple Liquid Glass 的微暗色遮罩）
            RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                        .fill(Color.black.opacity(0.35))
                }

            // 卡片内容
            content()
        }
        .liquidGlassLens(config)
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous))
    }
}

/// 完美复刻截图场景的交互式演示视图
public struct LiquidGlassDemoView: View {
    @State private var cardOffset: CGSize = CGSize(width: 0, height: -30)
    @State private var config = LiquidGlassConfiguration.opticalInversionPreset
    @State private var showControls: Bool = false

    public init() {}

    public var body: some View {
        ZStack {
            // 1. 底层背景：复刻类似截图的点阵/色彩画卷
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.indigo.opacity(0.9), Color.purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // 2. 模拟第二张截图里的“Glint”窗口标题栏
            VStack {
                Spacer()

                HStack(spacing: 16) {
                    // 红黄绿三色灯
                    HStack(spacing: 7) {
                        Circle().fill(Color.red).frame(width: 12, height: 12)
                        Circle().fill(Color.yellow).frame(width: 12, height: 12)
                        Circle().fill(Color.green).frame(width: 12, height: 12)
                    }
                    .padding(.trailing, 8)

                    Image(systemName: "magnifyingglass")
                    Image(systemName: "square.and.pencil")
                    Image(systemName: "sidebar.left")

                    Text("Glint")
                        .font(.system(size: 16, weight: .bold))

                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 24, height: 24)
                        .overlay {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 10, weight: .bold))
                        }

                    Spacer()

                    HStack(spacing: 16) {
                        Image(systemName: "pencil")
                        Image(systemName: "rectangle.split.2x1")
                        Image(systemName: "eye")
                        Image(systemName: "text.alignleft")
                        Image(systemName: "square.and.arrow.up")
                        Image(systemName: "pin")
                        Image(systemName: "trash")
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(white: 0.15).opacity(0.92))
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 120)
            }

            // 3. 第一张截图里的“灵动岛中转站”悬浮卡片
            VStack {
                VStack(spacing: 12) {
                    // 中转站图标
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 48, height: 48)
                        .overlay {
                            Image(systemName: "tray.and.arrow.down")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 16)

                    Text("暂无暂存项目")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Text("拖拽任意文件至灵动岛即可暂存与中转")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))

                    // 底部胶囊工具条
                    HStack(spacing: 20) {
                        Image(systemName: "house.fill")
                        Image(systemName: "tray.and.arrow.down.fill")
                        Image(systemName: "square.grid.2x2")
                        Divider().frame(height: 16)
                        Image(systemName: "calendar")
                        Image(systemName: "gearshape")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.black.opacity(0.4)))
                    .padding(.bottom, 16)
                }
                .frame(width: 520)
                .background(
                    RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                        .fill(Color.black.opacity(0.55))
                )
                // 核心应用：赋予其液态玻璃透镜折射效果（向下拖拽压过 Glint 栏即可触发倒像）
                .liquidGlassLens(config)
                .offset(cardOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            cardOffset = value.translation
                        }
                )

                Spacer()
            }
            .padding(.top, 40)

            // 4. 浮动参数调试浮窗（点击齿轮可展开）
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation { showControls.toggle() }
                    } label: {
                        Image(systemName: showControls ? "xmark.circle.fill" : "slider.horizontal.3")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                }
                .padding()

                if showControls {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("液态玻璃透镜调节").font(.headline).foregroundColor(.white)

                        Picker("模式", selection: $config.mode) {
                            Text("物理倒像 (截图同款)").tag(LiquidGlassRefractionMode.opticalInversion)
                            Text("防撕裂放大 (可读)").tag(LiquidGlassRefractionMode.foldFree)
                        }
                        .pickerStyle(.segmented)

                        HStack {
                            Text("折射倒角 Bevel: \(Int(config.bezel))")
                            Slider(value: $config.bezel, in: 4...36)
                        }
                        HStack {
                            Text("折射强度 Strength: \(Int(config.strength))")
                            Slider(value: $config.strength, in: 0...50)
                        }
                        HStack {
                            Text("光谱色散 Dispersion: \(String(format: "%.2f", config.dispersion))")
                            Slider(value: $config.dispersion, in: 0...2)
                        }
                        HStack {
                            Text("菲涅尔亮边 Fresnel: \(String(format: "%.2f", config.fresnelRim))")
                            Slider(value: $config.fresnelRim, in: 0...1)
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 320)
                    .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
                    .padding()
                }

                Spacer()
            }
        }
    }
}
