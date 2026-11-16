import AppKit

// MARK: - 三栏式原生分栏视图控制器 (NSSplitViewController)
public final class NotebookSplitViewController: NSSplitViewController {
    public let sidebarVC = SidebarViewController()
    public let noteListVC = NoteListViewController()
    public let noteEditorVC = NoteEditorViewController()

    private var sidebarSplitItem: NSSplitViewItem!
    private var listSplitItem: NSSplitViewItem!
    private var editorSplitItem: NSSplitViewItem!

    public override func viewDidLoad() {
        super.viewDidLoad()
        splitView.dividerStyle = .thin

        // 1. 侧边栏 (Column 1)
        sidebarSplitItem = NSSplitViewItem(sidebarWithViewController: sidebarVC)
        sidebarSplitItem.minimumThickness = 180
        sidebarSplitItem.maximumThickness = 280
        sidebarSplitItem.preferredThicknessFraction = 0.22
        sidebarSplitItem.canCollapse = true
        sidebarSplitItem.holdingPriority = .defaultLow

        // 2. 笔记列表栏 (Column 2)
        listSplitItem = NSSplitViewItem(viewController: noteListVC)
        listSplitItem.minimumThickness = 220
        listSplitItem.maximumThickness = 360
        listSplitItem.preferredThicknessFraction = 0.28
        listSplitItem.holdingPriority = .defaultLow

        // 3. 正文编辑栏 (Column 3)
        editorSplitItem = NSSplitViewItem(viewController: noteEditorVC)
        editorSplitItem.minimumThickness = 380
        editorSplitItem.holdingPriority = .defaultLow

        addSplitViewItem(sidebarSplitItem)
        addSplitViewItem(listSplitItem)
        addSplitViewItem(editorSplitItem)

        bindEvents()
    }

    private func bindEvents() {
        sidebarVC.onSelectFolder = { folder in
            // 切换文件夹时更新中间笔记列表
            print("Selected folder: \(folder.title)")
        }

        noteListVC.onSelectNote = { [weak self] note in
            self?.noteEditorVC.loadNote(note)
        }
    }

    public func toggleSidebar() {
        sidebarSplitItem.animator().isCollapsed.toggle()
    }

    public func createNewNote() {
        let newNote = NoteItem(
            title: "未命名笔记",
            summary: "点击开始输入...",
            content: "# 新建笔记\n\n在此开始记录您的思考..."
        )
        noteListVC.notes.insert(newNote, at: 0)
        noteListVC.selectNote(at: 0)
    }
}
