import SwiftUI
import UniformTypeIdentifiers

struct ScannerView: View {
    @ObservedObject var scanner: FileScanner
    @State private var referenceDrive: URL?
    @State private var targetDrives: [URL] = []
    @State private var navigatingToResults = false
    
    // Drag state for different drop zones
    @State private var isDraggingReference: Bool = false
    @State private var isDraggingTarget: Bool = false
    
    var body: some View {
        VStack(spacing: 48) { // Pro Max spacing
            Text("Mossy Clean")
                .font(.industrialLargeTitle)
                .foregroundColor(Theme.textColor)
            
            VStack {
                if scanner.isScanning {
                    VStack(spacing: 20) {
                        ProgressView(value: scanner.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: Theme.accentColor))
                            .frame(width: 300)
                        
                        Text(scanner.statusMessage)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Theme.subtleTextColor)
                        
                        Button("Cancel Scan") {
                            withAnimation {
                                scanner.cancelScan()
                            }
                        }
                        .buttonStyle(LinkButtonStyle())
                    }
                    .frame(height: 300)
                    .transition(.opacity.combined(with: .scale))
                } else {
                    VStack(spacing: 20) {
                        // Scan Setup Area
                        HStack(spacing: 24) {
                            // Reference Drive Zone
                            VStack {
                                Text("(Optional) Safe Reference Drive")
                                    .font(.industrialHeadline)
                                    .foregroundColor(Theme.textColor)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isDraggingReference ? Theme.accentColor : Theme.subtleTextColor.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                        .background(referenceDrive != nil ? Theme.accentColor.opacity(0.1) : Color.clear)
                                        .cornerRadius(16)
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: referenceDrive != nil ? "externaldrive.fill.badge.checkmark" : "externaldrive.badge.plus")
                                            .font(.system(size: 32))
                                            .foregroundColor(referenceDrive != nil ? Theme.accentColor : Theme.subtleTextColor)
                                        
                                        if let url = referenceDrive {
                                            Text(url.lastPathComponent)
                                                .font(.industrialBody)
                                                .foregroundColor(Theme.textColor)
                                            Button("Clear") {
                                                referenceDrive = nil
                                            }
                                            .font(.caption)
                                            .foregroundColor(Theme.warnColor)
                                            .buttonStyle(PlainButtonStyle())
                                        } else {
                                            Text("Drop or Click")
                                                .font(.industrialBody)
                                                .foregroundColor(Theme.subtleTextColor)
                                        }
                                    }
                                }
                                .frame(height: 140)
                                .onTapGesture { selectFolder(forTarget: false) }
                                .onDrop(of: [UTType.folder], isTargeted: $isDraggingReference) { providers in
                                    handleDrop(providers: providers, isTarget: false)
                                    return true
                                }
                            }
                            
                            // Target Drives Zone
                            VStack {
                                Text("Drives to Clean")
                                    .font(.industrialHeadline)
                                    .foregroundColor(Theme.textColor)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isDraggingTarget ? Theme.accentColor : Theme.subtleTextColor.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                        .background(!targetDrives.isEmpty ? Theme.accentColor.opacity(0.05) : Color.clear)
                                        .cornerRadius(16)
                                    
                                    VStack(spacing: 12) {
                                        Image(systemName: "folder.badge.plus")
                                            .font(.system(size: 32))
                                            .foregroundColor(!targetDrives.isEmpty ? Theme.accentColor : Theme.subtleTextColor)
                                        
                                        if !targetDrives.isEmpty {
                                            ScrollView {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    ForEach(targetDrives, id: \.self) { url in
                                                        HStack {
                                                            Text(url.lastPathComponent)
                                                                .font(.industrialMono)
                                                                .foregroundColor(Theme.textColor)
                                                                .lineLimit(1)
                                                            Spacer()
                                                            Button(action: {
                                                                targetDrives.removeAll { $0 == url }
                                                            }) {
                                                                Image(systemName: "xmark.circle.fill")
                                                                    .foregroundColor(Theme.subtleTextColor)
                                                            }
                                                            .buttonStyle(PlainButtonStyle())
                                                        }
                                                        .padding(.horizontal, 8)
                                                    }
                                                }
                                            }
                                            .frame(maxHeight: 80)
                                        } else {
                                            Text("Drop or Click")
                                                .font(.industrialBody)
                                                .foregroundColor(Theme.subtleTextColor)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                }
                                .frame(height: 140)
                                .onTapGesture { selectFolder(forTarget: true) }
                                .onDrop(of: [UTType.folder], isTargeted: $isDraggingTarget) { providers in
                                    handleDrop(providers: providers, isTarget: true)
                                    return true
                                }
                            }
                        }
                        .padding(.horizontal, 48)
                        
