import AppKit

// MARK: - 备忘录风格笔记卡片行视图 (NoteCardCell)
public final class NoteCardCell: NSTableCellView {
    private let titleLabel = NSTextField(labelWithString: "")
    private let dateLabel = NSTextField(labelWithString: "")
    private let summaryLabel = NSTextField(labelWithString: "")
    private let pinIcon = NSImageView()
    private let containerBox = NSBox()

    public var isSelected: Bool = false {
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
        containerBox.boxType = .custom
        containerBox.cornerRadius = 8
        containerBox.borderWidth = 0
        containerBox.fillColor = .clear
        containerBox.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerBox)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13.5, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        containerBox.addSubview(titleLabel)

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 11, weight: .regular)
        dateLabel.textColor = .secondaryLabelColor
        containerBox.addSubview(dateLabel)

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .systemFont(ofSize: 12, weight: .regular)
        summaryLabel.textColor = .secondaryLabelColor
        summaryLabel.lineBreakMode = .byTruncatingTail
        containerBox.addSubview(summaryLabel)

        pinIcon.translatesAutoresizingMaskIntoConstraints = false
        pinIcon.image = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: nil)
        pinIcon.contentTintColor = .systemOrange
        pinIcon.isHidden = true
        containerBox.addSubview(pinIcon)

        NSLayoutConstraint.activate([
            containerBox.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerBox.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            containerBox.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),

            titleLabel.leadingAnchor.constraint(equalTo: containerBox.leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: containerBox.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: pinIcon.leadingAnchor, constant: -6),

            pinIcon.trailingAnchor.constraint(equalTo: containerBox.trailingAnchor, constant: -10),
            pinIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            pinIcon.widthAnchor.constraint(equalToConstant: 12),
            pinIcon.heightAnchor.constraint(equalToConstant: 12),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            summaryLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 8),
            summaryLabel.trailingAnchor.constraint(equalTo: containerBox.trailingAnchor, constant: -10),
            summaryLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor)
        ])
    }

    public func configure(note: NoteItem, isSelected: Bool) {
        self.isSelected = isSelected
        titleLabel.stringValue = note.title.isEmpty ? "无标题笔记" : note.title
        dateLabel.stringValue = note.formattedDate
        summaryLabel.stringValue = note.summary.isEmpty ? "无额外文本" : note.summary
        pinIcon.isHidden = !note.isPinned
        updateColors()
    }

    private func updateColors() {
        if isSelected {
            containerBox.fillColor = NSColor.controlAccentColor.withAlphaComponent(0.18)
            containerBox.borderWidth = 1
            containerBox.borderColor = NSColor.controlAccentColor.withAlphaComponent(0.35)
            titleLabel.textColor = .controlAccentColor
        } else {
            containerBox.fillColor = .clear
            containerBox.borderWidth = 0
            titleLabel.textColor = .labelColor
        }
    }
}
