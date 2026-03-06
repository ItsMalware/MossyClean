import Foundation
import CryptoKit

struct HashEngine {
    /// Calculates SHA-256 hash for a file at the given URL.
    /// Reads in chunks to handle large files efficiently.
    static func calculateSHA256(for url: URL, fileSize: Int64 = 0, progressUpdate: ((Double) async -> Void)? = nil) async throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer {
            try? handle.close()
        }
        
        var hasher = SHA256()
        let bufferSize = 1024 * 1024 * 4 // 4MB buffer based on large file testing
        var totalBytesRead: Int64 = 0
        
        while let data = try handle.read(upToCount: bufferSize), !data.isEmpty {
            try Task.checkCancellation()
            
            hasher.update(data: data)
            totalBytesRead += Int64(data.count)
            
            if let progressUpdate = progressUpdate, fileSize > 0 {
                let currentProgress = Double(totalBytesRead) / Double(fileSize)
                await progressUpdate(currentProgress)
            }
            
            await Task.yield()
        }
        
        let digest = hasher.finalize()
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
