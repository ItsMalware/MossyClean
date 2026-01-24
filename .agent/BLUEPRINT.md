# Technical Blueprint: Mossy Clean

This blueprint breaks down the development of **Mossy Clean** into five actionable phases. Each phase includes a specific prompt designed for a high-intelligence coding agent.

## Project Overview
- **Stack:** macOS Native (SwiftUI)
- **Core Logic:** SHA-256 deduplication + AI-driven folder organization.
- **Safety:** All deletions move to Trash.

---

## Phase 1: Foundation & Navigation
**Goal:** Initialize the macOS project and establish the tabbed UI structure.

### Phase 1 Prompt:
> Initialize a new macOS SwiftUI project named "Mossy Clean". Create a window with a sidebar or tabbed navigation containing three areas: 
> 1. **Scanner:** A landing area with a "Drop Folder Here" zone and a "Scan Entire Mac" button.
> 2. **Organizer:** A view for the "Make My Folders Optimized" feature.
> 3. **Settings:** Toggle for "Move to Trash" (default ON) and "Truncate Long Names".
> Use a premium dark-themed aesthetic with mesh gradients. Define the `FileModel` struct to hold file metadata.

---

## Phase 2: The SHA-256 Engine
**Goal:** Implement the scanning logic and duplicate detection.

### Phase 2 Prompt:
> Implement the `FileScanner` class. It should recursively traverse directories and calculate SHA-256 hashes for all files. 
> 1. Use `CommonCrypto` or `CryptoKit` for hashes. 
> 2. Group files by hash and identify duplicates. 
> 3. Implement logic to identify the "Newest" version based on `contentModificationDate`.
> 4. Display a summary of duplicates found and the potential storage space (in GB/MB) to be reclaimed.
> **Constraint:** Use real file system APIs (`FileManager`). Handle file permissions gracefully.

---

## Phase 3: Selection & Trash Logic
**Goal:** Create the "Preview" mode and the safe deletion workflow.

### Phase 3 Prompt:
> Build the **Results Preview View**. 
> 1. Display duplicates in groups, showing the "Keep" (Newest) and "Trash" (Oldest) candidates.
> 2. Allow users to manually toggle which copy to keep.
> 3. Implement the "Clean Up" action: Use `FileManager.default.trashItem(at:resultingItemURL:)` to move files to the system Trash safely.
> 4. Add a "Space Reclaimed" confetti animation or summary upon completion.

---

## Phase 4: AI Folder Optimization
**Goal:** Implement the "00_Name" naming convention and AI suggestions.

### Phase 4 Prompt:
> Build the **Folder Optimizer** logic.
> 1. When a folder is selected, iterate through files and prepare a renaming map based on the pattern: `[01-XX]_[TopName]_[TruncatedOriginalName].[ext]`.
> 2. Implement truncated naming (max 30 chars for the original name part).
> 3. Create a mock or real interface for a "Mini AI Agent" that suggests the `TopName` based on the folder's existing name and common keywords found in its files.
> 4. Provide a "Preview Renaming" list before any system changes are committed.

---

## Phase 5: The Mossy Groundskeeper & Polish
**Goal:** Integrate the character and final UI/UX polish.

### Phase 5 Prompt:
> Integrate the "Mossy Groundskeeper" agent (asset: `agent.png`).
> 1. Display the agent in a corner of the app or during scan transitions.
> 2. Implement the "Notebook Summary" feature: A small pop-up or view where the robot provides a friendly report on the "Digital Health Score" of the folder.
> 3. Add smooth transitions between tabs and hover effects for buttons.
> 4. Ensure the app is fully sandboxed but handles `Powerbox` permissions correctly for external drives.

---

## Technical Recommendations
- **Model:** Use Gemini 1.5 Pro or similar for execution.
- **Safety:** Always verify volume-level permissions before initiating large scans.
- **Performance:** Run SHA-256 calculations on background threads to keep the UI responsive.
