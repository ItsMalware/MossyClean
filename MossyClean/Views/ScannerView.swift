import SwiftUI
import UniformTypeIdentifiers

struct ScannerView: View {
    @ObservedObject var scanner: FileScanner
    @State private var isDragging: Bool = false
    @State private var navigatingToResults = false
    
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(isDragging ? Theme.accentColor : Theme.subtleTextColor.opacity(0.2), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                        
                        VStack(spacing: 24) {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 56, weight: .light))
                                .foregroundColor(Theme.accentColor)
                                .shadow(color: Theme.accentColor.opacity(0.4), radius: 10)
                            
                            VStack(spacing: 8) {
                                Text("Drop Folder Here")
                                    .font(.industrialHeadline)
                                    .foregroundColor(Theme.textColor)
                                
                                Text("Industrial grade cleanup starts here")
                                    .font(.industrialBody)
                                    .foregroundColor(Theme.subtleTextColor)
                            }
                        }
                    }
                    .frame(maxHeight: 280)
                    .modifier(Theme.GlassBackground()) // Pro Max: Glass drop zone
                    .padding(.horizontal, 48)
                    .onTapGesture {
                        selectFolder()
                    }
                    .onDrop(of: [UTType.folder], isTargeted: $isDragging) { providers in
                        guard let provider = providers.first else { return false }
                        provider.loadItem(forTypeIdentifier: UTType.folder.identifier, options: nil) { item, _ in
                            if let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                                Task { @MainActor in
                                    withAnimation {
                                        scanner.scan(at: url)
                                    }
                                }
                            }
                        }
                        return true
                    }
                    .transition(.opacity)
                    
                    if !scanner.duplicates.isEmpty {
                        VStack(spacing: 20) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(Theme.warnColor)
                                Text("Found \(scanner.duplicates.count) Duplicate Groups")
                                    .font(.system(.headline, design: .monospaced))
                            }
                                                       NavigationLink(
                                destination: ResultsView(scanner: scanner),
                                isActive: $navigatingToResults
                            ) {
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
                            }
                            .buttonStyle(PlainButtonStyle())
                            .modifier(Theme.HapticPulse(isActive: false)) 
                            
                            Text(scanner.potentialSpaceSaved > 0 ? "Potential space to reclaim: \(ByteCountFormatter.string(fromByteCount: scanner.potentialSpaceSaved, countStyle: .file))" : "Mac state: Optimized")
                                .font(.industrialMono)
                                .foregroundColor(Theme.subtleTextColor)
                        }
                        .padding(40)
                        .modifier(Theme.GlassBackground()) // Pro Max: Glass results card
                    } else {
                        VStack(spacing: 24) {
                            // Professional "OR" Separator
                            HStack {
                                Rectangle().fill(Theme.subtleTextColor.opacity(0.1)).frame(height: 1)
                                Text("— OR —")
                                    .font(.industrialMono)
                                    .foregroundColor(Theme.subtleTextColor.opacity(0.5))
                                Rectangle().fill(Theme.subtleTextColor.opacity(0.1)).frame(height: 1)
                            }
                            .padding(.horizontal, 80)
                            
                            Button(action: {
                                scanner.scanHomeDirectory()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "house.fill")
                                    Text("Scan Home Directory")
                                }
                                .font(.industrialHeadline)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(Theme.accentColor)
                                .foregroundColor(.black)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.top, 24)
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
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                scanner.scan(at: url)
            }
        }
    }
}
