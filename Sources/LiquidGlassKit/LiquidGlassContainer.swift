import SwiftUI

private let defaultShaderLibrary: ShaderLibrary = {
    #if SWIFT_PACKAGE
    if let url = Bundle.module.url(forResource: "default", withExtension: "metallib") {
        return ShaderLibrary(url: url)
    }
    #endif
    return .default
}()

/// 通用液态玻璃画布与背景折射容器 (Liquid Glass Canvas Container)
///
/// 真正实现 App 内【真实背景穿透折射与光学倒像】：
/// 将底层背景（文字、图片、列表、色块）与浮动透镜置于同一 Shader 采样空间中。
/// 透镜在背景上方移动时，透镜下方的背景内容会实时产生真实物理折射、UV折叠倒像与 6-Tap 连续光谱色散！
public struct LiquidGlassCanvas<Backdrop: View, Overlay: View>: View {
    public var lensCenter: CGPoint
    public var lensSize: CGSize
    public var config: LiquidGlassConfiguration
    public var backdrop: () -> Backdrop
    public var overlay: () -> Overlay

    public init(
        lensCenter: CGPoint,
        lensSize: CGSize,
        config: LiquidGlassConfiguration = .opticalInversionPreset,
        @ViewBuilder backdrop: @escaping () -> Backdrop,
        @ViewBuilder overlay: @escaping () -> Overlay = { EmptyView() }
    ) {
        self.lensCenter = lensCenter
        self.lensSize = lensSize
        self.config = config
        self.backdrop = backdrop
        self.overlay = overlay
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            // Layer 1: 底层背景，由 Metal Canvas Shader 施加透镜折射
            backdrop()
                .visualEffect { view, _ in
                    let maxSampleOffset = config.strength * (1.0 + config.dispersion) + config.bezel
                    return view.layerEffect(
                        defaultShaderLibrary.liquidGlassCanvas(
                            .float2(Float(lensCenter.x), Float(lensCenter.y)),
                            .float2(Float(lensSize.width), Float(lensSize.height)),
                            .float(Float(config.cornerRadius)),
                            .float(Float(config.cornerExponent)),
                            .float(Float(config.bezel)),
                            .float(Float(config.strength)),
                            .float(config.mode.rawValue),
                            .float(Float(config.dispersion)),
                            .float(Float(config.fresnelRim)),
                            .float(Float(config.specular)),
                            .float(Float(config.lightAngle))
                        ),
                        maxSampleOffset: CGSize(width: maxSampleOffset, height: maxSampleOffset),
                        isEnabled: true
                    )
                }

            // Layer 2: 前景浮动层（提示、文字、按钮，不受扭曲影响）
            overlay()
        }
    }
}
