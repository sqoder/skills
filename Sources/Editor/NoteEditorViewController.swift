import AppKit

// MARK: - 笔记正文编辑器 (右侧主内容栏)
public final class NoteEditorViewController: NSViewController {
    private let topSpacer = NSView()
    private let headerDateLabel = NSTextField(labelWithString: "")
    private let titleField = NSTextField()
    private let textScrollView = NSScrollView()
    private let textView = NSTextView()

    private var currentNote: NoteItem?

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

        // 2. 日期信息
        headerDateLabel.translatesAutoresizingMaskIntoConstraints = false
        headerDateLabel.font = .systemFont(ofSize: 11, weight: .regular)
        headerDateLabel.textColor = .tertiaryLabelColor
        headerDateLabel.alignment = .center
        view.addSubview(headerDateLabel)

        // 3. 标题输入
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.font = .systemFont(ofSize: 22, weight: .bold)
        titleField.isBordered = false
        titleField.drawsBackground = false
        titleField.focusRingType = .none
        titleField.placeholderString = "输入笔记标题..."
        view.addSubview(titleField)

        // 4. 正文多行滚动编辑器
        textScrollView.translatesAutoresizingMaskIntoConstraints = false
        textScrollView.drawsBackground = false
        textScrollView.hasVerticalScroller = true
        textScrollView.hasHorizontalScroller = false
        textScrollView.autohidesScrollers = true

        textView.isRichText = false
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .labelColor
        textView.backgroundColor = .clear
        textView.autoresizingMask = [.width]
        textView.textContainer?.containerSize = NSSize(width: textScrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        textScrollView.documentView = textView
        view.addSubview(textScrollView)

        NSLayoutConstraint.activate([
            topSpacer.topAnchor.constraint(equalTo: view.topAnchor),
            topSpacer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSpacer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSpacer.heightAnchor.constraint(equalToConstant: 44),

            headerDateLabel.topAnchor.constraint(equalTo: topSpacer.bottomAnchor, constant: 6),
            headerDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            headerDateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            titleField.topAnchor.constraint(equalTo: headerDateLabel.bottomAnchor, constant: 12),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),

            textScrollView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 14),
            textScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            textScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }

    public func loadNote(_ note: NoteItem) {
        self.currentNote = note
        headerDateLabel.stringValue = "最后修改于 \(note.formattedDate)"
        titleField.stringValue = note.title
        textView.string = note.content
    }
}
