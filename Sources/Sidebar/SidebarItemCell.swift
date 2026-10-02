import AppKit

// MARK: - 侧边栏行内容视图 (图标 + 标题 + 数字角标)
public final class SidebarItemCell: NSTableCellView {
    private let iconImageView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let countLabel = NSTextField(labelWithString: "")

    public var isRowSelected: Bool = false {
        didSet {
            updateColors()
        }
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.imageScaling = .scaleProportionallyDown
        iconImageView.contentTintColor = .secondaryLabelColor
        addSubview(iconImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)

        countLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        countLabel.textColor = .tertiaryLabelColor
        countLabel.alignment = .right
        addSubview(countLabel)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            countLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 4),
            countLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            countLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    public func configure(item: FolderItem, isSelected: Bool) {
        iconImageView.image = NSImage(systemSymbolName: item.icon, accessibilityDescription: nil)
        titleLabel.stringValue = item.title
        countLabel.stringValue = item.count > 0 ? "\(item.count)" : ""
        self.isRowSelected = isSelected
    }

    private func updateColors() {
        if isRowSelected {
            iconImageView.contentTintColor = .white
            titleLabel.textColor = .white
            titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
            countLabel.textColor = NSColor.white.withAlphaComponent(0.85)
        } else {
            iconImageView.contentTintColor = .secondaryLabelColor
            titleLabel.textColor = .labelColor
            titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
            countLabel.textColor = .tertiaryLabelColor
        }
    }
}
