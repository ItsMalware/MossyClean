# Mossy Clean Project To-Dos

## Phase 1: Foundation & Navigation
- [x] Initialize macOS SwiftUI Project `Mossy Clean`
- [x] Implement Sidebar/Tabbed Navigation
- [x] Create `FileModel` data structure
- [x] Design "Scanner" Landing View (Drag & Drop zone)
- [x] Design "Organizer" View
- [x] Implement Settings View (Move to Trash / Truncate Toggles)
- [x] Apply Dark Mode / Mesh Gradient Styling

## Phase 2: The SHA-256 Engine
- [x] Implement `FileScanner` recursive traversal logic
- [x] Integrate `CommonCrypto` / `CryptoKit` for SHA-256 hashing
- [x] Implement duplicate grouping logic
- [x] Implement "Newest Version" identification logic
- [x] Create scanning summary report (File count / Potential space saved)
- [x] Handle `FileManager` permissions and errors

## Phase 3: Selection & Trash Logic
- [x] Build Results Preview List (Grouped duplicates)
- [x] Implement manual "Keep/Trash" selection toggles
- [x] Implement `trashItem` logic for safe deletion
- [x] Add "Space Reclaimed" success summary
- [x] Implement confetti/success animation

## Phase 4: Folder Optimization (The "00" Filter)
- [x] Implement renaming logic: `[XX]_[TopName]_[OriginalName].[ext]`
- [x] Implement filename truncation (max 30 chars)
- [x] Implement "Smart Suggest" for Top Name (Keyword analysis)
- [x] Build Rename Preview View
- [x] Execute bulk renaming with undo support (Trash-based)

## Phase 5: The Mossy Groundskeeper & Polish
- [x] Integrate Mossy Groundskeeper mascot (Sidebar companion)
- [x] Implement persistent settings with AppStorage
- [x] Animate Mossy mascot (Interaction & Idle)
- [x] Add organic "moss" decor to sidebar glass
- [x] Fix mascot framing and sidebar positioning
- [x] Final UI/UX polish and transitions
- [x] Final build verification and cleanup

## Phase 6: Glassmorphic Industrial Pro (UI/UX Pro Max)
- [x] Implement Glassmorphic Theme with `ultraThinMaterial`
- [x] Refine Industrial Borders to metallic double-stroke
- [x] Update Typography to Inter-inspired hierarchy
- [x] Add "Haptic Pulse" micro-animations to all interactions
- [x] Transform MeshGradient into "Living Industrial Mesh"
- [x] Apply "Pro Max" spacing (48px+ gaps) across all views

## Phase 7: Safety & Clarity 🛡️🔍
- [x] Implement Code Protection Engine (skip auto-selection for .py, .swift, etc.)
- [x] Add "OR" separator in Scanner View
- [x] Enable functional "Scan Entire Mac" (Home Directory)
- [x] Confirm SHA-256 usage in HashEngine
- [x] Fix Navigation Bug: Ensure Review area can be reopened (State promotion to MainView)

## Phase 8: Risk-Aware Override 🛡️⚖️
- [x] Implement manual selection for protected files
- [x] Add Risk Confirmation alert for protected artifacts
- [x] Add "Export & Inspect" functionality (Clipboard sync)

**MISSION COMPLETE! The Mossy ground is clean.**
