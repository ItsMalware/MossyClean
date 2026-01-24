import SwiftUI

struct OrganizerView: View {
    @StateObject private var organizer = FileOrganizer()
    @State private var showingPreview = false
    
    var body: some View {
        VStack(spacing: 48) {
            Text("Mossy Clean")
                .font(.industrialLargeTitle)
                .foregroundColor(Theme.textColor)
            
            if let selectedFolder = organizer.selectedFolder {
                VStack(spacing: 32) {
                    HStack(spacing: 16) {
                        Image(systemName: "folder.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Theme.accentColor)
                        Text(selectedFolder.lastPathComponent)
                            .font(.industrialTitle)
                    }
                    .padding(24)
                    .modifier(Theme.GlassBackground())
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Groundskeeper's Suggestion:")
                            .font(.industrialMono)
                            .foregroundColor(Theme.subtleTextColor)
                        
                        HStack(spacing: 0) {
                            TextField("Top Name", text: Binding(
                                get: { organizer.suggestedTopName },
                                set: { organizer.updateTopName($0) }
                            ))
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.industrialBody)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .modifier(Theme.IndustrialBorder())
                            
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 20))
                                .foregroundColor(Theme.accentColor)
                                .padding(.leading, 12)
                        }
                    }
                    .padding(.horizontal, 48)
                    
                    Button(action: {
                        showingPreview = true
                    }) {
                        Text("Preview Optimization")
                            .font(.industrialHeadline)
                            .padding(.horizontal, 48)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Theme.accentColor, Theme.accentColor.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .foregroundColor(.black)
                            .cornerRadius(14)
                            .shadow(color: Theme.accentColor.opacity(0.2), radius: 10, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .modifier(Theme.HapticPulse(isActive: false))
                }
                .sheet(isPresented: $showingPreview) {
                    RenamePreviewView(organizer: organizer)
                }
            } else {
                VStack(spacing: 24) {
                    Image(systemName: "folder.badge.gearshape")
                        .font(.system(size: 72, weight: .light))
                        .foregroundColor(Theme.accentColor)
                        .shadow(color: Theme.accentColor.opacity(0.4), radius: 15)
                    
                    Text("Pro Grade Organization")
                        .font(.industrialTitle)
                        .foregroundColor(Theme.textColor)
                    
                    Text("Mossy will suggest the best names for your files and organize them into tidy folders using the [XX]_[TopName] format.")
                        .font(.industrialBody)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Theme.subtleTextColor)
                        .padding(.horizontal, 60)
                }
                .padding(48)
                .modifier(Theme.GlassBackground())
                .padding(.horizontal, 48)
                
                Button(action: {
                    selectFolder()
                }) {
                    Text("Select Folder")
                        .font(.industrialHeadline)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 16)
                        .background(Theme.accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Spacer()
        }
        .padding()
        // MeshGradient handled by MainView
    }
    
    private func selectFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK {
            if let url = panel.url {
                organizer.selectFolder(at: url)
            }
        }
    }
}
