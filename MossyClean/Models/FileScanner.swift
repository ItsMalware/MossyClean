import Foundation
import Combine
import Combine

struct ScanData: Codable {
    let scannedFiles: [FileModel]
    let duplicates: [String: [FileModel]]
    let potentialSpaceSaved: Int64
}

@MainActor
class FileScanner: ObservableObject {
    @Published var scannedFiles: [FileModel] = []
    @Published var duplicates: [String: [FileModel]] = [:]
    @Published var isScanning: Bool = false
    @Published var progress: Double = 0
    @Published var statusMessage: String = ""
    @Published var potentialSpaceSaved: Int64 = 0
    private var scanTask: Task<Void, Error>?
    
    // Code Protection: Guard these extensions from auto-deletion
    private let protectedExtensions: Set<String> = [
        "py", "swift", "js", "ts", "cpp", "h", "c", "go", "rs", "java", "kt",
        "json", "yml", "yaml", "xml", "sh", "zsh", "env", "md", "markdown"
    ]
    
    func scanHomeDirectory() {
        scan(referenceDrive: FileManager.default.homeDirectoryForCurrentUser, targetDrives: [])
    }
    
    // MARK: - Save and Load Data
    
    private func savePath() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("MossyClean_LastScan.json")
    }

    var hasSavedScan: Bool { 
        FileManager.default.fileExists(atPath: savePath().path) 
    }

    func saveScan() {
        statusMessage = "Saving scan..."
        isScanning = true
        
        Task.detached(priority: .userInitiated) {
            let dataToSave = ScanData(scannedFiles: await self.scannedFiles, duplicates: await self.duplicates, potentialSpaceSaved: await self.potentialSpaceSaved)
            if let encoded = try? JSONEncoder().encode(dataToSave) {
                try? encoded.write(to: await self.savePath())
                Task { @MainActor in
                    self.statusMessage = "Scan saved to Documents."
                    self.isScanning = false
                }
            } else {
                Task { @MainActor in
                    self.statusMessage = "Failed to encode scan data."
                    self.isScanning = false
                }
            }
        }
    }

    func loadScan() {
        statusMessage = "Loading saved scan..."
        isScanning = true
        progress = 0.5
        
        Task.detached(priority: .userInitiated) {
            if let data = try? Data(contentsOf: await self.savePath()),
               let decoded = try? JSONDecoder().decode(ScanData.self, from: data) {
                Task { @MainActor in
                    self.scannedFiles = decoded.scannedFiles
                    self.duplicates = decoded.duplicates
                    self.potentialSpaceSaved = decoded.potentialSpaceSaved
                    self.statusMessage = "Loaded previous scan."
                    self.isScanning = false
                    self.progress = 1.0
                }
            } else {
                 Task { @MainActor in 
                     self.statusMessage = "Failed to load scan." 
                     self.isScanning = false
                 }
            }
        }
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
    
    func scan(referenceDrive: URL?, targetDrives: [URL]) {
        isScanning = true
        progress = 0
        statusMessage = "Starting scan..."
        scannedFiles = []
        duplicates = [:]
        potentialSpaceSaved = 0
        
        let drivesToScan = [referenceDrive].compactMap { $0 } + targetDrives
        guard !drivesToScan.isEmpty else {
            isScanning = false
            statusMessage = "No drives selected."
            return
        }
        
        let protectedExts = protectedExtensions
        
        scanTask = Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            let fileManager = FileManager.default
                let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .fileSizeKey, .contentModificationDateKey]
                
                var currentCount = 0
                var tempScannedFiles: [FileModel] = []
                var sizeGroups: [Int64: [FileModel]] = [:]
                
                // Discovery Phase
                for targetDrive in drivesToScan {
                    let isRef = (targetDrive == referenceDrive)
                    guard let enumerator = fileManager.enumerator(at: targetDrive, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
                        continue
                    }
                    
                    while let fileURL = enumerator.nextObject() as? URL {
                        if Task.isCancelled { return }
                        
                        if let resourceValues = try? fileURL.resourceValues(forKeys: Set(keys)), resourceValues.isDirectory != true {
                            let fileSize = Int64(resourceValues.fileSize ?? 0)
                            let file = FileModel(
                                id: UUID(),
                                url: fileURL,
                                name: resourceValues.name ?? fileURL.lastPathComponent,
                                extensionName: fileURL.pathExtension,
                                size: fileSize,
                                modificationDate: resourceValues.contentModificationDate ?? Date(),
                                isProtected: protectedExts.contains(fileURL.pathExtension.lowercased()),
                                isReference: isRef
                            )
                            
                            tempScannedFiles.append(file)
                            sizeGroups[fileSize, default: []].append(file)
                            currentCount += 1
                            
                            if currentCount % 1000 == 0 {
                                let displayCount = currentCount
                                await MainActor.run {
                                    self.statusMessage = "Discovered \(displayCount) files..."
                                }
                                await Task.yield()
                            }
                        }
                    }
                }
                
                // Hashing Phase
                var hashGroups: [String: [FileModel]] = [:]
                var processedCount = 0
                let totalFiles = tempScannedFiles.count
                var finalFiles: [FileModel] = []
                finalFiles.reserveCapacity(totalFiles)
                
                for var file in tempScannedFiles {
                    if Task.isCancelled { return }
                    
                    let duplicatesInSizeGroup = (sizeGroups[file.size]?.count ?? 0) > 1
                    
                    if duplicatesInSizeGroup {
                        do {
                            let lastUpdate = Date()
                            let hashValue = try await HashEngine.calculateSHA256(for: file.url, fileSize: file.size) { fileProgress in
                                // Only update every 0.25 seconds to avoid flooding MainActor
                                if Date().timeIntervalSince(lastUpdate) > 0.25 {
                                    let percentage = Int(fileProgress * 100)
                                    await MainActor.run {
                                        self.statusMessage = "Analyzing large file: \(file.name) (\(percentage)%)"
                                    }
                                }
                            }
                            file.hash = hashValue
                            
                            if hashGroups[hashValue] != nil {
                                hashGroups[hashValue]?.append(file)
                                file.isDuplicate = true
                            } else {
                                hashGroups[hashValue] = [file]
                            }
                        } catch {
                            // Skip hashing file if unreadable
                        }
                    }
                    
                    finalFiles.append(file)
                    processedCount += 1
                    
                    if processedCount % 500 == 0 {
                        let progressVal = Double(processedCount) / Double(totalFiles)
                        let statusText = duplicatesInSizeGroup ? "Hashing potentials: \(file.name)" : "Processing files..."
                        await MainActor.run {
                            self.progress = progressVal
                            self.statusMessage = statusText
                        }
                        await Task.yield()
                    }
                }
                
                // Finalize results
                let validDuplicates = hashGroups.filter { $0.value.count > 1 }
                var spaceReclaimed: Int64 = 0
                var idsToCleanup = Set<UUID>()
                
                for group in validDuplicates.values {
                    let sorted = group.sorted { (f1, f2) -> Bool in
                        if f1.isReference && !f2.isReference { return true }
                        if !f1.isReference && f2.isReference { return false }
                        return f1.modificationDate > f2.modificationDate
                    }
                    
                    for (index, file) in sorted.enumerated() {
                        if index > 0 && !file.isProtected && !file.isReference {
                            idsToCleanup.insert(file.id)
                            spaceReclaimed += file.size
                        }
                    }
                }
                
                for i in 0..<finalFiles.count {
                    if idsToCleanup.contains(finalFiles[i].id) {
                        finalFiles[i].isSelectedForCleanup = true
                    }
                }
                
                // Update Main Actor with results
                let actualDuplicates = validDuplicates
                let potentialSpace = spaceReclaimed
                let scanned = finalFiles
                
                await MainActor.run {
                    self.scannedFiles = scanned
                    self.duplicates = actualDuplicates
                    self.potentialSpaceSaved = potentialSpace
                    self.isScanning = false
                    self.statusMessage = "Scan complete! Found \(actualDuplicates.count) duplicate groups."
                    self.progress = 1.0
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
