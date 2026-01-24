# The Specification: Mossy Clean - Mac Duplicate & Folder Optimizer

## 1. Logical: The Core Concept
**Mossy Clean** is a lightweight, friendly Mac utility designed for non-technical users (friends and family) to reclaim disk space and bring order to digital chaos. It solves two primary problems:
- **Duplicate Explosion:** Finding identical files across multiple locations (including external/cloud drives) and safely removing the "oldest" clutter.
- **Folder Disorganization:** Transforming messy folders into perfectly sorted and named collections using a "Smart Optimize" logic.

### Core "Game" Rules
- **Safety First:** Files are never permanently deleted; they are moved to the macOS Trash for easy recovery.
- **SHA-256 Precision:** Duplicates are identified by their unique digital fingerprint, not just by name or size.
- **The "Groundskeeper" Persona:** A moss-covered robot agent acts as the user's friendly guide, providing suggestions and simple "health reports."

---

## 2. Analytical: Tech Stack & Interface
- **Platform:** Native macOS Application.
- **UI Framework:** **SwiftUI** for a modern, sleek, and premium Mac-native look and feel.
- **Optimization Strategy:**
    - **Tabbed Navigation:** Clean separation between "Duplicate Cleanup" and "Folder Organization."
    - **The "Magic Button":** A prominent "Make My Folders Optimized" feature.
- **Permissions & Scanning:**
    - Scans locally, on mounted external hard drives, and cloud-mounted drives (Google Drive, iCloud, etc.).
    - Option to scan specific folders via drag-and-drop or the entire user directory.
- **AI Integration:** A mini-agent (visualized as a robot) that analyzes filenames to suggest the best "Top Name" for folder organization.

---

## 3. Computational: Milestones & Logic
### Milestone 1: Duplicate Scanning (Core Engine)
- Find duplicates across all selected volumes via SHA-256.
- **Rule:** Keep the "newest" version. User can choose sorting criteria (Alphabetical, Date Created, Date Added).
- **Space Saved:** Display a summary of potential space recovery before action.

### Milestone 2: Folder Organization (The "00" Filter)
- Prompt for a "Top Name" (suggested by AI or typed by user).
- **Naming Convention:** `[XX]_[TopName]_[TruncatedOriginalName].[ext]`
    - Example: `01_Vacation_beach_party.jpg`
- **Perfect Sorting:** Leading numbers increment (01, 02, 03...) based on user-selected sort order.
- **Truncation:** Keep extensions intact; truncate long file names to maintain folder cleanliness.

### Milestone 3: The Preview (Safety Mode)
- An optional "Dry Run" view showing exactly what will be moved/renamed before execution.

---

## 4. Procedural: User Demographic & Strategy
- **Demographic:** Family and friends who want a "heavy lifting" tool that feels lightweight and safe.
- **Visual Engagement:**
    - The "Groundskeeper" robot provides context and personality.
    - Simple, high-contrast UI following the `ui-ux-pro-max` guidelines.
- **The Summary Report:** After optimization, the robot provides a simple "thank you" notebook entry showing "Digital Health Progress" and space saved.

---

## The Groundskeeper
![The Mossy Groundskeeper](file:///Users/yaz_malware_honeypot/.gemini/antigravity/brain/bda18899-1f42-4191-9507-eb79a4331322/agent.png)

> "I've handled the files with care. Your folders are now as tidy as a well-kept garden!"
