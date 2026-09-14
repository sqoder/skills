import AppKit
import SwiftUI
import QuartzCore

// =============================================================================
// DesktopGlassLens.swift (原 DesktopGlassBubble)
// macOS 桌面全局悬浮透明液态玻璃镜片 / 面板 (Desktop Floating Liquid Glass Lens)
//
// 核心架构：
// 1. NSPanel 全局浮动于所有窗口顶层 (.floating)，可在所有桌面空间漫游 (.canJoinAllSpaces)
// 2. 鼠标按住窗口任意背景直接拖拽 (isMovableByWindowBackground = true)
// 3. 驱动 WindowServer 硬件级真实跨窗口穿透合成，无需任何屏幕录制权限
// 4. 三层架构：穿透折射底板 + 菲涅尔高光轮廓 + 独立前景交互插槽
// =============================================================================

/// 桌面全局悬浮透镜管理器
@MainActor
public final class DesktopGlassLens {
    public static let shared = DesktopGlassLens()
    private var panel: DesktopLensPanel?

    public init() {}

    /// 在桌面显示悬浮镜片
    /// - Parameters:
    ///   - width: 宽度
    ///   - height: 高度
    ///   - cornerRadius: 圆角（-1 代表正圆/全胶囊）
    ///   - initialPoint: 初始屏幕坐标（可选）
    ///   - content: 浮动在镜片上的自定义前景 View（可选）
    public func show<Content: View>(
        width: CGFloat = 220,
        height: CGFloat = 220,
        cornerRadius: CGFloat = -1,
        initialPoint: CGPoint? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        panel?.orderOut(nil)
        let resolvedRadius = cornerRadius < 0 ? min(width, height) / 2 : cornerRadius
        let p = DesktopLensPanel(
            width: width,
            height: height,
            cornerRadius: resolvedRadius,
            initialPoint: initialPoint,
            content: content
        )
        self.panel = p
        p.makeKeyAndOrderFront(nil)
    }

    /// 便捷方法：快速升起一颗纯折射水晶玻璃球
    public func showCircle(diameter: CGFloat = 220, initialPoint: CGPoint? = nil) {
        show(width: diameter, height: diameter, cornerRadius: diameter / 2, initialPoint: initialPoint) {
            EmptyView()
        }
    }

    public func hide() {
        panel?.orderOut(nil)
        panel = nil
    }
}

/// 兼容别名
public typealias DesktopGlassBubble = DesktopGlassLens

/// 桌面全局透明无边框 Panel
public final class DesktopLensPanel: NSPanel {
    public init<Content: View>(
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat,
        initialPoint: CGPoint?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let x = initialPoint?.x ?? (screenFrame.midX - width / 2)
        let y = initialPoint?.y ?? (screenFrame.midY - height / 2)
        let rect = NSRect(x: x, y: y, width: width, height: height)

        super.init(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
        self.hasShadow = true
        self.isMovableByWindowBackground = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isReleasedWhenClosed = false

        let hosting = NSHostingView(
            rootView: DesktopLensView(
                width: width,
                height: height,
                cornerRadius: cornerRadius,
                content: content
            )
        )
        self.contentView = hosting
    }
}

/// 桌面透镜的 SwiftUI 渲染层
public struct DesktopLensView<Content: View>: View {
    public var width: CGFloat
    public var height: CGFloat
    public var cornerRadius: CGFloat
    public var content: () -> Content

    @State private var isHovered = false

    public init(
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.content = content
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            // Layer 1: 真实穿透 WindowServer 底层窗口的原生透镜折射底板
            WindowServerGlassBackdrop(cornerRadius: cornerRadius)
                .clipShape(shape)

            // Layer 2: 玻璃表面微光反光层 (高透球体/曲面质感)
            shape
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.14), Color.white.opacity(0.0)],
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: max(width, height) * 0.75
                    )
                )

            // Layer 3: 连续曲率菲涅尔边缘高光弧线 (Crisp Fresnel Rim)
            shape
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.20),
                            Color.white.opacity(0.70)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )

            // Layer 4: 前景内容层（用户传入的图标、文字、控件等，不受扭曲影响）
            content()
        }
        .frame(width: width, height: height)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

/// 驱动 WindowServer 硬件穿透合成的 NSView 包装层
public struct WindowServerGlassBackdrop: NSViewRepresentable {
    public var cornerRadius: CGFloat

    public init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }

    public func makeNSView(context: Context) -> NSView {
        if let glassClass = NSClassFromString("NSGlassEffectView") as? NSView.Type {
            let container = NSView()
            container.wantsLayer = true

            let glass = glassClass.init(frame: .zero)
            glass.translatesAutoresizingMaskIntoConstraints = false
            glass.wantsLayer = true
            glass.setValue(cornerRadius, forKey: "cornerRadius")

            // 1. 设置 Apple 原生 Liquid Glass 变体 (v11: 超清晶莹液态透镜)
            let selVariant = NSSelectorFromString("set_variant:")
            if glass.responds(to: selVariant) {
                typealias Setter = @convention(c) (AnyObject, Selector, Int) -> Void
                let imp = glass.method(for: selVariant)
                let fn = unsafeBitCast(imp, to: Setter.self)
                fn(glass, selVariant, 11)
            }

            // 2. 激活原生透镜屈光扭曲 (Content Lensing - 产生倒像与折射)
            let selLensing = NSSelectorFromString("set_contentLensing:")
            if glass.responds(to: selLensing) {
                typealias LensSetter = @convention(c) (AnyObject, Selector, Int) -> Void
                let imp = glass.method(for: selLensing)
                let fn = unsafeBitCast(imp, to: LensSetter.self)
                fn(glass, selLensing, 1)
            }

            container.addSubview(glass)
            NSLayoutConstraint.activate([
                glass.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                glass.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                glass.topAnchor.constraint(equalTo: container.topAnchor),
                glass.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

            // 3. 激活 WindowServer 硬件穿透合成（无需录屏权限，直接穿透桌面所有底层窗口）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak glass] in
                guard let rootLayer = glass?.layer else { return }
                func configureBackdrop(in layer: CALayer) {
                    if NSStringFromClass(type(of: layer)).contains("CABackdropLayer") {
                        layer.setValue(true, forKey: "windowServerAware")
                        layer.setValue(1.0, forKey: "scale")
                    }
                    layer.sublayers?.forEach { configureBackdrop(in: $0) }
                }
                configureBackdrop(in: rootLayer)
            }

            return container
        }

        // 降级兜底：标准 AppKit 毛玻璃
        let fallback = NSVisualEffectView()
        fallback.material = .popover
        fallback.blendingMode = .behindWindow
        return fallback
    }

    public func updateNSView(_ nsView: NSView, context: Context) {}
}
