# Mossy Clean Lessons Learned

Actionable insights and technical constraints discovered during development.

## SwiftUI & Navigation
- **NavigationLink Selection**: When using `tag` and `selection` in `NavigationView` (Sidebar), the selection binding must be an **optional** type of the tag enum (e.g., `Tab?`) to allow for state transitions and initial value matching.
- **Mesh Gradients**: Using blurred circles (`Circle().blur()`) in a `ZStack` is an effective way to create premium "mesh gradient" backgrounds without complex external libraries.

## Concurrency (Swift 6)
- **@MainActor for UI Updates**: Mark `ObservableObject` classes (like `FileScanner`) with `@MainActor` to ensure all `@Published` properties are updated on the main thread, avoiding data races in modern Swift.
- **NSDirectoryEnumerator in Async**: `for-in` loops over `NSDirectoryEnumerator` are unavailable in asynchronous contexts. Use `while let fileURL = enumerator.nextObject() as? URL` instead.
- **Detached Tasks & Sendable**: When performing heavy work (like SHA-256 hashing) in a `Task.detached`, ensure that only `Sendable` types (like `URL` or `String`) are passed into the closure. Avoid capturing non-Sendable properties of `self` directly.

## File System
- **Powerbox & Sandboxing**: For macOS utility apps, prioritize `NSOpenPanel` for user-initiated folder selection to handle security scope and Powerbox requirements gracefully.
- **Efficient Hashing**: Use chunked reading (e.g., 1MB buffers) when calculating file hashes to avoid loading entire large files into memory.
