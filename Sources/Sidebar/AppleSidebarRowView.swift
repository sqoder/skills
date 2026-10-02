import AppKit

// MARK: - Apple 1:1 蓝药丸选中高亮行 (Glint / Apple HIG 规范)
public final class AppleSidebarRowView: NSTableRowView {
    private var isHovered = false
    private var trackingArea: NSTrackingArea?

    public override var isEmphasized: Bool {
        get { true }
        set { }
    }

    public override var isSelected: Bool {
        didSet {
            needsDisplay = true
            updateCellColors()
        }
    }

    public override func didAddSubview(_ subview: NSView) {
        super.didAddSubview(subview)
        updateCellColors()
    }

    private func updateCellColors() {
        for subview in subviews {
            if let cell = subview as? SidebarItemCell {
                cell.isRowSelected = isSelected
            }
        }
    }

    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeInKeyWindow, .inVisibleRect], owner: self, userInfo: nil)
        addTrackingArea(area)
        self.trackingArea = area
    }

    public override func mouseEntered(with event: NSEvent) {
        isHovered = true
        needsDisplay = true
    }

    public override func mouseExited(with event: NSEvent) {
        isHovered = false
        needsDisplay = true
    }

    public override func drawSelection(in dirtyRect: NSRect) {
        if isSelected {
            let selectionRect = bounds.insetBy(dx: 6, dy: 1)
            let path = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
            NSColor(red: 0.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0).setFill()
            path.fill()
        }
    }

    public override func drawBackground(in dirtyRect: NSRect) {
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
