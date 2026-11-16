import AppKit

// MARK: - 侧边栏 AppKit 原生底栏 (更多操作 + 笔记数统计)
public final class SidebarBottomBarView: NSView {
    public var onNewFolder: (() -> Void)?

    private let menuButton = NSButton()
    private let statsLabel = NSTextField(labelWithString: "")
    private let divider = NSBox()

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.boxType = .separator
        addSubview(divider)

        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.bezelStyle = .regularSquare
        menuButton.isBordered = false
        menuButton.image = NSImage(systemSymbolName: "ellipsis", accessibilityDescription: "更多操作")
        menuButton.contentTintColor = .secondaryLabelColor
        menuButton.target = self
        menuButton.action = #selector(showMenu(_:))
        addSubview(menuButton)

        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsLabel.font = .monospacedSystemFont(ofSize: 10.5, weight: .regular)
        statsLabel.textColor = .tertiaryLabelColor
        statsLabel.alignment = .right
        addSubview(statsLabel)

        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),

            menuButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            menuButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 24),
            menuButton.heightAnchor.constraint(equalToConstant: 20),

            statsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            statsLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    public func updateStats(text: String) {
        statsLabel.stringValue = text
    }

    @objc private func showMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "新建文件夹...", action: #selector(newFolderAction), keyEquivalent: "N"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "在访达中显示笔记库", action: nil, keyEquivalent: ""))

        for item in menu.items {
            item.target = self
        }
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height + 4), in: sender)
    }

    @objc private func newFolderAction() {
        onNewFolder?()
    }
}
