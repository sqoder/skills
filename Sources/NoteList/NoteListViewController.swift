import AppKit

// MARK: - 笔记列表控制器 (中间栏 NSTableView)
public final class NoteListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    public var onSelectNote: ((NoteItem) -> Void)?

    private let topSpacer = NSView()
    private let scrollView = NSScrollView()
    private let tableView = NSTableView()

    public var notes: [NoteItem] = [
        NoteItem(
            title: "macOS 原生架构学习笔记",
            summary: "NSSplitViewController 与 unified toolbar 的完美结合...",
            content: "# macOS 原生架构学习笔记\n\n- toolbarStyle = .unified\n- NSTrackingSeparatorToolbarItem\n- AppleSidebarRowView 1:1 蓝药丸",
            isPinned: true
        ),
        NoteItem(
            title: "Swift 5.9 与 AppKit 最佳实践",
            summary: "如何使用现代 Swift 构建极致性能的桌面端 App...",
            content: "# Swift 5.9 与 AppKit 最佳实践\n\n现代 AppKit 开发中，充分利用原生组件能够带来最佳体验。"
        ),
        NoteItem(
            title: "双语输入法词库演进",
            summary: "CET-4, IELTS 与专业术语分级词库管理架构...",
            content: "# 双语输入法词库演进\n\n沉浸式伴随学习，日常打字记忆单词。"
        )
    ]

    private var selectedIndex: Int = 0

    public override func loadView() {
        let rootView = NSView()
        rootView.wantsLayer = true
        self.view = rootView
        setupViews()
    }

    private func setupViews() {
        // 1. Top Spacer (44pt)
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topSpacer)

        // 2. 列表视图
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.headerView = nil
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 64
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        tableView.selectionHighlightStyle = .none
        tableView.backgroundColor = .clear

        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("NoteListColumn"))
        tableView.addTableColumn(col)

        scrollView.documentView = tableView
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            topSpacer.topAnchor.constraint(equalTo: view.topAnchor),
            topSpacer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSpacer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSpacer.heightAnchor.constraint(equalToConstant: 44),

            scrollView.topAnchor.constraint(equalTo: topSpacer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if !notes.isEmpty {
            selectNote(at: 0)
        }
    }

    public func selectNote(at index: Int) {
        guard index >= 0 && index < notes.count else { return }
        selectedIndex = index
        tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
        tableView.reloadData()
        onSelectNote?(notes[index])
    }

    // MARK: - NSTableViewDataSource & Delegate

    public func numberOfRows(in tableView: NSTableView) -> Int {
        return notes.count
    }

    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("NoteCardCell"), owner: self) as? NoteCardCell ?? NoteCardCell()
        cell.identifier = NSUserInterfaceItemIdentifier("NoteCardCell")
        let isSel = (row == selectedIndex)
        cell.configure(note: notes[row], isSelected: isSel)
        return cell
    }

    public func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        guard row >= 0 && row < notes.count else { return }
        selectedIndex = row
        tableView.reloadData()
        onSelectNote?(notes[row])
    }
}
