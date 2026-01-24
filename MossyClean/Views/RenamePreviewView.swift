import SwiftUI

struct RenamePreviewView: View {
    @ObservedObject var organizer: FileOrganizer
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Optimization Preview")
                        .font(.industrialTitle)
                        .foregroundColor(Theme.textColor)
                    Text("Applying the [XX]_[TopName] Filter")
                        .font(.industrialMono)
                        .foregroundColor(Theme.accentColor)
                }
                Spacer()
                
                Button("Discard") {
                    dismiss()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(Theme.warnColor)
                
                Button(action: {
                    organizer.performRename()
                    dismiss()
                }) {
                    Text("Commit Changes")
                        .font(.industrialHeadline)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Theme.accentColor)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .shadow(color: Theme.accentColor.opacity(0.3), radius: 10, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(organizer.isProcessing)
                .modifier(Theme.HapticPulse(isActive: false))
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .modifier(Theme.IndustrialBorder(cornerRadius: 0))
            
            // Preview Table
            List {
                HStack {
                    Text("Original Name")
                        .font(.industrialMono)
                    Spacer()
                    Image(systemName: "arrow.right")
                    Spacer()
                    Text("Optimized Name")
                        .font(.industrialMono)
                }
                .foregroundColor(Theme.subtleTextColor)
                .padding(.vertical, 12)
                .scrollContentBackground(.hidden)
                
                ForEach(organizer.renamePairs) { pair in
                    HStack {
                        Text(pair.originalName)
                            .font(.industrialBody)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(Theme.accentColor.opacity(0.4))
                        
                        Text(pair.newName)
                            .font(.industrialMono)
                            .foregroundColor(Theme.accentColor)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            
            // Footer
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(Theme.accentColor)
                Text(organizer.statusMessage.isEmpty ? "Groundskeeper is ready to tidy up." : organizer.statusMessage)
                    .font(.industrialMono)
                    .foregroundColor(Theme.subtleTextColor)
                Spacer()
            }
            .padding(16)
            .background(.ultraThinMaterial)
        }
        .frame(width: 700, height: 500)
        .background(Theme.MeshGradient())
        .preferredColorScheme(.dark)
    }
}
