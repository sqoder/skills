# macOS 原生分栏与侧边栏标准模版 (NSSplitViewController)

本项目沉淀自 Apple macOS 原生设计规范（HIG）与成熟 macOS App（Glint / 备忘录 / 访达）的最佳实践，提供开箱即用的原生分栏脚手架与通用架构组件。

---

## 📂 目录结构与模块说明

```text
/Users/wangxinglin/Desktop/NSSplitViewController/
├── SKILL.md                          # Antigravity 全局已注册的 Agent Skill 规范
├── README.md                         # 本架构说明指南
├── build_run.sh                      # 一键编译并运行本地记事本 App 脚本
├── notebook_showcase.html            # 1:1 三栏记事本交互式 Web 预览
└── Sources/
    ├── AppDelegate.swift             # AppKit 原生应用启动入口
    ├── NotebookWindowController.swift# 统一工具栏 (unified) 与红黄绿灯托管
    ├── NotebookSplitViewController.swift # 3 栏分栏主控制器 (NSSplitViewController)
    ├── Models/
    │   └── NoteModel.swift           # 文件夹与笔记数据模型
    ├── Sidebar/                      # 【第 1 栏：侧边栏】
    │   ├── SidebarViewController.swift  # SourceList NSOutlineView
    │   ├── AppleSidebarRowView.swift    # 1:1 Apple 纯正蓝药丸选中高亮行
    │   ├── SidebarItemCell.swift        # SF Symbol + 文字 + 计数角标
    │   └── SidebarBottomBarView.swift   # 底部操作栏 (··· 弹窗 + 统计)
    ├── NoteList/                     # 【第 2 栏：笔记卡片列表】
    │   ├── NoteListViewController.swift # NSTableView 笔记流
    │   └── NoteCardCell.swift           # 备忘录卡片 (标题、时间、摘要预览)
    └── Editor/                       # 【第 3 栏：正文编辑器】
        └── NoteEditorViewController.swift # 大标题输入 + 多行正文编辑器
```

---

## ⚡️ 快速开始

### 1. 运行本地原生 macOS 记事本 App
在终端运行：
```bash
cd /Users/wangxinglin/Desktop/NSSplitViewController
./build_run.sh
```

### 2. 在浏览器中查看 1:1 动态设计原型
双击打开 `/Users/wangxinglin/Desktop/NSSplitViewController/notebook_showcase.html`，支持浅色/深色无缝切换与交互。

---

## 💎 为什么这套架构看起来最原生？

1. **统一工具栏与分割线跟踪 (`toolbarStyle = .unified` + `NSTrackingSeparatorToolbarItem`)**
   - 红黄绿交通灯自然嵌入侧边栏顶栏内部，无任何多余边距或悬空感。
   - 工具栏分割线随侧边栏拖拽/折叠平滑联动。
2. **Apple 官方标准 1:1 蓝药丸 (`AppleSidebarRowView`)**
   - 选中行呈现纯正 Apple Blue（`#007AFF`，圆角 6pt），图标与文字自动反白为纯白色。
3. **极简层次与呼吸感**
   - 侧边栏顶部 44pt 空隙为工具栏留足空间，底部 36pt 稳定视觉重心。
