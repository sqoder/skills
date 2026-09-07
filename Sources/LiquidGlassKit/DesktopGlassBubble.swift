import AppKit
import SwiftUI
import QuartzCore

// =============================================================================
// DesktopGlassBubble.swift
// 原生 macOS 桌面全局透明悬浮气泡 / 液态透镜面板
//
// 核心能力：
// 1. NSPanel 全局悬浮在所有窗口之巅 (.floating)，任意桌面空间穿梭 (.canJoinAllSpaces)
// 2. 鼠标按住直接在桌面上拖拽 (isMovableByWindowBackground = true)
// 3. 激活 WindowServer 硬件级真实跨窗口穿透合成 (windowServerAware = true)
// 4. 真实折射桌面上的任何其他 App（Xcode、浏览器、Finder、桌面壁纸），无需录屏权限！
// =============================================================================

/// 桌面悬浮气泡控制器
@MainActor
public final class DesktopGlassBubble {
    public static let shared = DesktopGlassBubble()
    private var panel: DesktopBubblePanel?

    public init() {}

    /// 在屏幕中央升起一颗真实的桌面折射气泡
    public func show(size: CGFloat = 220, initialPoint: CGPoint? = nil) {
        if let existing = panel {
            existing.makeKeyAndOrderFront(nil)
            return
        }
        let p = DesktopBubblePanel(size: size, initialPoint: initialPoint)
        self.panel = p
        p.makeKeyAndOrderFront(nil)
    }

    public func hide() {
        panel?.orderOut(nil)
        panel = nil
    }
}

/// 桌面全局透明无边框 Panel
public final class DesktopBubblePanel: NSPanel {
    public init(size: CGFloat = 220, initialPoint: CGPoint? = nil) {
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let x = initialPoint?.x ?? (screenFrame.midX - size / 2)
        let y = initialPoint?.y ?? (screenFrame.midY - size / 2)
        let rect = NSRect(x: x, y: y, width: size, height: size)

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

        let hosting = NSHostingView(rootView: DesktopBubbleView(size: size))
        self.contentView = hosting
    }
}

/// 气泡的 SwiftUI 渲染层（真实穿透底层的苹果液态透镜 + 菲涅尔白边）
public struct DesktopBubbleView: View {
    public var size: CGFloat
    @State private var isHovered = false

    public init(size: CGFloat = 220) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            // 1. 真实穿透 WindowServer 底层任何窗口的原生 Liquid Glass 背板
            WindowServerGlassBackdrop(cornerRadius: size / 2)
                .clipShape(Circle())

            // 2. 玻璃球体微光反光层 (产生高透球体质感)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.12), Color.white.opacity(0.0)],
                        center: .topLeading,
                        startRadius: 10,
                        endRadius: size * 0.75
                    )
                )

            // 3. 菲涅尔外圈与高光弧线（截图同款清透白边）
            Circle()
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
                    lineWidth: 2.0
                )

            // 4. 中心可爱的交互提示（悬浮或静止时显示）
            VStack(spacing: 5) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white.opacity(0.95))
                Text("桌面折射气泡")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.95))
                Text("按住直接在桌面上拖拽")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.75))
            }
            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 1)
            .opacity(isHovered ? 0.3 : 0.85)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
        }
        .frame(width: size, height: size)
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

        // 降级兜底
        let fallback = NSVisualEffectView()
        fallback.material = .popover
        fallback.blendingMode = .behindWindow
        return fallback
    }

    public func updateNSView(_ nsView: NSView, context: Context) {}
}
