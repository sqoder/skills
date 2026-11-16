import Foundation

// MARK: - 侧边栏分类模型
public struct FolderItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let icon: String
    public var count: Int

    public init(id: String, title: String, icon: String, count: Int = 0) {
        self.id = id
        self.title = title
        self.icon = icon
        self.count = count
    }
}

// MARK: - 笔记数据模型
public struct NoteItem: Identifiable, Hashable {
    public let id: String
    public var title: String
    public var summary: String
    public var content: String
    public var updatedAt: Date
    public var isPinned: Bool
    public var folderId: String

    public init(
        id: String = UUID().uuidString,
        title: String,
        summary: String,
        content: String,
        updatedAt: Date = Date(),
        isPinned: Bool = false,
        folderId: String = "all"
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.content = content
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.folderId = folderId
    }

    public var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(updatedAt) {
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDateInYesterday(updatedAt) {
            return "昨天"
        } else {
            formatter.dateFormat = "M/d"
        }
        return formatter.string(from: updatedAt)
    }
}
