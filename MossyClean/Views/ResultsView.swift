import SwiftUI

struct ResultsView: View {
    @ObservedObject var scanner: FileScanner
    @Environment(\.dismiss) var dismiss
    @State private var showingRiskAlert = false
    @State private var fileForAlert: FileModel?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with industrial border
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duplicate Discovery")
                        .font(.industrialTitle)
                        .foregroundColor(Theme.textColor)
                    Text("Potential Cleanup: \(ByteCountFormatter.string(fromByteCount: scanner.potentialSpaceSaved, countStyle: .file))")
                        .font(.industrialMono)
                        .foregroundColor(Theme.accentColor)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                        .font(.industrialHeadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Theme.secondaryBackground.opacity(0.5))
                        .modifier(Theme.IndustrialBorder(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 10)
                
                Button(action: {
                    Task {
                        await scanner.cleanupSelectedFiles()
                    }
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Move to Trash")
                    }
                    .font(.industrialHeadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Theme.warnColor, Theme.warnColor.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(color: Theme.warnColor.opacity(0.3), radius: 10, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(scanner.isScanning || scanner.duplicates.isEmpty)
                .modifier(Theme.HapticPulse(isActive: false))
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .modifier(Theme.IndustrialBorder(cornerRadius: 0)) // Pinned header
            
            // List of grouped duplicates
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(Array(scanner.duplicates.keys), id: \.self) { hash in
                        if let group = scanner.duplicates[hash] {
                            GroupedDuplicateCard(
                                files: group,
                                scanner: scanner,
                                onSelectionAttempt: { file in
                                    if file.isProtected {
                                        fileForAlert = file
                                        showingRiskAlert = true
                                        return false // Intercept
                                    }
                                    return true // Allow
                                }
                            )
                            .modifier(Theme.GlassBackground())
                        }
                    }
                }
                .padding(24)
            }
            
            // Status Footer
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(Theme.accentColor)
                Text(scanner.statusMessage)
                    .font(.industrialMono)
                    .foregroundColor(Theme.subtleTextColor)
                Spacer()
            }
            .padding(16)
            .background(.ultraThinMaterial)
        }
        .alert(isPresented: $showingRiskAlert) {
            Alert(
                title: Text("Risk Awareness: Code Artifact"),
                message: Text("The file '\(fileForAlert?.name ?? "this file")' is a protected code artifact. Deleting it may impact project logic or dependencies."),
                primaryButton: .destructive(Text("Confirm Risk")) {
                    if let file = fileForAlert {
                        scanner.manualToggleSelection(for: file)
                    }
                },
                secondaryButton: .default(Text("Export Info & Inspect")) {
                    if let url = fileForAlert?.url {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(url.path, forType: .string)
                        scanner.statusMessage = "Path exported to clipboard for inspection."
                    }
                }
            )
        }
    }
}

struct GroupedDuplicateCard: View {
    let files: [FileModel]
    @ObservedObject var scanner: FileScanner
    var onSelectionAttempt: (FileModel) -> Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Identical Duplicates (\(files.count))")
                .font(.industrialMono)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Theme.accentColor.opacity(0.1))
                .foregroundColor(Theme.accentColor)
            
            VStack(spacing: 0) {
                ForEach(files) { file in
                    HStack {
                        Image(systemName: file.iconName)
                            .foregroundColor(Theme.subtleTextColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(file.name)
                                    .font(.system(size: 13, weight: .medium))
                                    .lineLimit(1)
                                
                                if file.isProtected {
                                    HStack(spacing: 3) {
                                        Image(systemName: "shield.fill")
                                            .font(.system(size: 8))
                                        Text("PROTECTED")
                                            .font(.industrialMono)
                                            .font(.system(size: 8))
                                    }
                                    .foregroundColor(Theme.accentColor)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Theme.accentColor.opacity(0.1))
                                    .cornerRadius(4)
                                }
                            }
                            
                            Text("\(file.formattedSize) • Modified: \(file.modificationDate, style: .date)")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.subtleTextColor)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { scanner.scannedFiles.first { $0.id == file.id }?.isSelectedForCleanup ?? false },
                            set: { newValue in
                                if onSelectionAttempt(file) {
                                    if let index = scanner.scannedFiles.firstIndex(where: { $0.id == file.id }) {
                                        scanner.scannedFiles[index].isSelectedForCleanup = newValue
                                        updatePotentialSpace()
                                    }
                                }
                            }
                        ))
                        .toggleStyle(CheckboxToggleStyle())
                        .opacity(file.isProtected ? 0.7 : 1.0)
                        .help(file.isProtected ? "Protected artifact - Expert override required" : "Select for cleanup")
                    }
                    .padding(8)
                    .background(Theme.secondaryBackground.opacity(0.4))
                    
                    if file.id != files.last?.id {
                        Divider().background(Theme.subtleTextColor.opacity(0.1))
                    }
                }
            }
            .modifier(Theme.IndustrialBorder())
        }
    }
    
    private func updatePotentialSpace() {
        var space: Int64 = 0
        for file in scanner.scannedFiles {
            if file.isSelectedForCleanup {
                space += file.size
            }
        }
        scanner.potentialSpaceSaved = space
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? Theme.warnColor : Theme.subtleTextColor)
                .font(.system(size: 18))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
