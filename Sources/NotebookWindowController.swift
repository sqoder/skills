import AppKit

// MARK: - 记事本主窗口控制器 (1:1 Apple 原生统一工具栏架构)
public final class NotebookWindowController: NSWindowController, NSToolbarDelegate, NSWindowDelegate {
    public static let shared = NotebookWindowController()

    public let splitVC = NotebookSplitViewController()
    private let sidebarToggleButton = NSButton()
    private let newNoteButton = NSButton()
    private let searchField = NSSearchField()

    public init() {
        let size = CGSize(width: 960, height: 600)
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView, .resizable],
            backing: .buffered,
            defer: false
        )
        win.minSize = CGSize(width: 800, height: 480)
        win.title = "备忘录"
        win.titlebarAppearsTransparent = false
        win.titlebarSeparatorStyle = .automatic
        win.titleVisibility = .hidden
        win.toolbarStyle = .unified
        win.isMovableByWindowBackground = false

        super.init(window: win)
        win.delegate = self

        setupToolbar(for: win)
        win.contentViewController = splitVC
        win.setContentSize(size)
        win.center()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupToolbar(for window: NSWindow) {
        let toolbar = NSToolbar(identifier: "NotebookWindowToolbar")
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.displayMode = .iconOnly
        toolbar.delegate = self
        window.toolbar = toolbar
    }

    // MARK: - NSToolbarDelegate

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .flexibleSpace,
            NSToolbarItem.Identifier("SidebarActionsItem"),
            .sidebarTrackingSeparator,
            NSToolbarItem.Identifier("NewNoteItem"),
            .flexibleSpace,
            NSToolbarItem.Identifier("SearchItem")
        ]
    }

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            // 1. 侧边栏上方折叠按钮
            .flexibleSpace,
            NSToolbarItem.Identifier("SidebarActionsItem"),

            // 2. 侧边栏跟随分割线
            .sidebarTrackingSeparator,

            // 3. 中间栏操作：新建笔记
            NSToolbarItem.Identifier("NewNoteItem"),

            // 4. 弹性空间推至右侧
            .flexibleSpace,

            // 5. 搜索栏
            NSToolbarItem.Identifier("SearchItem")
        ]
    }

    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if itemIdentifier == .sidebarTrackingSeparator {
            return NSTrackingSeparatorToolbarItem(
                identifier: .sidebarTrackingSeparator,
                splitView: splitVC.splitView,
                dividerIndex: 0
            )
        }

        if itemIdentifier == NSToolbarItem.Identifier("SidebarActionsItem") {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let imgConfig = NSImage.SymbolConfiguration(pointSize: 12, weight: .regular)

            sidebarToggleButton.image = NSImage(systemSymbolName: "sidebar.leading", accessibilityDescription: "折叠/展开侧边栏")?.withSymbolConfiguration(imgConfig)
            sidebarToggleButton.target = self
            sidebarToggleButton.action = #selector(handleToggleSidebar)
            sidebarToggleButton.bezelStyle = .texturedRounded
            sidebarToggleButton.isBordered = true
            sidebarToggleButton.focusRingType = .none
            sidebarToggleButton.translatesAutoresizingMaskIntoConstraints = false
            sidebarToggleButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
            sidebarToggleButton.heightAnchor.constraint(equalToConstant: 26).isActive = true

            item.view = sidebarToggleButton
            item.label = "侧边栏"
            return item
        }

        if itemIdentifier == NSToolbarItem.Identifier("NewNoteItem") {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let imgConfig = NSImage.SymbolConfiguration(pointSize: 12, weight: .regular)

            newNoteButton.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "新建笔记")?.withSymbolConfiguration(imgConfig)
            newNoteButton.target = self
            newNoteButton.action = #selector(handleNewNote)
            newNoteButton.bezelStyle = .texturedRounded
            newNoteButton.isBordered = true
            newNoteButton.focusRingType = .none
            newNoteButton.translatesAutoresizingMaskIntoConstraints = false
            newNoteButton.widthAnchor.constraint(equalToConstant: 38).isActive = true
            newNoteButton.heightAnchor.constraint(equalToConstant: 26).isActive = true

            item.view = newNoteButton
            item.label = "新建笔记"
            return item
        }

        if itemIdentifier == NSToolbarItem.Identifier("SearchItem") {
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            searchField.placeholderString = "搜索笔记..."
            searchField.translatesAutoresizingMaskIntoConstraints = false
            searchField.widthAnchor.constraint(equalToConstant: 180).isActive = true
            item.view = searchField
            item.label = "搜索"
            return item
        }

        return nil
    }

    @objc private func handleToggleSidebar() {
        splitVC.toggleSidebar()
    }

    @objc private func handleNewNote() {
        splitVC.createNewNote()
    }

    public func show() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
