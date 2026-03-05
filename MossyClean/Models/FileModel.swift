import Foundation

struct FileModel: Identifiable, Hashable, Codable {
    let id: UUID
    let url: URL
    let name: String
    let extensionName: String
    let size: Int64
    let modificationDate: Date
    var hash: String?
    var isDuplicate: Bool = false
    var isSelectedForCleanup: Bool = false
    var isProtected: Bool = false
    var isReference: Bool = false    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
    }
    
    var iconName: String {
        // Simple mapping for demo purposes, in real app would use NSWorkspace
        switch extensionName.lowercased() {
        case "jpg", "jpeg", "png", "gif": return "photo"
        case "pdf": return "doc.richtext"
        case "mp4", "mov", "avi": return "video"
        case "zip", "gz", "tar": return "archivebox"
        case "py", "swift", "js", "ts", "cpp", "h", "c", "go", "rs", "java", "kt": return "chevron.left.forwardslash.chevron.right"
        default: return "doc"
        }
    }
}
