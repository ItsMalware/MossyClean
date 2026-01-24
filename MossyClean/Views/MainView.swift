import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab? = .scanner
    @State private var mascotMessage: String? = nil
    @State private var mascotPulse = false
    @StateObject private var scanner = FileScanner()
    
    private let greetings = ["Ready to clean!", "The grounds look good today.", "Found some dust!", "Scanning... beep boop.", "Hello, Groundskeeper!"]
    
    enum Tab {
        case scanner, organizer, settings
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    NavigationLink(
                        destination: ScannerView(scanner: scanner),
                        tag: Tab.scanner,
                        selection: $selectedTab
                    ) {
                        Label("Scanner", systemImage: "magnifyingglass")
                    }
                    
                    NavigationLink(
                        destination: OrganizerView(),
                        tag: Tab.organizer,
                        selection: $selectedTab
                    ) {
                        Label("Organizer", systemImage: "folder.fill")
                    }
                    
                    Divider()
                    
                    NavigationLink(
                        destination: SettingsView(),
                        tag: Tab.settings,
                        selection: $selectedTab
                    ) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                .listStyle(SidebarListStyle())
                .scrollContentBackground(.hidden) // Pro Max: Remove default list background
                
                // Pinned Mascot Companion at Bottom
                ZStack(alignment: .bottom) {
                    // Mossy Growth Decor
                    Theme.MossyGrowth()
                        .opacity(0.8)
                    
                    VStack(spacing: 8) {
                        if let message = mascotMessage {
                            Text(message)
                                .font(.industrialMono)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .cornerRadius(8)
                                .modifier(Theme.IndustrialBorder(cornerRadius: 8))
                                .transition(.scale.combined(with: .opacity))
                                .padding(.bottom, 8)
                        }
                        
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                mascotPulse = true
                                mascotMessage = greetings.randomElement()
                            }
                            // Reset pulse
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                mascotPulse = false
                            }
                            // Auto-hide message
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    mascotMessage = nil
                                }
                            }
                        } label: {
                            if let mascotURL = URL(string: "file:///Users/yaz_malware_honeypot/.gemini/antigravity/brain/bda18899-1f42-4191-9507-eb79a4331322/uploaded_media_1769280217124.png") {
                                AsyncImage(url: mascotURL) { image in
                                    image.resizable()
                                         .aspectRatio(contentMode: .fit)
                                         .frame(height: 100) // Slightly smaller to ensure framing
                                         .scaleEffect(mascotPulse ? 1.1 : 1.0)
                                         .modifier(Theme.MascotEffect())
                                } placeholder: {
                                    ProgressView().controlSize(.small)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("Click Mossy for a status report!")
                    }
                    .padding(.bottom, 15)
                    .frame(maxWidth: .infinity)
                }
                .frame(height: 160)
                .background(.ultraThinMaterial) // Pro Max: Glass sidebar base
            }
            .frame(minWidth: 200)
            .background(Theme.secondaryBackground.opacity(0.4))
            
            // Default view
            ScannerView(scanner: scanner)
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Theme.MeshGradient()) // Pro Max: Living mesh backdrop
        .preferredColorScheme(.dark)
    }
}