                        // Start Scan Button
                        Button(action: {
                            Task { @MainActor in
                                withAnimation {
                                    scanner.scan(referenceDrive: referenceDrive, targetDrives: targetDrives)
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text(referenceDrive != nil ? "Start Cross-Drive Scan" : "Start Scan")
                            }
                            .font(.industrialHeadline)
                            .padding(.horizontal, 48)
                            .padding(.vertical, 16)
                            .background(targetDrives.isEmpty ? Theme.subtleTextColor.opacity(0.2) : Theme.accentColor)
                            .foregroundColor(targetDrives.isEmpty ? Theme.subtleTextColor : .black)
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(targetDrives.isEmpty)
                        
                        // Load Saved Scan Button
                        if scanner.hasSavedScan && scanner.duplicates.isEmpty {
                            Button("Load Previous Scan") {
                                scanner.loadScan()
                            }
                            .font(.industrialBody)
                            .foregroundColor(Theme.accentColor)
                            .padding(.top, 10)
                            .buttonStyle(LinkButtonStyle())
                        }
                    }
                    .padding(.vertical, 24)
                    .modifier(Theme.GlassBackground())
                    .padding(.horizontal, 24)
                    .transition(.opacity)
                    
                    if !scanner.duplicates.isEmpty {
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Theme.warnColor)
                                Text("Found \(scanner.duplicates.count) Duplicate Groups")
                                    .font(.system(.headline, design: .monospaced))
                            }
                                                       Button(action: {
                                navigatingToResults = true
                            }) {
                                Text("Review & Cleanup")
                                    .font(.industrialHeadline)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Theme.accentColor, Theme.accentColor.opacity(0.8)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                                    .shadow(color: Theme.accentColor.opacity(0.3), radius: 15, y: 5)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .modifier(Theme.HapticPulse(isActive: false))
                            
                            Text(scanner.potentialSpaceSaved > 0 ? "Potential space to reclaim: \(ByteCountFormatter.string(fromByteCount: scanner.potentialSpaceSaved, countStyle: .file))" : "Mac state: Optimized")
                                .font(.industrialMono)
                                .foregroundColor(Theme.subtleTextColor)
                        }
                        .padding(40)
                        .modifier(Theme.GlassBackground()) // Pro Max: Glass results card
                        .sheet(isPresented: $navigatingToResults) {
                            ResultsView(scanner: scanner)
                                .frame(minWidth: 700, minHeight: 500)
                        }
                    } else {
                        // Removed Home Directory quick link as its now handled via explicit drag/drop target
                    }
                }
            }
            
            Spacer()
            
            // Industrial Status Indicator
            HStack {
                Spacer()
                HStack(spacing: 8) {
                    Circle()
                        .fill(scanner.isScanning ? Theme.accentColor : Theme.subtleTextColor.opacity(0.2))
                        .frame(width: 6, height: 6)
                    Text(scanner.isScanning ? "Mossy is cleaning..." : "System Idle")
                        .font(.industrialMono)
                        .foregroundColor(Theme.subtleTextColor)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .modifier(Theme.GlassBackground())
                .padding()
            }
        }
        .padding()
        // Removed local MeshGradient, now handled by MainView

    }
    
    private func selectFolder(forTarget: Bool) {
        Task { @MainActor in
            let panel = NSOpenPanel()
            panel.canChooseFiles = false
            panel.canChooseDirectories = true
            panel.allowsMultipleSelection = forTarget
            panel.directoryURL = URL(fileURLWithPath: "/Volumes")
            
            if panel.runModal() == .OK {
                if forTarget {
                    for url in panel.urls {
                        if !self.targetDrives.contains(url) && self.referenceDrive != url {
                            self.targetDrives.append(url)
                        }
                    }
                } else if let url = panel.url {
                    self.referenceDrive = url
                    // If it was already a target, remove it from targets
                    self.targetDrives.removeAll { $0 == url }
                }
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider], isTarget: Bool) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: UTType.folder.identifier, options: nil) { item, _ in
                if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                    DispatchQueue.main.async {
                        if isTarget {
                            if !self.targetDrives.contains(url) && self.referenceDrive != url {
                                self.targetDrives.append(url)
                            }
                        } else {
                            self.referenceDrive = url
                            self.targetDrives.removeAll { $0 == url }
                        }
                    }
                }
            }
        }
    }
}
