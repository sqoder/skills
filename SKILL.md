---
name: macos-native-splitview
description: >-
  Design and build 1:1 authentic Apple native macOS Sidebars and Multi-Column SplitViews
  (NSSplitViewController, unified toolbar, NSTrackingSeparatorToolbarItem, AppleSidebarRowView,
  SourceList NSOutlineView, and SwiftUI .formStyle(.grouped) / NoteList layouts). Use whenever
  creating or modifying macOS native desktop apps (Finder, Notes, System Settings, Glint style).
---

# macOS Native SplitView & Sidebar Skill (Glint / Apple 1:1 架构规范)

本 Skill 沉淀自 Apple macOS 原生设计规范（HIG）与成熟开源 App（如 Glint / 备忘录 / 访达）的最佳实践架构。
无论何时需要创建 **原生 macOS 侧边栏**、**双栏/三栏分栏应用（如记事本、知识库、管理面板）** 或 **偏好设置窗口**，请直接遵循本套标准架构。

---

## 核心架构原则（Banned Anti-Patterns vs. Golden Rules）

### ❌ 严禁的非原生反模式（Anti-Patterns）
1. **禁止人工在窗口内包裹带边距/阴影的悬浮卡片**：这会导致红黄绿交通灯脱节孤立、浮在半空中。
2. **禁止硬编码暗黑色/非原生背景色**：破坏 macOS 系统浅色/深色自适应，显得廉价。
3. **禁止非标准选中高亮**：绝不要使用带边框的灰色卡片作为选中态，Apple HIG 标准是 **实心纯正蓝药丸（`#007AFF`，圆角 6pt）搭配纯白文字与纯白图标**。
4. **禁止堆砌杂乱模块**：侧边栏必须高度克制，保持 2~3 个分组、每个分组 2~4 个条目，内容简洁透亮。

---

## 💎 黄金架构四件套（Golden Architecture）

### 1. 窗口与统一工具栏 (`toolbarStyle = .unified` + `NSTrackingSeparatorToolbarItem`)
```swift
let win = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 880, height: 560),
    styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView, .resizable],
    backing: .buffered,
    defer: false
)
win.titlebarAppearsTransparent = false
win.titlebarSeparatorStyle = .automatic
win.titleVisibility = .hidden
win.toolbarStyle = .unified
```
- **红黄绿交通灯**：自动位于侧边栏上方，无需任何手动位置计算。
- **分割线跟踪项**：
```swift
NSTrackingSeparatorToolbarItem(
    identifier: .sidebarTrackingSeparator,
    splitView: splitVC.splitView,
    dividerIndex: 0
)
```
- **侧边栏折叠按钮**：使用 `sidebar.leading` 图标，`38x26` texturedRounded 胶囊样式，右推至侧边栏右侧边缘。

---

### 2. 纯正 1:1 Apple 蓝药丸行 (`AppleSidebarRowView`)
```swift
final class AppleSidebarRowView: NSTableRowView {
    private var isHovered = false
    
    override var isEmphasized: Bool { get { true } set { } }
    
    override func drawSelection(in dirtyRect: NSRect) {
        if isSelected {
            let selectionRect = bounds.insetBy(dx: 6, dy: 1)
            let path = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
            NSColor(red: 0.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0).setFill()
            path.fill()
        }
    }
    
    override func drawBackground(in dirtyRect: NSRect) {
        super.drawBackground(in: dirtyRect)
        if !isSelected && isHovered {
            let hoverRect = bounds.insetBy(dx: 6, dy: 1)
            let path = NSBezierPath(roundedRect: hoverRect, xRadius: 6, yRadius: 6)
            let isDark = effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let color = isDark ? NSColor.white.withAlphaComponent(0.06) : NSColor.black.withAlphaComponent(0.04)
            color.setFill()
            path.fill()
        }
    }
}
```

---

### 3. 侧边栏高度规范
- **Top Spacer**：高度 `44pt`，为统一工具栏与红黄绿灯留出天然呼吸感。
- **SourceList OutlineView**：`style = .sourceList`, `rowHeight = 30~32`, `intercellSpacing = (0, 2)`。
- **Bottom Bar**：高度 `36pt`，带有 1px 细分割线，左侧 `···` 原生弹窗按钮，右侧等宽版本号（如 `v1.0.0`）。

---

### 4. 右侧内容区规范（两类经典场景）
1. **记事本/备忘录 (3 栏架构)**：
   - Column 1: `SidebarViewController` (文件夹与标签分类)
   - Column 2: `NoteListViewController` (笔记卡片列表，圆角选中卡片，展示标题、摘要与时间)
   - Column 3: `NoteEditorViewController` (Markdown / 富文本编辑器)
2. **偏好设置/仪表盘 (2 栏架构)**：
   - Column 1: `SidebarViewController`
   - Column 2: SwiftUI `Form { ... }.formStyle(.grouped)`（Apple 官方标准分组圆角卡片）
