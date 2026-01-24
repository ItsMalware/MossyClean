import Foundation
import Combine

struct RenamePair: Identifiable, Hashable {
    let id = UUID()
    let originalURL: URL
    let originalName: String
    let newName: String
    let extensionName: String
    
    var newFullURL: URL {
        originalURL.deletingLastPathComponent().appendingPathComponent(newName)
    }
}

@MainActor
class FileOrganizer: ObservableObject {
    @Published var selectedFolder: URL?
    @Published var suggestedTopName: String = ""
    @Published var renamePairs: [RenamePair] = []
    @Published var isProcessing: Bool = false
    @Published var statusMessage: String = ""
    
    func selectFolder(at url: URL) {
        self.selectedFolder = url
        generateHeuristicName(for: url)
        preparePreview()
    }
    
    private func generateHeuristicName(for url: URL) {
        // Simple heuristic: Use folder name, stripping common suffixes
        var name = url.lastPathComponent
        let suffixes = ["_files", " backup", " Copy", " export"]
        for suffix in suffixes {
            if let range = name.range(of: suffix, options: .caseInsensitive) {
                name.removeSubrange(range)
            }
        }
        self.suggestedTopName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updateTopName(_ newName: String) {
        self.suggestedTopName = newName
        preparePreview()
    }
    
    func preparePreview() {
        guard let folderURL = selectedFolder else { return }
        
        Task {
            statusMessage = "Processing preview..."
            
            // Capture local copy of suggestedTopName
            let topName = self.suggestedTopName
            
            let pairs = await Task.detached(priority: .userInitiated) { [topName] in
                var pairs: [RenamePair] = []
                do {
                    let fileManager = FileManager.default
                    let contents = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: [.nameKey, .isDirectoryKey, .creationDateKey], options: .skipsHiddenFiles)
                    
                    let fileURLs = contents.filter { url in
                        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == false
                    }
                    
                    let sortedURLs = fileURLs.sorted { url1, url2 in
                        let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                        let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date.distantPast
                        return date1 < date2
                    }
                    
                    for (index, url) in sortedURLs.enumerated() {
                        let originalName = url.lastPathComponent
                        let extensionName = url.pathExtension
                        let indexString = String(format: "%02d", index + 1)
                        let baseName = url.deletingPathExtension().lastPathComponent
                        let truncatedBase = String(baseName.prefix(30))
                        
                        let finalName = "[\(indexString)]_\(topName)_\(truncatedBase).\(extensionName)"
                        
                        pairs.append(RenamePair(
                            originalURL: url,
                            originalName: originalName,
                            newName: finalName,
                            extensionName: extensionName
                        ))
                    }
                } catch {
                    print("Error in preparePreview: \(error)")
                }
                return pairs
            }.value
            
            self.renamePairs = pairs
            self.statusMessage = ""
        }
    }
    
    func performRename() {
        isProcessing = true
        statusMessage = "Optimizing files..."
        
        Task {
            // Capture local copy of renamePairs
            let pairs = self.renamePairs
            
            let successCount = await Task.detached(priority: .userInitiated) { [pairs] in
                let fileManager = FileManager.default
                var count = 0
                for pair in pairs {
                    do {
                        try fileManager.moveItem(at: pair.originalURL, to: pair.newFullURL)
                        count += 1
                    } catch {
                        print("Failed to rename \(pair.originalURL.lastPathComponent): \(error)")
                    }
                }
                return count
            }.value
            
            self.statusMessage = "Optimization complete! Groundskeeper processed \(successCount) files."
            self.isProcessing = false
            
            if successCount > 0 {
                self.selectedFolder = nil
                self.renamePairs = []
            }
        }
    }
}
