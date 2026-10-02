import AppKit

// MARK: - 侧边栏控制器 (NSOutlineView SourceList 规范)
public final class SidebarViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    public var onSelectFolder: ((FolderItem) -> Void)?

    private let topSpacer = NSView()
    private let scrollView = NSScrollView()
    private let outlineView = NSOutlineView()
    private let bottomBar = SidebarBottomBarView()

    public struct SectionData {
        public let title: String
        public var items: [FolderItem]
    }

    public var sections: [SectionData] = [
        SectionData(title: "快速访问", items: [
            FolderItem(id: "all", title: "全部笔记", icon: "tray.full", count: 8),
            FolderItem(id: "quick", title: "速记灵感", icon: "sparkle", count: 3)
        ]),
        SectionData(title: "分类与标签", items: [
            FolderItem(id: "work", title: "工作与项目", icon: "folder", count: 4),
            FolderItem(id: "study", title: "学习笔记", icon: "book", count: 1),
            FolderItem(id: "archive", title: "归档", icon: "archivebox", count: 0)
        ])
    ]

    private var selectedFolderId: String = "all"

    public override func loadView() {
        let rootView = NSView()
        rootView.wantsLayer = true
        self.view = rootView
        setupViews()
    }

    private func setupViews() {
        // 1. Top Spacer: 44pt 为 unified 工具栏与红黄绿灯留足呼吸感
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topSpacer)

        // 2. SourceList 列表
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        outlineView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.headerView = nil
        outlineView.style = .sourceList
        outlineView.floatsGroupRows = false
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.rowHeight = 32
        outlineView.intercellSpacing = NSSize(width: 0, height: 2)

        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("NotebookSidebarColumn"))
        col.isEditable = false
        outlineView.addTableColumn(col)
        outlineView.outlineTableColumn = col

        scrollView.documentView = outlineView
        view.addSubview(scrollView)

        // 3. Bottom Bar
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.updateStats(text: "8 篇笔记")
        view.addSubview(bottomBar)

        NSLayoutConstraint.activate([
            topSpacer.topAnchor.constraint(equalTo: view.topAnchor),
            topSpacer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSpacer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSpacer.heightAnchor.constraint(equalToConstant: 44),

            scrollView.topAnchor.constraint(equalTo: topSpacer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        outlineView.expandItem(nil, expandChildren: true)
        selectFirstItem()
    }

    private func selectFirstItem() {
        if let first = sections.first?.items.first {
            selectedFolderId = first.id
            outlineView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
        }
    }

    // MARK: - NSOutlineViewDataSource

    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil { return sections.count }
        if let s = item as? SectionData { return s.items.count }
        return 0
    }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { return sections[index] }
        if let s = item as? SectionData { return s.items[index] }
        return ""
    }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is SectionData
    }

    public func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is SectionData
    }

    public func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return item is FolderItem
    }

    public func outlineView(_ outlineView: NSOutlineView, shouldCollapseItem item: Any) -> Bool {
        return false
    }

    public func outlineView(_ outlineView: NSOutlineView, shouldExpandItem item: Any) -> Bool {
        return true
    }

    public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return AppleSidebarRowView()
    }

    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let section = item as? SectionData {
            let label = NSTextField(labelWithString: section.title)
            label.font = .systemFont(ofSize: 11, weight: .bold)
            label.textColor = .secondaryLabelColor
            return label
        } else if let folder = item as? FolderItem {
            let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("SidebarFolderCell"), owner: self) as? SidebarItemCell ?? SidebarItemCell()
            cell.identifier = NSUserInterfaceItemIdentifier("SidebarFolderCell")
            let isSel = (folder.id == selectedFolderId)
            cell.configure(item: folder, isSelected: isSel)
            return cell
        }
        return nil
    }

    public func outlineViewSelectionDidChange(_ notification: Notification) {
        let row = outlineView.selectedRow
        guard row >= 0, let folder = outlineView.item(atRow: row) as? FolderItem else { return }
        selectedFolderId = folder.id
        onSelectFolder?(folder)
    }
}
