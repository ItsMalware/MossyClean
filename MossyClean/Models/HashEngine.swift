import Foundation
import CryptoKit

struct HashEngine {
    /// Calculates SHA-256 hash for a file at the given URL.
    /// Reads in chunks to handle large files efficiently.
    static func calculateSHA256(for url: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: url)
        defer {
            try? handle.close()
        }
        
        var hasher = SHA256()
        let bufferSize = 1024 * 1024 // 1MB buffer
        
        while let data = try handle.read(upToCount: bufferSize), !data.isEmpty {
            hasher.update(data: data)
        }
        
        let digest = hasher.finalize()
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
