import Foundation
import Combine

@MainActor
class FileScanner: ObservableObject {
    @Published var scannedFiles: [FileModel] = []
    @Published var duplicates: [String: [FileModel]] = [:]
    @Published var isScanning: Bool = false
    @Published var progress: Double = 0
    @Published var statusMessage: String = ""
    @Published var potentialSpaceSaved: Int64 = 0
    
    // Code Protection: Guard these extensions from auto-deletion
    private let protectedExtensions: Set<String> = [
        "py", "swift", "js", "ts", "cpp", "h", "c", "go", "rs", "java", "kt",
        "json", "yml", "yaml", "xml", "sh", "zsh", "env", "md", "markdown"
    ]
    
    private var scanTask: Task<Void, Never>?
    
    func scanHomeDirectory() {
        scan(at: FileManager.default.homeDirectoryForCurrentUser)
    }
    
    func manualToggleSelection(for file: FileModel) {
        if let index = scannedFiles.firstIndex(where: { $0.id == file.id }) {
            scannedFiles[index].isSelectedForCleanup.toggle()
            
            // Recalculate potential space saved
            var space: Int64 = 0
            for scannedFile in scannedFiles {
                if scannedFile.isSelectedForCleanup {
                    space += scannedFile.size
                }
            }
            potentialSpaceSaved = space
            
            // Also update the groups mapping to reflect the change visually if needed
            // (The view usually observes scannedFiles group members via scanner)
        }
    }
    
    func scan(at url: URL) {
        isScanning = true
        progress = 0
        statusMessage = "Starting scan..."
        scannedFiles = []
        duplicates = [:]
        potentialSpaceSaved = 0
        
        scanTask = Task {
            do {
                let fileManager = FileManager.default
                let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
                
                // Move discovery to a detached task to avoid blocking MainActor
                let allFileURLs = try await Task.detached(priority: .userInitiated) {
                    guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
                        throw NSError(domain: "ScannerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create enumerator"])
                    }
                    var urls: [URL] = []
                    while let fileURL = enumerator.nextObject() as? URL {
                        urls.append(fileURL)
                    }
                    return urls
                }.value
                
                let totalFiles = allFileURLs.count
                var currentCount = 0
                var tempScannedFiles: [FileModel] = []
                
                // Discovery Phase
                for fileURL in allFileURLs {
                    if Task.isCancelled { return }
                    
                    let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))
                    if resourceValues.isDirectory == true { continue }
                    
                    let file = FileModel(
                        url: fileURL,
                        name: resourceValues.name ?? fileURL.lastPathComponent,
                        extensionName: fileURL.pathExtension,
                        size: Int64(resourceValues.fileSize ?? 0),
                        modificationDate: resourceValues.contentModificationDate ?? Date(),
                        isProtected: protectedExtensions.contains(fileURL.pathExtension.lowercased())
                    )
                    
                    tempScannedFiles.append(file)
                    
                    currentCount += 1
                    if currentCount % 50 == 0 {
                        let currentProgress = Double(currentCount) / Double(totalFiles)
                        self.progress = currentProgress * 0.2
                        self.statusMessage = "Discovered \(currentCount) files..."
                    }
                }
                
                // Hashing Phase
                var hashGroups: [String: [FileModel]] = [:]
                var finalScannedFiles: [FileModel] = []
                
                for (index, var file) in tempScannedFiles.enumerated() {
                    if Task.isCancelled { return }
                    
                    self.statusMessage = "Hashing: \(file.name)"
                    self.progress = 0.2 + (Double(index) / Double(tempScannedFiles.count) * 0.8)
                    
                    // Perform hashing on a background thread
                    let fileURL = file.url
                    let hashValue = try await Task.detached(priority: .userInitiated) {
                        try HashEngine.calculateSHA256(for: fileURL)
                    }.value
                    
                    file.hash = hashValue
                    
                    if hashGroups[hashValue] != nil {
                        hashGroups[hashValue]?.append(file)
                        file.isDuplicate = true
                    } else {
                        hashGroups[hashValue] = [file]
                    }
                    
                    finalScannedFiles.append(file)
                }
                
                // Finalize results
                let actualDuplicates = hashGroups.filter { $0.value.count > 1 }
                
                var space: Int64 = 0
                for group in actualDuplicates.values {
                    // Automatically mark all but the newest as selected for cleanup
                    // UNLESS the file is protected (code/config)
                    let sorted = group.sorted { $0.modificationDate > $1.modificationDate }
                    for (index, file) in sorted.enumerated() {
                        if index > 0 && !file.isProtected {
                            if let originalIndex = finalScannedFiles.firstIndex(where: { $0.id == file.id }) {
                                finalScannedFiles[originalIndex].isSelectedForCleanup = true
                                space += finalScannedFiles[originalIndex].size
                            }
                        }
                    }
                }
                
                self.scannedFiles = finalScannedFiles
                self.duplicates = actualDuplicates
                self.potentialSpaceSaved = space
                self.isScanning = false
                self.statusMessage = "Scan complete! Found \(actualDuplicates.count) duplicate groups."
                
            } catch {
                if !Task.isCancelled {
                    self.isScanning = false
                    self.statusMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func cleanupSelectedFiles() async {
        statusMessage = "Cleaning up..."
        isScanning = true
        
        let filesToRemove = scannedFiles.filter { $0.isSelectedForCleanup }
        var reclaimed: Int64 = 0
        
        for file in filesToRemove {
            do {
                try FileManager.default.trashItem(at: file.url, resultingItemURL: nil)
                reclaimed += file.size
            } catch {
                print("Failed to trash \(file.url): \(error)")
            }
        }
        
        statusMessage = "Cleanup complete! Reclaimed \(ByteCountFormatter.string(fromByteCount: reclaimed, countStyle: .file))"
        isScanning = false
        
        // Refresh scanned files to remove the trashed ones
        scannedFiles.removeAll { $0.isSelectedForCleanup }
        
        // Recalculate duplicates groups
        var newGroups: [String: [FileModel]] = [:]
        for file in scannedFiles {
            if let hash = file.hash {
                newGroups[hash, default: []].append(file)
            }
        }
        duplicates = newGroups.filter { $0.value.count > 1 }
        
        // Reset potential space
        var space: Int64 = 0
        for group in duplicates.values {
            let sorted = group.sorted { $0.modificationDate > $1.modificationDate }
            for i in 1..<sorted.count {
                space += sorted[i].size
            }
        }
        potentialSpaceSaved = space
    }
    
    func cancelScan() {
        scanTask?.cancel()
        isScanning = false
        statusMessage = "Scan cancelled."
    }
}
