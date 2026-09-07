import AppKit
import SwiftUI
import LiquidGlassKit

@main
struct LiquidGlassDemoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 设置为后台挂靠辅助应用，不抢焦点，不占 Dock 栏
        NSApp.setActivationPolicy(.accessory)

        // 直接在真实桌面中央升起一颗高透折射玻璃球！
        DesktopGlassBubble.shared.show(size: 220)
        print(">>> 桌面液态折射气泡已成功启动并在屏幕上显示！按住鼠标即可在任何窗口上拖拽！")
    }
}
