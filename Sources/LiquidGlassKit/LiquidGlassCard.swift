import SwiftUI

/// 通用液态玻璃卡片容器 (Liquid Glass Card)
///
/// 遵循严格的【三层玻璃架构 (3-Layer Glass Architecture)】：
/// 1. 透镜底板 (Lens Base)：运用物理材质与 LiquidGlass Metal Shader 产生边缘折射与流光
/// 2. 物理光泽边框 (Rim Highlight)：连续曲率菲涅尔白边与环境光反射
/// 3. 前景内容层 (Foreground Content)：独立于透镜层上方，100% 保持文字锐利、图标清晰与交互正常
public struct LiquidGlassCard<Content: View>: View {
    public var config: LiquidGlassConfiguration
    public var tintColor: Color
    public var content: () -> Content

    public init(
        config: LiquidGlassConfiguration = .cardPreset,
        tintColor: Color = Color.black.opacity(0.25),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.config = config
        self.tintColor = tintColor
        self.content = content
    }

    public var body: some View {
        ZStack {
            // Layer 1: 透镜与材质底板
            RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                        .fill(tintColor)
                }
                .liquidGlassLens(config)

            // Layer 2: 连续曲率菲涅尔边缘高光 (0.75px ~ 1.5px 极清透白边)
            RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.85 * config.fresnelRim),
                            Color.white.opacity(0.15 * config.fresnelRim),
                            Color.white.opacity(0.50 * config.fresnelRim)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )

            // Layer 3: 前景交互内容（保持绝对清晰与正常点击，不受透镜倒像干扰）
            content()
        }
        .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous))
    }
}

/// 通用液态玻璃胶囊 / 按钮 / 导航条容器 (Liquid Glass Pill)
/// 专为 TabBar、浮动药丸、Action Button 设计的紧凑型玻璃容器
public struct LiquidGlassPill<Content: View>: View {
    public var config: LiquidGlassConfiguration
    public var content: () -> Content

    public init(
        config: LiquidGlassConfiguration = .foldFreePreset,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.config = config
        self.content = content
    }

    public var body: some View {
        ZStack {
            // 胶囊底板
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule().fill(Color.black.opacity(0.2))
                }
                .liquidGlassLens(config)

            // 胶囊菲涅尔光边
            Capsule()
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.85 * config.fresnelRim),
                            Color.white.opacity(0.20 * config.fresnelRim)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )

            // 内容
            content()
        }
        .clipShape(Capsule())
    }
}
